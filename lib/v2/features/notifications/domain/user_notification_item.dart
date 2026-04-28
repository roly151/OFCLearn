import '../../../core/network/json_helpers.dart';

class UserNotificationItem {
  const UserNotificationItem({
    required this.id,
    required this.isNew,
    required this.descriptionHtml,
    required this.descriptionText,
    required this.link,
    required this.component,
    required this.action,
    required this.avatarThumbUrl,
    required this.date,
  });

  final int id;
  final bool isNew;
  final String descriptionHtml;
  final String descriptionText;
  final String link;
  final String component;
  final String action;
  final String avatarThumbUrl;
  final DateTime? date;

  factory UserNotificationItem.fromJson(Map<String, dynamic> json) {
    final description = json['description'] is Map<String, dynamic>
        ? json['description'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final avatars = json['avatar_urls'] is Map<String, dynamic>
        ? json['avatar_urls'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return UserNotificationItem(
      id: intValue(json['id']),
      isNew: boolValue(json['is_new'], fallback: false),
      descriptionHtml: stringValue(description['rendered']),
      descriptionText: plainTextValue(description['rendered']),
      link: stringValue(json['link']),
      component: stringValue(json['component']),
      action: stringValue(json['action']),
      avatarThumbUrl: stringValue(avatars['thumb']),
      date: DateTime.tryParse(stringValue(json['date'])),
    );
  }
}
