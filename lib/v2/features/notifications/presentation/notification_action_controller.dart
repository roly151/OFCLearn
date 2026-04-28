import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';

class NotificationActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> markRead(int notificationId) async {
    final repository = ref.read(notificationsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.markRead(notificationId),
    );
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<ActionResult> dismiss(int notificationId) async {
    final repository = ref.read(notificationsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.dismiss(notificationId),
    );
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<ActionResult> markAllRead() async {
    final repository = ref.read(notificationsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(repository.markAllRead);
    state = result.whenData((_) {});
    return result.requireValue;
  }
}

final notificationActionControllerProvider =
    AsyncNotifierProvider<NotificationActionController, void>(
  NotificationActionController.new,
);
