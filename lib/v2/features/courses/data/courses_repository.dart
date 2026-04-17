import '../../../core/network/api_client.dart';
import '../../../core/domain/action_result.dart';
import '../domain/course_detail.dart';
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

  Future<CourseDetail> fetchCourseDetail(int courseId) async {
    final response = await _apiClient.getMap('/courses/$courseId');
    return CourseDetail.fromJson(response);
  }

  Future<ActionResult> joinCourse(int courseId) async {
    final response = await _apiClient.postMap('/courses/$courseId/join');
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Course joined successfully.',
    );
  }
}
