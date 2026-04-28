import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/features/notifications/domain/user_notification_item.dart';

void main() {
  test('notification item keeps rendered website content and read state', () {
    final item = UserNotificationItem.fromJson(
      <String, dynamic>{
        'id': 88,
        'is_new': true,
        'component': 'messages',
        'action': 'new_message',
        'date': '2026-04-28T10:00:00',
        'link': 'https://ofclearn.com/members/coach/messages/view/88/',
        'avatar_urls': <String, dynamic>{
          'thumb': 'https://example.test/avatar-thumb.jpg',
        },
        'description': <String, dynamic>{
          'rendered':
              '<a href="https://ofclearn.com">Lindsey Robinson</a> sent you a message.',
        },
      },
    );

    expect(item.id, 88);
    expect(item.isNew, isTrue);
    expect(item.component, 'messages');
    expect(item.action, 'new_message');
    expect(item.descriptionText, 'Lindsey Robinson sent you a message.');
    expect(item.link, 'https://ofclearn.com/members/coach/messages/view/88/');
    expect(item.avatarThumbUrl, 'https://example.test/avatar-thumb.jpg');
  });
}
