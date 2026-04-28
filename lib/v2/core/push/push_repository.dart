import '../network/api_client.dart';

class PushRepository {
  const PushRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    await _apiClient.postMap(
      '/me/push-token',
      data: <String, dynamic>{
        'token': token,
        'platform': platform,
      },
    );
  }

  Future<void> deleteToken({
    required String token,
  }) async {
    await _apiClient.postMap(
      '/me/push-token/delete',
      data: <String, dynamic>{'token': token},
    );
  }

  Future<int> fetchBadgeCount() async {
    final response = await _apiClient.getMap('/me/badge-counts');
    final value = response['total'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
