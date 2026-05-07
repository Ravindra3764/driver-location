import 'dart:async';

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

  /// Cache: the last location that was successfully received while online.
  /// Used to render the partner when the device goes offline.
  LocationUpdate? lastKnownLocation;
  DeliveryStatus lastKnownStatus = DeliveryStatus.searching;

  // --- Derived getters --------------------------------------------------
  DriverModel? get driver => delivery.value.driver;
  DeliveryStatus get status => delivery.value.status;
  bool get isOffline => networkStatus.value.isOffline;

  LatLng? get displayedDriverLocation {
    if (isOffline) return lastKnownLocation?.position;
    return latestLocation.value?.position ?? lastKnownLocation?.position;
  }

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

    deliveryService.start();
    if (networkStatus.value.isOnline) {
      locationService.start();
    }
  }

  // --- Stream handlers --------------------------------------------------
  void _onLocationUpdate(LocationUpdate update) {
    if (networkStatus.value.isOffline) return;
    latestLocation.value = update;
    lastKnownLocation = update;

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

  void _onDeliveryChanged(DeliveryModel model) {
    delivery.value = model;
    if (model.status != DeliveryStatus.searching) {
      lastKnownStatus = model.status;
    }
  }

  void _onNetworkChanged(NetworkStatus status) {
    final NetworkStatus previous = networkStatus.value;
    networkStatus.value = status;

    if (status.isOffline) {
      locationService.stop();
      return;
    }

    if (previous.isOffline && status.isOnline) {
      justReconnected.value = true;
      _reconnectBannerTimer?.cancel();
      _reconnectBannerTimer = Timer(const Duration(seconds: 2), () {
        justReconnected.value = false;
      });
      if (!delivery.value.status.isTerminal) {
        locationService.start();
      }
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
    isDriverDetailsOpen.value = false;
    justReconnected.value = false;
    _reconnectBannerTimer?.cancel();

    deliveryService.start();
    if (networkStatus.value.isOnline) {
      locationService.start();
    }
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
    _locationSub?.cancel();
    _networkSub?.cancel();
    _deliverySub?.cancel();
    locationService.dispose();
    networkService.dispose();
    deliveryService.dispose();
    super.onClose();
  }
}
