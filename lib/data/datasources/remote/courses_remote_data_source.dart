import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/course_item.dart';

class CoursesRemoteDataSource {
  const CoursesRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<CourseItem>> fetchCourses() => _fetchCatalogCourses();

  Future<List<CourseItem>> _fetchCatalogCourses() async {
    final items = <CourseItem>[];
    Uri? nextUrl = AppEndpoints.courseCatalog();
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
        data.map((e) => CourseItem.fromJson(e as Map<String, dynamic>)),
      );
      nextUrl = ApiClient.extractNextPageUri(body);
      safety += 1;
    }

    return items;
  }

  Future<CourseItem> fetchCourseDetail(int id) async {
    final response = await _apiClient.get(
      AppEndpoints.courseCatalogDetail(id),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Kurs maʼlumotlarini olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    ApiClient.ensureBodyStatusOk(
      body,
      fallbackMessage: "Kurs ma'lumotlarini olishda xatolik.",
    );
    final data = ApiClient.dataMap(body);
    return CourseItem.fromJson(data);
  }
}
