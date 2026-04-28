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
    final value = stringValue(json['value']);
    final label = stringValue(json['label']);
    final description = stringValue(json['description']);

    return GroupNotificationOption(
      value: value,
      label: label,
      description: description.isEmpty
          ? _defaultNotificationDescription(value: value, label: label)
          : description,
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

String _defaultNotificationDescription({
  required String value,
  required String label,
}) {
  switch (value) {
    case 'no':
      return 'I will read this group on the web';
    case 'sum':
      return 'Get a summary of topics each week';
    case 'dig':
      return "Get the day's activity bundled into one email";
    case 'sub':
      return 'Send new topics as they arrive (but no replies)';
    case 'supersub':
      return 'Send all group activity as it arrives';
  }

  switch (label.trim().toLowerCase()) {
    case 'no email':
      return 'I will read this group on the web';
    case 'weekly summary':
      return 'Get a summary of topics each week';
    case 'daily digest':
      return "Get the day's activity bundled into one email";
    case 'new topics':
      return 'Send new topics as they arrive (but no replies)';
    case 'all email':
      return 'Send all group activity as it arrives';
    default:
      return '';
  }
}
