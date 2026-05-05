import 'package:flutter/material.dart';
import 'package:uztelecom/application/use_cases/courses/load_courses_use_case.dart';
import 'package:uztelecom/data/models/course_item.dart';

class CoursesProvider with ChangeNotifier {
  CoursesProvider({required LoadCoursesUseCase loadCourses})
    : _loadCourses = loadCourses;

  final LoadCoursesUseCase _loadCourses;
  bool _disposed = false;

  bool _isLoading = true;
  Object? _error;
  List<CourseItem> _items = const [];

  bool get isLoading => _isLoading;
  Object? get error => _error;
  List<CourseItem> get items => _items;

  Future<void> load({bool force = false}) async {
    final hasData = _items.isNotEmpty;
    if (!hasData || force) {
      _isLoading = true;
      _error = null;
      _safeNotify();
    } else {
      _isLoading = false;
      _error = null;
    }

    try {
      _items = await _loadCourses();
    } catch (error) {
      if (!hasData) {
        _error = error;
      }
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
