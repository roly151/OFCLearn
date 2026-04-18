import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';
import '../../../core/providers.dart';

class ActivityActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> toggleFavorite(int activityId) async {
    final repository = ref.read(dashboardRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.toggleFavorite(activityId),
    );
    state = result.whenData((_) {});
    ref.invalidate(dashboardActivityProvider);
    ref.invalidate(activityCommentsProvider(activityId));
    return result.requireValue;
  }

  Future<ActionResult> createComment({
    required int activityId,
    required String message,
    int? parentCommentId,
  }) async {
    final repository = ref.read(dashboardRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.createComment(
        activityId: activityId,
        message: message,
        parentCommentId: parentCommentId,
      ),
    );
    state = result.whenData((_) {});
    ref.invalidate(dashboardActivityProvider);
    ref.invalidate(activityCommentsProvider(activityId));
    return result.requireValue;
  }

  Future<ActionResult> createActivityPost({
    required String content,
    List<String> imagePaths = const <String>[],
    List<String> documentPaths = const <String>[],
  }) async {
    final repository = ref.read(dashboardRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => repository.createActivityPost(
        content: content,
        imagePaths: imagePaths,
        documentPaths: documentPaths,
      ),
    );
    state = result.whenData((_) {});
    ref.invalidate(dashboardActivityProvider);
    return result.requireValue;
  }
}

final activityActionControllerProvider =
    AsyncNotifierProvider<ActivityActionController, void>(
      ActivityActionController.new,
    );
