import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uztelecom/app/app_services.dart';
import 'package:uztelecom/core/config/app_config.dart';
import 'package:uztelecom/core/routing/app_router.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/ui/pages/shared/no_internet_page.dart';

class ConnectivityGate extends StatefulWidget {
  final Widget child;

  const ConnectivityGate({super.key, required this.child});

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  bool _checking = false;
  bool _offlineRouteOpen = false;
  Route<void>? _offlineRoute;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  final Connectivity _connectivity = Connectivity();
  late final http.Client _client;
  static final Uri _probeUri = AppConfig.connectivityProbeUri;

  @override
  void initState() {
    super.initState();
    _client = context.read<AppServices>().httpClient;
    _check();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) {
      _check();
    });
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    final connected = await _isConnected();
    if (!mounted) return;
    setState(() {
      _checking = false;
    });
    if (!connected) {
      _showOfflinePage();
    } else if (_offlineRouteOpen) {
      _offlineRouteOpen = false;
      final route = _offlineRoute;
      _offlineRoute = null;
      if (route != null && route.isActive) {
        AppRouter.navigatorKey.currentState?.removeRoute(route);
      }
    }
  }

  Future<bool> _isConnected() async {
    final result = await _connectivity.checkConnectivity();
    final hasTransport = _hasActiveTransport(result);
    if (!hasTransport) return false;
    return _canReachBackend();
  }

  bool _hasActiveTransport(List<ConnectivityResult> result) =>
      result.any((item) => item != ConnectivityResult.none);

  Future<bool> _canReachBackend() async {
    try {
      final response = await _client
          .head(_probeUri)
          .timeout(const Duration(seconds: 4));
      return response.statusCode > 0;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Connectivity probe failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void _showOfflinePage() {
    if (_offlineRouteOpen) return;
    _offlineRouteOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = AppRouter.navigatorKey.currentState;
      if (navigator == null) {
        _offlineRouteOpen = false;
        return;
      }
      final route = MaterialPageRoute<void>(
        builder: (_) => NoInternetPage(onRetry: _check),
        settings: const RouteSettings(name: 'offline-gate'),
      );
      _offlineRoute = route;
      navigator.push(route).then((_) {
        if (identical(_offlineRoute, route)) {
          _offlineRoute = null;
        }
        _offlineRouteOpen = false;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
