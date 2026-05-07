import 'package:latlong2/latlong.dart';

import '../../core/enums/delivery_status.dart';
import 'driver_model.dart';

class DeliveryModel {
  final String orderId;
  final String customerName;
  final String dropAddress;
  final LatLng dropLocation;
  final DriverModel? driver;
  final DeliveryStatus status;
  final DateTime updatedAt;

  const DeliveryModel({
    required this.orderId,
    required this.customerName,
    required this.dropAddress,
    required this.dropLocation,
    required this.driver,
    required this.status,
    required this.updatedAt,
  });

  DeliveryModel copyWith({
    DriverModel? driver,
    DeliveryStatus? status,
    DateTime? updatedAt,
  }) {
    return DeliveryModel(
      orderId: orderId,
      customerName: customerName,
      dropAddress: dropAddress,
      dropLocation: dropLocation,
      driver: driver ?? this.driver,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
