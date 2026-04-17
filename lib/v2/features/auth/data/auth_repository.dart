import '../../../core/network/api_client.dart';
import '../../../core/network/json_helpers.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/api_user.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final user = await fetchCurrentUser();
    return AuthSession(
      token: token,
      user: user,
      siteName: 'OFC Learn',
      homeUrl: '',
    );
  }

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'password': password,
      identifier.contains('@') ? 'user_email' : 'username': identifier,
    };

    final response = await _apiClient.postMap('/auth/login', data: payload);
    final token = stringValue(response['token']);
    await _tokenStorage.writeToken(token);

    return AuthSession(
      token: token,
      user: ApiUser.fromJson(response['user'] as Map<String, dynamic>),
      siteName: stringValue((response['site'] as Map<String, dynamic>)['name']),
      homeUrl:
          stringValue((response['site'] as Map<String, dynamic>)['home_url']),
    );
  }

  Future<ApiUser> fetchCurrentUser() async {
    final response = await _apiClient.getMap('/me');
    return ApiUser.fromJson(response);
  }

  Future<void> logout() => _tokenStorage.clearToken();
}
