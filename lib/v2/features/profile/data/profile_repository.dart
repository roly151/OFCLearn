import '../../../core/domain/action_result.dart';
import '../../../core/network/api_client.dart';
import '../domain/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfileOverview> fetchProfile() async {
    final response = await _apiClient.getMap('/me/profile');
    return ProfileOverview.fromJson(response);
  }

  Future<ActionResult> updateProfileFields(Map<int, Object> fields) async {
    final response = await _apiClient.postMap(
      '/me/profile',
      data: <String, dynamic>{
        'fields': fields.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      },
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Profile updated successfully.',
    );
  }

  Future<List<UserConnection>> fetchConnections() async {
    final response = await _apiClient.getList('/connections');
    return response
        .whereType<Map<String, dynamic>>()
        .map(UserConnection.fromJson)
        .toList(growable: false);
  }

  Future<QualificationsOverview> fetchQualifications() async {
    final response = await _apiClient.getMap('/me/qualifications');
    return QualificationsOverview.fromJson(response);
  }
}
