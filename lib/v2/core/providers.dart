import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_shell_page.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/courses/domain/course_summary.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/events/domain/event_summary.dart';
import '../features/groups/domain/group_summary.dart';
import 'dependencies.dart';

final coursesProvider = FutureProvider<List<CourseSummary>>((ref) {
  return ref.watch(coursesRepositoryProvider).fetchCourses();
});

final groupsProvider = FutureProvider<List<GroupSummary>>((ref) {
  return ref.watch(groupsRepositoryProvider).fetchGroups();
});

final previousEventsProvider = FutureProvider<List<EventSummary>>((ref) {
  return ref.watch(eventsRepositoryProvider).fetchPreviousEvents();
});

final upcomingEventsProvider = FutureProvider<List<EventSummary>>((ref) {
  return ref.watch(eventsRepositoryProvider).fetchUpcomingEvents();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final results = await Future.wait<dynamic>(<Future<dynamic>>[
    ref.watch(coursesRepositoryProvider).fetchCourses(),
    ref.watch(groupsRepositoryProvider).fetchGroups(),
    ref.watch(eventsRepositoryProvider).fetchPreviousEvents(),
    ref.watch(eventsRepositoryProvider).fetchUpcomingEvents(),
  ]);

  return DashboardStats(
    courses: (results[0] as List<dynamic>).length,
    groups: (results[1] as List<dynamic>).length,
    previousEvents: (results[2] as List<dynamic>).length,
    upcomingEvents: (results[3] as List<dynamic>).length,
  );
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/loading',
    routes: <RouteBase>[
      GoRoute(
        path: '/loading',
        builder: (context, state) => const _LoadingPage(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/app/:tab',
        builder: (context, state) {
          final tab = AppTab.fromSlug(state.pathParameters['tab']);
          return AppShellPage(
            currentTab: tab,
            onTabSelected: (nextTab) =>
                GoRouter.of(context).go('/app/${nextTab.slug}'),
          );
        },
      ),
    ],
    redirect: (_, state) {
      final path = state.matchedLocation;
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.asData?.value != null;

      if (isLoading) {
        return path == '/loading' ? null : '/loading';
      }

      if (!isAuthenticated) {
        return path == '/sign-in' ? null : '/sign-in';
      }

      if (path == '/sign-in' || path == '/loading') {
        return '/app/dashboard';
      }

      return null;
    },
  );
});

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
