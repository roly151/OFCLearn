import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';

class MessageReplyController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> sendReply({
    required int threadId,
    required String message,
  }) async {
    final repository = ref.read(messagesRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.replyToThread(
        threadId: threadId,
        message: message,
      ),
    );
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<ActionResult> sendDirectMessage({
    required int userId,
    required String message,
  }) async {
    final repository = ref.read(messagesRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.sendDirectMessage(
        userId: userId,
        message: message,
      ),
    );
    state = result.whenData((_) {});
    return result.requireValue;
  }
}

final messageReplyControllerProvider =
    AsyncNotifierProvider<MessageReplyController, void>(
  MessageReplyController.new,
);

class MessageConnectionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> requestConnection({
    required int userId,
  }) async {
    final repository = ref.read(messagesRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.requestConnection(userId: userId),
    );
    state = result.whenData((_) {});
    return result.requireValue;
  }
}

final messageConnectionControllerProvider =
    AsyncNotifierProvider<MessageConnectionController, void>(
  MessageConnectionController.new,
);
