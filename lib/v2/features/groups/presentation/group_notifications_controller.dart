import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';

class GroupNotificationsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> saveGroupNotifications({
    required int groupId,
    required String subscription,
  }) async {
    final repository = ref.read(groupsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.updateGroupNotificationSettings(
        groupId: groupId,
        subscription: subscription,
      ),
    );
    state = result.whenData((_) {});
    return result.requireValue;
  }
}

final groupNotificationsControllerProvider =
    AsyncNotifierProvider<GroupNotificationsController, void>(
  GroupNotificationsController.new,
);
