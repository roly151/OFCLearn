import '../../../core/network/json_helpers.dart';

class MessageParticipant {
  const MessageParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.avatarThumbUrl,
  });

  final int id;
  final String name;
  final String avatarUrl;
  final String avatarThumbUrl;

  factory MessageParticipant.fromJson(Map<String, dynamic> json) {
    final avatars = json['user_avatars'] is Map<String, dynamic>
        ? json['user_avatars'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return MessageParticipant(
      id: intValue(json['user_id']),
      name: stringValue(json['name']),
      avatarUrl: stringValue(avatars['full']),
      avatarThumbUrl: stringValue(avatars['thumb']),
    );
  }
}

class ThreadMessage {
  const ThreadMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.senderAvatarThumbUrl,
    required this.messageHtml,
    required this.messageText,
    required this.sentAt,
    required this.displayDate,
    required this.isMine,
  });

  final int id;
  final int threadId;
  final int senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String senderAvatarThumbUrl;
  final String messageHtml;
  final String messageText;
  final DateTime? sentAt;
  final String displayDate;
  final bool isMine;

  factory ThreadMessage.fromJson(Map<String, dynamic> json,
      {required int currentUserId}) {
    final senderData = json['sender_data'] is Map<String, dynamic>
        ? json['sender_data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final avatars = senderData['user_avatars'] is Map<String, dynamic>
        ? senderData['user_avatars'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final message = json['message'] is Map<String, dynamic>
        ? json['message'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final senderId = intValue(json['sender_id']);

    return ThreadMessage(
      id: intValue(json['id']),
      threadId: intValue(json['thread_id']),
      senderId: senderId,
      senderName: stringValue(senderData['sender_name']),
      senderAvatarUrl: stringValue(avatars['full']),
      senderAvatarThumbUrl: stringValue(avatars['thumb']),
      messageHtml: stringValue(message['rendered']),
      messageText: plainTextValue(message['rendered']),
      sentAt: DateTime.tryParse(stringValue(json['date_sent'])),
      displayDate: stringValue(json['display_date']),
      isMine: senderId == currentUserId,
    );
  }
}

class MessageThreadSummary {
  const MessageThreadSummary({
    required this.id,
    required this.subject,
    required this.senderName,
    required this.updatedAt,
    required this.unreadCount,
    required this.avatarThumbUrl,
    required this.isGroupThread,
  });

  final int id;
  final String subject;
  final String senderName;
  final DateTime? updatedAt;
  final int unreadCount;
  final String avatarThumbUrl;
  final bool isGroupThread;

  factory MessageThreadSummary.fromJson(Map<String, dynamic> json) {
    final currentUserId = intValue(json['current_user']);
    final recipients = _participantsFromJson(json);
    final subject = json['subject'] is Map<String, dynamic>
        ? json['subject'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final avatars = (json['avatar'] is List)
        ? (json['avatar'] as List)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false)
        : const <Map<String, dynamic>>[];
    final isGroupThread = boolValue(json['is_group_thread']);
    final groupName = stringValue(json['group_name']);

    return MessageThreadSummary(
      id: intValue(json['id']),
      subject: _threadSubject(
        subject: plainTextValue(subject['rendered']),
        isGroupThread: isGroupThread,
        groupName: groupName,
      ),
      senderName: _summarySenderName(
        explicitSenderName: stringValue(json['last_sender_name']),
        currentUserId: currentUserId,
        recipients: recipients,
      ),
      updatedAt: DateTime.tryParse(stringValue(json['date'])),
      unreadCount: intValue(json['unread_count']),
      avatarThumbUrl: avatars.isNotEmpty
          ? stringValue(avatars.first['thumb'])
          : (recipients.isNotEmpty ? recipients.first.avatarThumbUrl : ''),
      isGroupThread: isGroupThread,
    );
  }
}

class MessageThreadDetail {
  const MessageThreadDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.subject,
    required this.currentUserId,
    required this.canSendMessage,
    required this.connectionRequired,
    required this.connectionStatus,
    required this.connectionRequestUserId,
    required this.connectionRequestName,
    required this.connectionRequestAvatarUrl,
    required this.unreadCount,
    required this.participants,
    required this.messages,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String subtitle;
  final String subject;
  final int currentUserId;
  final bool canSendMessage;
  final bool connectionRequired;
  final String connectionStatus;
  final int connectionRequestUserId;
  final String connectionRequestName;
  final String connectionRequestAvatarUrl;
  final int unreadCount;
  final List<MessageParticipant> participants;
  final List<ThreadMessage> messages;
  final DateTime? updatedAt;

  factory MessageThreadDetail.fromJson(Map<String, dynamic> json) {
    final currentUserId = intValue(json['current_user']);
    final participants = _participantsFromJson(json);
    final recipientNames = participants
        .where((participant) => participant.id != currentUserId)
        .map((participant) => participant.name)
        .where((name) => name.trim().isNotEmpty)
        .toList(growable: false);
    final threadMessages = (json['messages'] is List)
        ? (json['messages'] as List)
            .whereType<Map<String, dynamic>>()
            .map((message) => ThreadMessage.fromJson(
                  message,
                  currentUserId: currentUserId,
                ))
            .toList(growable: false)
        : const <ThreadMessage>[];
    final isGroupThread = boolValue(json['is_group_thread']);
    final groupName = stringValue(json['group_name']);
    final subject = json['subject'] is Map<String, dynamic>
        ? json['subject'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return MessageThreadDetail(
      id: intValue(json['id']),
      title: _threadTitle(
        isGroupThread: isGroupThread,
        groupName: groupName,
        recipientNames: recipientNames,
      ),
      subtitle: recipientNames.isEmpty
          ? stringValue(json['group_message_type'], fallback: 'Conversation')
          : recipientNames.join(', '),
      subject: plainTextValue(subject['rendered']).trim(),
      currentUserId: currentUserId,
      canSendMessage: boolValue(json['can_send_message'], fallback: true),
      connectionRequired: boolValue(json['connection_required']),
      connectionStatus: stringValue(json['connection_status']),
      connectionRequestUserId: intValue(json['connection_request_user']),
      connectionRequestName: decodedTextValue(json['connection_request_name']),
      connectionRequestAvatarUrl: stringValue(
        json['connection_request_avatar'],
      ),
      unreadCount: intValue(json['unread_count']),
      participants: participants,
      messages: threadMessages,
      updatedAt: DateTime.tryParse(stringValue(json['date'])),
    );
  }
}

List<MessageParticipant> _participantsFromJson(Map<String, dynamic> json) {
  final recipients = json['recipients'] is Map<String, dynamic>
      ? json['recipients'] as Map<String, dynamic>
      : const <String, dynamic>{};

  return recipients.values
      .whereType<Map<String, dynamic>>()
      .map(MessageParticipant.fromJson)
      .toList(growable: false);
}

String _threadTitle({
  required bool isGroupThread,
  required String groupName,
  required List<String> recipientNames,
}) {
  if (isGroupThread && groupName.trim().isNotEmpty) {
    return groupName;
  }

  if (recipientNames.isNotEmpty) {
    return recipientNames.join(', ');
  }

  return 'Conversation';
}

String _threadSubject({
  required String subject,
  required bool isGroupThread,
  required String groupName,
}) {
  if (subject.trim().isNotEmpty) {
    return subject.trim();
  }

  if (isGroupThread && groupName.trim().isNotEmpty) {
    return groupName.trim();
  }

  return 'Conversation';
}

String _summarySenderName({
  required String explicitSenderName,
  required int currentUserId,
  required List<MessageParticipant> recipients,
}) {
  if (explicitSenderName.trim().isNotEmpty) {
    return explicitSenderName.trim();
  }

  for (final participant in recipients) {
    if (participant.id != currentUserId && participant.name.trim().isNotEmpty) {
      return participant.name.trim();
    }
  }

  return 'Unknown sender';
}
