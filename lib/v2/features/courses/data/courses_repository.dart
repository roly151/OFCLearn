import '../../../core/network/api_client.dart';
import '../domain/course_summary.dart';

class CoursesRepository {
  const CoursesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CourseSummary>> fetchCourses() async {
    final response = await _apiClient.getList('/courses');
    return response
        .whereType<Map<String, dynamic>>()
        .map(CourseSummary.fromJson)
        .toList(growable: false);
  }
}
