import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../../../core/domain/action_result.dart';
import '../../../core/providers.dart';

class CourseActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ActionResult> joinCourse(int courseId) async {
    final repository = ref.read(coursesRepositoryProvider);
    state = const AsyncLoading();
    final result =
        await AsyncValue.guard(() => repository.joinCourse(courseId));
    state = result.whenData((_) {});
    ref.invalidate(coursesProvider);
    ref.invalidate(courseDetailProvider(courseId));
    return result.requireValue;
  }
}

final courseActionControllerProvider =
    AsyncNotifierProvider<CourseActionController, void>(
  CourseActionController.new,
);
