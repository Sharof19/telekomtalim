import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/repositories/courses_repository.dart';
import 'package:uztelecom/data/repositories/my_courses_repository.dart';

class LoadCourseDetailUseCase {
  const LoadCourseDetailUseCase({
    required CoursesRepository coursesRepository,
    required MyCoursesRepository myCoursesRepository,
  }) : _coursesRepository = coursesRepository,
       _myCoursesRepository = myCoursesRepository;

  final CoursesRepository _coursesRepository;
  final MyCoursesRepository _myCoursesRepository;

  Future<CourseItem> call({
    required int courseId,
    required bool useMyCoursesDetailApi,
  }) {
    if (useMyCoursesDetailApi) {
      return _myCoursesRepository.fetchCourseDetail(courseId);
    }
    return _coursesRepository.fetchCourseDetail(courseId);
  }
}
