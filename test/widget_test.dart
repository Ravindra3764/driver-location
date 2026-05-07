import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:driver_location/app/core/utils/distance_calculator.dart';

void main() {
  test('GeoCalculator.formatDistance formats sub-kilometer values in meters',
      () {
    expect(GeoCalculator.formatDistance(0.25), '250 m');
    expect(GeoCalculator.formatDistance(1.4), '1.4 km');
  });

  test('GeoCalculator.kilometersBetween returns ~0 for the same point', () {
    const point = LatLng(28.6139, 77.2090);
    expect(GeoCalculator.kilometersBetween(point, point), closeTo(0, 0.001));
  });
}
