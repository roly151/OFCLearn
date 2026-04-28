import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_notification_settings.dart';

void main() {
  test('backfills default notification option descriptions when API omits them',
      () {
    final settings = GroupNotificationSettings.fromJson(const <String, dynamic>{
      'group_id': 4,
      'title': 'Email Subscription Options',
      'prompt': 'How do you want to read this group?',
      'current_status': 'dig',
      'current_label': 'Daily Digest',
      'options': <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'sub',
          'label': 'New Topics',
          'description': '',
        },
        <String, dynamic>{
          'value': 'supersub',
          'label': 'All Email',
          'description': '',
        },
      ],
    });

    expect(
      settings.options[0].description,
      'Send new topics as they arrive (but no replies)',
    );
    expect(
      settings.options[1].description,
      'Send all group activity as it arrives',
    );
  });
}
