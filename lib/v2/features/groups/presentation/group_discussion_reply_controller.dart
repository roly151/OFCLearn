import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';
import '../../../core/providers.dart';

class GroupDiscussionReplyController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> createReply({
    required int groupId,
    required int discussionId,
    required String message,
  }) async {
    final repository = ref.read(groupsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.createGroupDiscussionReply(
        groupId: groupId,
        discussionId: discussionId,
        message: message,
      ),
    );
    state = result.whenData((_) {});
    ref.invalidate(
      groupDiscussionProvider(
        GroupDiscussionQuery(groupId: groupId, discussionId: discussionId),
      ),
    );
    ref.invalidate(groupDiscussionsProvider(groupId));
    return result.requireValue;
  }
}

final groupDiscussionReplyControllerProvider =
    AsyncNotifierProvider<GroupDiscussionReplyController, void>(
  GroupDiscussionReplyController.new,
);
