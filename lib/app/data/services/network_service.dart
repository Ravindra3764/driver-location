import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/enums/network_status.dart';

class NetworkService {
  NetworkService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkStatus _current = NetworkStatus.online;

  Stream<NetworkStatus> get stream => _controller.stream;
  NetworkStatus get current => _current;

  Future<void> init() async {
    final List<ConnectivityResult> initial =
        await _connectivity.checkConnectivity();
    _emit(_resolve(initial));

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _emit(_resolve(results));
    });
  }

  /// Manual override for demo / debug — useful for the offline toggle in UI.
  void setManualStatus(NetworkStatus status) {
    _emit(status);
  }

  NetworkStatus _resolve(List<ConnectivityResult> results) {
    final bool hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    return hasConnection ? NetworkStatus.online : NetworkStatus.offline;
  }

  void _emit(NetworkStatus status) {
    _current = status;
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
