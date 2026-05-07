import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:driver_location/app/core/utils/distance_calculator.dart';

void main() {
  test('GeoCalculator.formatDistance rounds sub-km values to 100 m',
      () {
    expect(GeoCalculator.formatDistance(0.247), '200 m');
    expect(GeoCalculator.formatDistance(0.38), '400 m');
    expect(GeoCalculator.formatDistance(0.97), '1.0 km');
    expect(GeoCalculator.formatDistance(1.4), '1.4 km');
  });

  test('GeoCalculator.kilometersBetween returns ~0 for the same point', () {
    const point = LatLng(28.6139, 77.2090);
    expect(GeoCalculator.kilometersBetween(point, point), closeTo(0, 0.001));
  });
}
