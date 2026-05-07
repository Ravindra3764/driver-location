import 'dart:async';

import '../../core/enums/delivery_status.dart';
import '../mock/mock_driver_data.dart';
import '../models/delivery_model.dart';

/// Mock backend that progresses the delivery through its lifecycle.
/// Emits a fresh DeliveryModel on each transition.
class DeliveryService {
  DeliveryService();

  final StreamController<DeliveryModel> _controller =
      StreamController<DeliveryModel>.broadcast();

  Timer? _searchTimer;
  Timer? _assignTimer;

  DeliveryModel _current = DeliveryModel(
    orderId: MockDriverData.orderId,
    customerName: MockDriverData.customerName,
    dropAddress: MockDriverData.dropAddress,
    dropLocation: MockDriverData.customerDropLocation,
    driver: null,
    status: DeliveryStatus.searching,
    updatedAt: DateTime.now(),
  );

  Stream<DeliveryModel> get stream => _controller.stream;
  DeliveryModel get current => _current;

  /// Begin the simulated lifecycle: searching → assigned → arriving.
  /// Delivered is triggered externally when the driver reaches the drop point.
  void start() {
    _emit(_current);

    _searchTimer = Timer(const Duration(seconds: 4), () {
      _transitionTo(
        DeliveryStatus.assigned,
        driver: MockDriverData.sampleDriver,
      );
      _assignTimer = Timer(const Duration(seconds: 3), () {
        _transitionTo(DeliveryStatus.arriving);
      });
    });
  }

  void markDelivered() {
    if (_current.status == DeliveryStatus.delivered) return;
    _transitionTo(DeliveryStatus.delivered);
  }

  /// Cancel any in-flight transitions and rewind back to the initial
  /// "searching" state. Use [start] afterwards to replay the lifecycle.
  void reset() {
    _searchTimer?.cancel();
    _assignTimer?.cancel();
    _searchTimer = null;
    _assignTimer = null;
    _current = DeliveryModel(
      orderId: MockDriverData.orderId,
      customerName: MockDriverData.customerName,
      dropAddress: MockDriverData.dropAddress,
      dropLocation: MockDriverData.customerDropLocation,
      driver: null,
      status: DeliveryStatus.searching,
      updatedAt: DateTime.now(),
    );
    _emit(_current);
  }

  void _transitionTo(DeliveryStatus status, {dynamic driver}) {
    _current = _current.copyWith(
      status: status,
      driver: driver ?? _current.driver,
      updatedAt: DateTime.now(),
    );
    _emit(_current);
  }

  void _emit(DeliveryModel model) {
    if (!_controller.isClosed) {
      _controller.add(model);
    }
  }

  Future<void> dispose() async {
    _searchTimer?.cancel();
    _assignTimer?.cancel();
    await _controller.close();
  }
}
