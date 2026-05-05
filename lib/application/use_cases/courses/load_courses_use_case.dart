import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/repositories/courses_repository.dart';

class LoadCoursesUseCase {
  const LoadCoursesUseCase({required CoursesRepository coursesRepository})
    : _coursesRepository = coursesRepository;

  final CoursesRepository _coursesRepository;

  Future<List<CourseItem>> call() {
    return _coursesRepository.fetchCourses();
  }
}
