import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/message_thread.dart';

class MessageReadMarker {
  const MessageReadMarker({
    required this.updatedAt,
    required this.unreadCount,
  });

  final DateTime? updatedAt;
  final int unreadCount;
}

class MessageReadStateController extends Notifier<Map<int, MessageReadMarker>> {
  @override
  Map<int, MessageReadMarker> build() => const <int, MessageReadMarker>{};

  void markServerConfirmedRead(MessageThreadSummary thread) {
    if (thread.unreadCount <= 0) {
      return;
    }

    state = <int, MessageReadMarker>{
      ...state,
      thread.id: MessageReadMarker(
        updatedAt: thread.updatedAt,
        unreadCount: thread.unreadCount,
      ),
    };
  }
}

final messageReadStateProvider =
    NotifierProvider<MessageReadStateController, Map<int, MessageReadMarker>>(
  MessageReadStateController.new,
);

int visibleUnreadCountForThread(
  MessageThreadSummary thread,
  Map<int, MessageReadMarker> readMarkers,
) {
  final marker = readMarkers[thread.id];
  if (marker != null &&
      marker.updatedAt == thread.updatedAt &&
      thread.unreadCount <= marker.unreadCount) {
    return 0;
  }

  return thread.unreadCount;
}
