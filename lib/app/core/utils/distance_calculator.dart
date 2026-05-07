import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

class GeoCalculator {
  GeoCalculator._();

  static const double _earthRadiusKm = 6371.0;

  static double kilometersBetween(LatLng a, LatLng b) {
    final double dLat = _toRadians(b.latitude - a.latitude);
    final double dLng = _toRadians(b.longitude - a.longitude);
    final double lat1 = _toRadians(a.latitude);
    final double lat2 = _toRadians(b.latitude);

    final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(lat1) * math.cos(lat2);
    final double c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return _earthRadiusKm * c;
  }

  static String formatDistance(double km) {
    if (km < 1) {
      final int meters = (km * 1000).round();
      return '$meters m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatEta(double km, {double avgSpeedKmh = 25}) {
    final double minutes = (km / avgSpeedKmh) * 60;
    final int rounded = minutes.ceil();
    if (rounded < 1) return '< 1 min';
    return '$rounded min';
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;
}
