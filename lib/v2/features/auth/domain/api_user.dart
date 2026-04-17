import '../../../core/network/json_helpers.dart';

class ApiUser {
  const ApiUser({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.country,
    required this.gender,
    required this.dateOfBirth,
    required this.regionalOrganisation,
    required this.avatarUrl,
    required this.avatarThumbUrl,
    required this.coverUrl,
  });

  final int id;
  final String username;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final String nickname;
  final String country;
  final String gender;
  final String dateOfBirth;
  final String regionalOrganisation;
  final String avatarUrl;
  final String avatarThumbUrl;
  final String coverUrl;

  String get initials {
    final source = displayName.trim().isNotEmpty ? displayName : username;
    final parts = source.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: intValue(json['id']),
      username: stringValue(json['username']),
      email: stringValue(json['email']),
      displayName: stringValue(json['display_name']),
      firstName: stringValue(json['first_name']),
      lastName: stringValue(json['last_name']),
      nickname: stringValue(json['nickname']),
      country: stringValue(json['ofc_country']),
      gender: stringValue(json['ofc_gender']),
      dateOfBirth: stringValue(json['ofc_date_of_birth']),
      regionalOrganisation: stringValue(json['ofc_regional_organisation']),
      avatarUrl: stringValue(json['avatar_url']),
      avatarThumbUrl: stringValue(json['avatar_thumb_url']),
      coverUrl: stringValue(json['cover_url']),
    );
  }
}
