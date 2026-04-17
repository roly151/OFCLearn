import 'api_user.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    required this.siteName,
    required this.homeUrl,
  });

  final String token;
  final ApiUser user;
  final String siteName;
  final String homeUrl;

  AuthSession copyWith({
    String? token,
    ApiUser? user,
    String? siteName,
    String? homeUrl,
  }) {
    return AuthSession(
      token: token ?? this.token,
      user: user ?? this.user,
      siteName: siteName ?? this.siteName,
      homeUrl: homeUrl ?? this.homeUrl,
    );
  }
}
