import 'package:flutter/material.dart';
import 'package:uztelecom/application/facades/dashboard_facade.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/data/models/main_dashboard_data.dart';

class MainPageProvider with ChangeNotifier {
  MainPageProvider({required DashboardFacade dashboardFacade})
    : _dashboardFacade = dashboardFacade;

  final DashboardFacade _dashboardFacade;

  bool _isLoading = true;
  Object? _error;
  MainDashboardData? _data;
  String _appBarName = '';

  bool get isLoading => _isLoading;
  Object? get error => _error;
  MainDashboardData? get data => _data;
  String get appBarName => _appBarName;

  Future<void> load({bool force = false}) async {
    final hasData = _data != null;
    if (!hasData || force) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      _isLoading = false;
      _error = null;
    }

    await _seedAppBarName();

    try {
      final nextData = await _dashboardFacade.load();
      _data = nextData;
      _error = null;
      if (nextData.fullName.trim().isNotEmpty) {
        _appBarName = nextData.fullName.trim();
      }
    } catch (error) {
      if (!hasData) {
        _error = error;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedAppBarName() async {
    try {
      final name = await _dashboardFacade.cachedProfileName();
      if (name.isEmpty || name == _appBarName) return;
      _appBarName = name;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to seed dashboard app bar name from cache.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
