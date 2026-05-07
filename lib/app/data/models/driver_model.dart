import 'package:latlong2/latlong.dart';

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String avatarUrl;
  final String vehicleType;
  final String vehicleNumber;
  final double rating;
  final int totalTrips;
  final LatLng location;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.rating,
    required this.totalTrips,
    required this.location,
  });

  DriverModel copyWith({LatLng? location}) {
    return DriverModel(
      id: id,
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      rating: rating,
      totalTrips: totalTrips,
      location: location ?? this.location,
    );
  }
}
