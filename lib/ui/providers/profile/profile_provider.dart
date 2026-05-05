import 'package:flutter/material.dart';
import 'package:uztelecom/application/use_cases/profile/load_profile_use_case.dart';
import 'package:uztelecom/data/models/profile_models.dart';

class ProfileProvider with ChangeNotifier {
  ProfileProvider({required LoadProfileUseCase loadProfile})
    : _loadProfile = loadProfile;

  final LoadProfileUseCase _loadProfile;

  bool _isLoading = true;
  Object? _error;
  ProfileInfo? _profile;

  bool get isLoading => _isLoading;
  Object? get error => _error;
  ProfileInfo? get profile => _profile;

  Future<void> load({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _loadProfile(forceRefresh: forceRefresh);
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
