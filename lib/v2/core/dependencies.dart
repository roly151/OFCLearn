import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/courses/data/courses_repository.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/events/data/events_repository.dart';
import '../features/groups/data/groups_repository.dart';
import '../features/library/data/library_repository.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(flutterSecureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(
    baseUrl: config.baseUrl,
    tokenStorage: storage,
    defaultHeaders: config.defaultHeaders,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository(ref.watch(apiClientProvider));
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(
    ref.watch(apiClientProvider),
    wpJsonBaseUrl: ref.watch(appConfigProvider).wpJsonBaseUrl,
  );
});

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(apiClientProvider));
});
