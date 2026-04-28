import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/features/messages/domain/message_thread.dart';

void main() {
  test('message thread summary derives sender, subject, and unread count', () {
    final summary = MessageThreadSummary.fromJson(
      <String, dynamic>{
        'id': 42,
        'current_user': 7,
        'date': '2026-04-28T09:55:00',
        'unread_count': 2,
        'is_group_thread': false,
        'subject': <String, dynamic>{
          'rendered': '<p>COMET APPOINTMENT - NOTIFICATIONS</p>',
        },
        'last_sender_name': 'Lindsey Robinson',
        'avatar': <Map<String, dynamic>>[
          <String, dynamic>{
            'thumb': 'https://example.test/avatar-thumb.jpg',
          },
        ],
        'recipients': <String, dynamic>{
          '7': <String, dynamic>{
            'user_id': 7,
            'name': 'Current User',
            'user_avatars': <String, dynamic>{'thumb': ''},
          },
          '9': <String, dynamic>{
            'user_id': 9,
            'name': 'Lindsey Robinson',
            'user_avatars': <String, dynamic>{'thumb': ''},
          },
        },
      },
    );

    expect(summary.id, 42);
    expect(summary.senderName, 'Lindsey Robinson');
    expect(summary.subject, 'COMET APPOINTMENT - NOTIFICATIONS');
    expect(summary.unreadCount, 2);
    expect(summary.avatarThumbUrl, 'https://example.test/avatar-thumb.jpg');
  });

  test('message thread detail maps participants and reply messages', () {
    final detail = MessageThreadDetail.fromJson(
      <String, dynamic>{
        'id': 42,
        'current_user': 7,
        'can_send_message': true,
        'unread_count': 0,
        'is_group_thread': true,
        'group_name': 'NZF National League Championship Panel Officials',
        'group_message_type': 'open',
        'date': '2026-04-28T09:55:00',
        'recipients': <String, dynamic>{
          '7': <String, dynamic>{
            'user_id': 7,
            'name': 'Current User',
            'user_avatars': <String, dynamic>{'thumb': '', 'full': ''},
          },
          '9': <String, dynamic>{
            'user_id': 9,
            'name': 'Lindsey Robinson',
            'user_avatars': <String, dynamic>{
              'thumb': 'https://example.test/lindsey-thumb.jpg',
              'full': 'https://example.test/lindsey.jpg',
            },
          },
        },
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 501,
            'thread_id': 42,
            'sender_id': 9,
            'date_sent': '2026-04-28T09:50:00',
            'display_date': '5 minutes ago',
            'message': <String, dynamic>{
              'rendered': '<p>Kia Ora</p>',
            },
            'sender_data': <String, dynamic>{
              'sender_name': 'Lindsey Robinson',
              'user_avatars': <String, dynamic>{
                'thumb': 'https://example.test/lindsey-thumb.jpg',
                'full': 'https://example.test/lindsey.jpg',
              },
            },
          },
        ],
      },
    );

    expect(detail.title, 'NZF National League Championship Panel Officials');
    expect(detail.canSendMessage, isTrue);
    expect(detail.participants, hasLength(2));
    expect(detail.messages.single.senderName, 'Lindsey Robinson');
    expect(detail.messages.single.messageText, 'Kia Ora');
    expect(detail.messages.single.isMine, isFalse);
  });

  test('message thread detail maps blocked connection state', () {
    final detail = MessageThreadDetail.fromJson(
      <String, dynamic>{
        'id': 77,
        'current_user': 7,
        'can_send_message': false,
        'connection_required': true,
        'connection_status': 'not_friends',
        'connection_request_user': 9,
        'connection_request_name': 'Lindsey Robinson',
        'connection_request_avatar': 'https://example.test/lindsey-thumb.jpg',
        'recipients': <String, dynamic>{
          '7': <String, dynamic>{
            'user_id': 7,
            'name': 'Current User',
            'user_avatars': <String, dynamic>{'thumb': '', 'full': ''},
          },
          '9': <String, dynamic>{
            'user_id': 9,
            'name': 'Lindsey Robinson',
            'user_avatars': <String, dynamic>{'thumb': '', 'full': ''},
          },
        },
        'messages': const <Map<String, dynamic>>[],
      },
    );

    expect(detail.canSendMessage, isFalse);
    expect(detail.connectionRequired, isTrue);
    expect(detail.connectionStatus, 'not_friends');
    expect(detail.connectionRequestUserId, 9);
    expect(detail.connectionRequestName, 'Lindsey Robinson');
    expect(
      detail.connectionRequestAvatarUrl,
      'https://example.test/lindsey-thumb.jpg',
    );
  });
}
