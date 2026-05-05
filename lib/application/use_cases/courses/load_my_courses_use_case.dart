import 'package:uztelecom/data/models/my_course_item.dart';
import 'package:uztelecom/data/repositories/my_courses_repository.dart';

class LoadMyCoursesUseCase {
  const LoadMyCoursesUseCase({required MyCoursesRepository myCoursesRepository})
    : _myCoursesRepository = myCoursesRepository;

  final MyCoursesRepository _myCoursesRepository;

  Future<List<MyCourseItem>> call() {
    return _myCoursesRepository.fetchMyCourses();
  }
}
