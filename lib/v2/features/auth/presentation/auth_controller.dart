import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../domain/auth_session.dart';

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    try {
      return await repository.restoreSession();
    } catch (_) {
      await repository.logout();
      return null;
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.login(identifier: identifier, password: password),
    );
  }

  Future<void> refreshProfile() async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    final user = await repository.fetchCurrentUser();
    state = AsyncData(current.copyWith(user: user));
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
