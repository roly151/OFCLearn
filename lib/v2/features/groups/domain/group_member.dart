import '../../../core/network/json_helpers.dart';

class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.lastActivity,
  });

  final int id;
  final String name;
  final String avatarUrl;
  final String role;
  final String lastActivity;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final avatarUrls = json['avatar_urls'];

    return GroupMember(
      id: intValue(json['id']),
      name: decodedTextValue(json['name']),
      avatarUrl: avatarUrls is Map<String, dynamic>
          ? stringValue(
              avatarUrls['thumb'],
              fallback: stringValue(avatarUrls['full']),
            )
          : '',
      role: decodedTextValue(json['role']),
      lastActivity: stringValue(json['last_activity']),
    );
  }
}
