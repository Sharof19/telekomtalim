import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/models/my_course_item.dart';

class MyCoursesRemoteDataSource {
  const MyCoursesRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MyCourseItem>> fetchMyCourses() async {
    final items = <MyCourseItem>[];
    Uri? nextUrl = AppEndpoints.myTrainingCourses();
    var safety = 0;

    while (nextUrl != null && safety < 10) {
      final response = await _apiClient.get(nextUrl, authorized: true);
      ApiClient.ensureSuccess(
        response,
        fallbackMessage: 'Kurslarni olishda xatolik.',
      );

      final body = ApiClient.decodeObjectBody(response.body);
      ApiClient.ensureBodyStatusOk(
        body,
        fallbackMessage: 'Kurslarni olishda xatolik.',
      );
      final data = ApiClient.dataList(body);
      items.addAll(
        data.whereType<Map<String, dynamic>>().map(MyCourseItem.fromJson),
      );
      nextUrl = ApiClient.extractNextPageUri(body);
      safety += 1;
    }

    return items;
  }

  Future<CourseItem> fetchCourseDetail(int id) async {
    final response = await _apiClient.get(
      AppEndpoints.myTrainingCourseDetail(id),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: "Kurs ma'lumotlarini olishda xatolik.",
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = ApiClient.dataMap(body);
    return CourseItem.fromJson(data);
  }
}
