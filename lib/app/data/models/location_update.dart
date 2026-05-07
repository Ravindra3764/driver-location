import 'package:latlong2/latlong.dart';

class LocationUpdate {
  final LatLng position;
  final double bearing;
  final DateTime timestamp;

  const LocationUpdate({
    required this.position,
    required this.bearing,
    required this.timestamp,
  });
}
