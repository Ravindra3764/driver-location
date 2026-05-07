import 'dart:async';
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../mock/mock_driver_data.dart';
import '../models/location_update.dart';

/// Streams mock driver locations along a fixed route at a fixed interval.
/// In a production app this would be replaced by a websocket / polling
/// client without changing the controller.
class LocationService {
  LocationService({
    Duration interval = const Duration(seconds: 3),
    List<LatLng>? route,
  })  : _interval = interval,
        _route = List<LatLng>.unmodifiable(route ?? MockDriverData.deliveryRoute);

  final Duration _interval;
  final List<LatLng> _route;
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();

  Timer? _timer;
  int _index = 0;

  Stream<LocationUpdate> get stream => _controller.stream;
  Duration get interval => _interval;
  bool get isStreaming => _timer?.isActive ?? false;

  void start() {
    if (isStreaming) return;
    // Emit current position immediately so listeners aren't waiting.
    _emitCurrent();
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    _index = 0;
  }

  void _tick() {
    if (_index >= _route.length - 1) {
      stop();
      return;
    }
    _index++;
    _emitCurrent();
  }

  void _emitCurrent() {
    final LatLng current = _route[_index];
    final LatLng next = _route[math.min(_index + 1, _route.length - 1)];
    final double bearing = _bearingBetween(current, next);
    _controller.add(
      LocationUpdate(
        position: current,
        bearing: bearing,
        timestamp: DateTime.now(),
      ),
    );
  }

  double _bearingBetween(LatLng a, LatLng b) {
    final double lat1 = _toRadians(a.latitude);
    final double lat2 = _toRadians(b.latitude);
    final double dLng = _toRadians(b.longitude - a.longitude);
    final double y = math.sin(dLng) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  double _toRadians(double degree) => degree * math.pi / 180.0;

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }
}
