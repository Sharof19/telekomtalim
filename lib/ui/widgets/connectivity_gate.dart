import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uztelecom/ui/pages/no_internet_page.dart';

class ConnectivityGate extends StatefulWidget {
  final Widget child;

  const ConnectivityGate({super.key, required this.child});

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  bool _checking = false;
  bool _offlineRouteOpen = false;
  StreamSubscription<dynamic>? _connectivitySub;
  static final Uri _probeUri = Uri.parse('https://eduapi.uztelecom.uz/');

  @override
  void initState() {
    super.initState();
    _check();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
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
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _isConnected() async {
    final result = await Connectivity().checkConnectivity();
    final hasTransport = _hasActiveTransport(result);
    if (hasTransport) return true;
    return _canReachBackend();
  }

  bool _hasActiveTransport(dynamic result) {
    if (result is List<ConnectivityResult>) {
      return result.any((item) => item != ConnectivityResult.none);
    }
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    // Unknown return shape should not force a false offline screen.
    return true;
  }

  Future<bool> _canReachBackend() async {
    final client = http.Client();
    try {
      final response =
          await client.head(_probeUri).timeout(const Duration(seconds: 4));
      return response.statusCode > 0;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  void _showOfflinePage() {
    if (_offlineRouteOpen) return;
    _offlineRouteOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NoInternetPage(onRetry: _check),
        ),
      );
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
