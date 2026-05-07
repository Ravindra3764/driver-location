import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/enums/delivery_status.dart';
import '../../../core/enums/network_status.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../data/mock/mock_driver_data.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/models/location_update.dart';
import '../../../data/services/delivery_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/network_service.dart';

class DeliveryTrackingController extends GetxController {
  DeliveryTrackingController({
    required this.locationService,
    required this.networkService,
    required this.deliveryService,
  });

  final LocationService locationService;
  final NetworkService networkService;
  final DeliveryService deliveryService;

  // --- Reactive state ---------------------------------------------------
  final Rx<DeliveryModel> delivery = Rx<DeliveryModel>(
    DeliveryModel(
      orderId: MockDriverData.orderId,
      customerName: MockDriverData.customerName,
      dropAddress: MockDriverData.dropAddress,
      dropLocation: MockDriverData.customerDropLocation,
      driver: null,
      status: DeliveryStatus.searching,
      updatedAt: DateTime.now(),
    ),
  );

  final Rx<NetworkStatus> networkStatus = NetworkStatus.online.obs;
  final Rxn<LocationUpdate> latestLocation = Rxn<LocationUpdate>();
  final RxBool isDriverDetailsOpen = false.obs;
  final RxBool justReconnected = false.obs;

  /// Smoothly interpolated position used by the UI. Backend ticks land
  /// every ~3s; we tween between them at 60fps so the marker glides
  /// instead of jumping.
  final Rxn<LatLng> animatedDriverPosition = Rxn<LatLng>();

  /// Cache: the last location that was successfully received while online.
  /// Used to render the partner when the device goes offline.
  LocationUpdate? lastKnownLocation;
  DeliveryStatus lastKnownStatus = DeliveryStatus.searching;

  /// Frozen at the moment connectivity is lost. While offline the UI
  /// keeps rendering this position even though the backend simulation
  /// keeps progressing, so the customer sees a stable "last known" view.
  LocationUpdate? _offlineSnapshot;
  DeliveryStatus? _offlineStatusSnapshot;

  // --- Derived getters --------------------------------------------------
  DriverModel? get driver => delivery.value.driver;
  DeliveryStatus get status =>
      isOffline ? (_offlineStatusSnapshot ?? delivery.value.status) : delivery.value.status;
  bool get isOffline => networkStatus.value.isOffline;

  LatLng? get displayedDriverLocation {
    if (isOffline) {
      return _offlineSnapshot?.position ?? lastKnownLocation?.position;
    }
    return animatedDriverPosition.value ??
        latestLocation.value?.position ??
        lastKnownLocation?.position;
  }

  int? get displayedRouteIndex {
    if (isOffline) {
      return _offlineSnapshot?.routeIndex ?? lastKnownLocation?.routeIndex;
    }
    return latestLocation.value?.routeIndex ?? lastKnownLocation?.routeIndex;
  }

  List<LatLng> get fullRoute => locationService.fullRoute;

  double? get distanceKm {
    final LatLng? pos = displayedDriverLocation;
    if (pos == null) return null;
    return GeoCalculator.kilometersBetween(pos, delivery.value.dropLocation);
  }

  String get distanceLabel {
    final double? km = distanceKm;
    if (km == null) return '--';
    return GeoCalculator.formatDistance(km);
  }

  String get etaLabel {
    final double? km = distanceKm;
    if (km == null) return '--';
    return GeoCalculator.formatEta(km);
  }

  // --- Map controller ---------------------------------------------------
  final MapController mapController = MapController();

  // --- Subscriptions ----------------------------------------------------
  StreamSubscription<LocationUpdate>? _locationSub;
  StreamSubscription<NetworkStatus>? _networkSub;
  StreamSubscription<DeliveryModel>? _deliverySub;
  Timer? _reconnectBannerTimer;

  // --- Smooth-marker interpolation -------------------------------------
  Timer? _animTimer;
  LatLng? _animFrom;
  LatLng? _animTo;
  DateTime? _animStartedAt;
  Duration _animDuration = const Duration(milliseconds: 2900);

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await networkService.init();
    networkStatus.value = networkService.current;

    _networkSub = networkService.stream.listen(_onNetworkChanged);
    _deliverySub = deliveryService.stream.listen(_onDeliveryChanged);
    _locationSub = locationService.stream.listen(_onLocationUpdate);

    // Match interpolation duration to the backend tick interval, with a
    // small buffer so animation finishes just before the next tick lands.
    _animDuration = locationService.interval - const Duration(milliseconds: 100);
    if (_animDuration.isNegative) {
      _animDuration = locationService.interval;
    }

    // Mock backend simulation runs independently of customer connectivity.
    deliveryService.start();
    locationService.start();

    if (networkStatus.value.isOffline) {
      _offlineSnapshot = latestLocation.value;
      _offlineStatusSnapshot = delivery.value.status;
    }
  }

  // --- Stream handlers --------------------------------------------------
  void _onLocationUpdate(LocationUpdate update) {
    // Mock backend keeps simulating even while the customer is offline.
    // We always cache the latest tick so a reconnect can snap straight
    // to the partner's *current* position instead of replaying from a
    // stale point.
    final LatLng? previousTarget = _animTo ?? latestLocation.value?.position;
    latestLocation.value = update;
    lastKnownLocation = update;

    // Use the previous tick's target as the start point so the marker
    // glides continuously without snapping back.
    _startMarkerAnimation(
      from: previousTarget ?? update.position,
      to: update.position,
    );

    // Auto-mark delivered when partner reaches drop point.
    final double km = GeoCalculator.kilometersBetween(
      update.position,
      delivery.value.dropLocation,
    );
    if (km < 0.03 && delivery.value.status == DeliveryStatus.arriving) {
      deliveryService.markDelivered();
      locationService.stop();
    }
  }

  void _startMarkerAnimation({required LatLng from, required LatLng to}) {
    _animTimer?.cancel();
    // No movement — skip the timer entirely.
    if (from.latitude == to.latitude && from.longitude == to.longitude) {
      animatedDriverPosition.value = to;
      return;
    }
    _animFrom = from;
    _animTo = to;
    _animStartedAt = DateTime.now();
    animatedDriverPosition.value = from;

    const Duration frame = Duration(milliseconds: 16);
    _animTimer = Timer.periodic(frame, (timer) {
      final DateTime? started = _animStartedAt;
      final LatLng? a = _animFrom;
      final LatLng? b = _animTo;
      if (started == null || a == null || b == null) {
        timer.cancel();
        return;
      }
      final int elapsed = DateTime.now().difference(started).inMilliseconds;
      final double t =
          (elapsed / _animDuration.inMilliseconds).clamp(0.0, 1.0);
      // Ease-in-out for a more natural feel.
      final double eased = _easeInOut(t);
      animatedDriverPosition.value = LatLng(
        a.latitude + (b.latitude - a.latitude) * eased,
        a.longitude + (b.longitude - a.longitude) * eased,
      );
      if (t >= 1.0) {
        timer.cancel();
        _animTimer = null;
      }
    });
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;
  }

  void _onDeliveryChanged(DeliveryModel model) {
    delivery.value = model;
    if (model.status != DeliveryStatus.searching) {
      lastKnownStatus = model.status;
    }
  }

  void _onNetworkChanged(NetworkStatus status) {
    final NetworkStatus previous = networkStatus.value;
    networkStatus.value = status;

    if (previous.isOnline && status.isOffline) {
      // Freeze what the customer can see; the simulation keeps running
      // in the background so we can resync on reconnect.
      _offlineSnapshot = latestLocation.value ?? lastKnownLocation;
      _offlineStatusSnapshot = delivery.value.status;
      // Trigger a UI refresh so getters re-evaluate with the snapshot.
      latestLocation.refresh();
      delivery.refresh();
      return;
    }

    if (previous.isOffline && status.isOnline) {
      // Drop the snapshot — UI will now read the live position the
      // partner is currently at, regardless of how far they moved
      // while we were offline.
      _offlineSnapshot = null;
      _offlineStatusSnapshot = null;
      latestLocation.refresh();
      delivery.refresh();

      justReconnected.value = true;
      _reconnectBannerTimer?.cancel();
      _reconnectBannerTimer = Timer(const Duration(seconds: 2), () {
        justReconnected.value = false;
      });
    }
  }

  // --- UI actions -------------------------------------------------------
  void openDriverDetails() {
    if (driver == null) return;
    isDriverDetailsOpen.value = true;
  }

  void closeDriverDetails() {
    isDriverDetailsOpen.value = false;
  }

  void recenterMap() {
    final LatLng? pos = displayedDriverLocation;
    if (pos == null) return;
    mapController.move(pos, 15.5);
  }

  /// Replay the entire lifecycle from "searching" without restarting the
  /// app. Cancels in-flight timers, clears cached location, then kicks
  /// off the delivery + location services again.
  void restartTracking() {
    locationService.reset();
    deliveryService.reset();

    latestLocation.value = null;
    lastKnownLocation = null;
    lastKnownStatus = DeliveryStatus.searching;
    _offlineSnapshot = null;
    _offlineStatusSnapshot = null;
    animatedDriverPosition.value = null;
    _animTimer?.cancel();
    _animFrom = null;
    _animTo = null;
    _animStartedAt = null;
    isDriverDetailsOpen.value = false;
    justReconnected.value = false;
    _reconnectBannerTimer?.cancel();

    deliveryService.start();
    locationService.start();
  }

  /// Demo helper — toggles connectivity for manual testing without
  /// having to actually disable the device's network.
  void toggleSimulatedNetwork() {
    final NetworkStatus next = networkStatus.value.isOnline
        ? NetworkStatus.offline
        : NetworkStatus.online;
    networkService.setManualStatus(next);
  }

  @override
  void onClose() {
    _reconnectBannerTimer?.cancel();
    _animTimer?.cancel();
    _locationSub?.cancel();
    _networkSub?.cancel();
    _deliverySub?.cancel();
    locationService.dispose();
    networkService.dispose();
    deliveryService.dispose();
    super.onClose();
  }
}
