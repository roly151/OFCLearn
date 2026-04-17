import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';
import '../../../core/providers.dart';

class GroupJoinController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> joinGroup(int groupId) async {
    final repository = ref.read(groupsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => repository.joinGroup(groupId));
    state = result.whenData((_) {});
    ref.invalidate(groupsProvider);
    ref.invalidate(groupDetailProvider(groupId));
    ref.invalidate(groupFeedProvider(groupId));
    return result.requireValue;
  }
}

final groupJoinControllerProvider =
    AsyncNotifierProvider<GroupJoinController, void>(GroupJoinController.new);
