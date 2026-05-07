import 'package:latlong2/latlong.dart';

import '../models/driver_model.dart';

class MockDriverData {
  MockDriverData._();

  static const LatLng customerDropLocation = LatLng(28.6139, 77.2090);

  static const LatLng driverStartLocation = LatLng(28.6050, 77.2010);

  /// A pre-built path leading from the driver's starting point to the
  /// customer's drop location. Each step represents the driver's position
  /// after a 3-second tick.
  static const List<LatLng> deliveryRoute = [
    LatLng(28.6050, 77.2010),
    LatLng(28.6058, 77.2018),
    LatLng(28.6066, 77.2026),
    LatLng(28.6074, 77.2034),
    LatLng(28.6082, 77.2042),
    LatLng(28.6090, 77.2050),
    LatLng(28.6098, 77.2058),
    LatLng(28.6106, 77.2066),
    LatLng(28.6114, 77.2074),
    LatLng(28.6122, 77.2082),
    LatLng(28.6130, 77.2086),
    LatLng(28.6135, 77.2088),
    LatLng(28.6139, 77.2090),
  ];

  static DriverModel get sampleDriver => DriverModel(
    id: 'drv_8821',
    name: 'Arjun Mehta',
    phone: '+91 98xxxxxx21',
    avatarUrl: 'https://cdn.marvel.com/content/2x/005smp_ons_cut_mob_01_6.jpg',
    vehicleType: 'Scooter',
    vehicleNumber: 'DL 4S AB 2241',
    rating: 4.8,
    totalTrips: 1342,
    location: driverStartLocation,
  );

  static const String customerName = 'Ravindra';
  static const String dropAddress = 'Connaught Place, New Delhi';
  static const String orderId = 'ORD-90041';
}
