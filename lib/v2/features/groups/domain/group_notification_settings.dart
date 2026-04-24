import '../../../core/network/json_helpers.dart';

class GroupNotificationOption {
  const GroupNotificationOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;

  factory GroupNotificationOption.fromJson(Map<String, dynamic> json) {
    return GroupNotificationOption(
      value: stringValue(json['value']),
      label: stringValue(json['label']),
      description: stringValue(json['description']),
    );
  }
}

class GroupNotificationSettings {
  const GroupNotificationSettings({
    required this.groupId,
    required this.title,
    required this.prompt,
    required this.currentStatus,
    required this.currentLabel,
    required this.options,
  });

  final int groupId;
  final String title;
  final String prompt;
  final String currentStatus;
  final String currentLabel;
  final List<GroupNotificationOption> options;

  factory GroupNotificationSettings.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions
            .whereType<Map<String, dynamic>>()
            .map(GroupNotificationOption.fromJson)
            .toList(growable: false)
        : const <GroupNotificationOption>[];

    return GroupNotificationSettings(
      groupId: intValue(json['group_id']),
      title: stringValue(
        json['title'],
        fallback: 'Email Subscription Options',
      ),
      prompt: stringValue(
        json['prompt'],
        fallback: 'How do you want to read this group?',
      ),
      currentStatus: stringValue(json['current_status'], fallback: 'no'),
      currentLabel: stringValue(json['current_label']),
      options: options,
    );
  }
}
