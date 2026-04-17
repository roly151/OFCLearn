import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';
import '../../../core/providers.dart';

class GroupPostController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> createPost({
    required int groupId,
    required String content,
  }) async {
    final repository = ref.read(groupsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.createGroupPost(groupId: groupId, content: content),
    );
    state = result.whenData((_) {});
    ref.invalidate(groupFeedProvider(groupId));
    ref.invalidate(groupDetailProvider(groupId));
    ref.invalidate(groupsProvider);
    return result.requireValue;
  }
}

final groupPostControllerProvider =
    AsyncNotifierProvider<GroupPostController, void>(
  GroupPostController.new,
);
