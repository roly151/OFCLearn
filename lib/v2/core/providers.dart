import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_shell_page.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/courses/domain/course_detail.dart';
import '../features/courses/domain/course_summary.dart';
import '../features/courses/presentation/course_detail_page.dart';
import '../features/dashboard/domain/activity_feed_item.dart';
import '../features/dashboard/domain/activity_comment.dart';
import '../features/events/domain/event_detail.dart';
import '../features/events/domain/event_summary.dart';
import '../features/events/presentation/event_detail_page.dart';
import '../features/groups/domain/group_detail.dart';
import '../features/groups/domain/group_feed_item.dart';
import '../features/groups/domain/group_summary.dart';
import '../features/groups/presentation/group_detail_page.dart';
import 'dependencies.dart';

final coursesProvider = FutureProvider<List<CourseSummary>>((ref) {
  return ref.watch(coursesRepositoryProvider).fetchCourses();
});

final groupsProvider = FutureProvider<List<GroupSummary>>((ref) {
  return ref.watch(groupsRepositoryProvider).fetchGroups();
});

final courseDetailProvider =
    FutureProvider.family<CourseDetail, int>((ref, courseId) {
  return ref.watch(coursesRepositoryProvider).fetchCourseDetail(courseId);
});

final groupDetailProvider =
    FutureProvider.family<GroupDetail, int>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).fetchGroupDetail(groupId);
});

final groupFeedProvider =
    FutureProvider.family<List<GroupFeedItem>, int>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).fetchGroupFeed(groupId);
});

final previousEventsProvider = FutureProvider<List<EventSummary>>((ref) {
  return ref.watch(eventsRepositoryProvider).fetchPreviousEvents();
});

final upcomingEventsProvider = FutureProvider<List<EventSummary>>((ref) {
  return ref.watch(eventsRepositoryProvider).fetchUpcomingEvents();
});

final eventDetailProvider = FutureProvider.family<EventDetail, int>((
  ref,
  eventId,
) {
  return ref.watch(eventsRepositoryProvider).fetchEventDetail(eventId);
});

final dashboardActivityProvider = FutureProvider<List<ActivityFeedItem>>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetchActivityFeed();
});

final activityCommentsProvider =
    FutureProvider.family<List<ActivityComment>, int>((ref, activityId) {
      return ref.watch(dashboardRepositoryProvider).fetchComments(activityId);
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
      GoRoute(
        path: '/app/:tab/course/:id',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['id']!);
          return CourseDetailPage(
            tab: AppTab.fromSlug(state.pathParameters['tab']),
            courseId: courseId,
          );
        },
      ),
      GoRoute(
        path: '/app/:tab/group/:id',
        builder: (context, state) {
          final groupId = int.parse(state.pathParameters['id']!);
          return GroupDetailPage(
            tab: AppTab.fromSlug(state.pathParameters['tab']),
            groupId: groupId,
          );
        },
      ),
      GoRoute(
        path: '/app/:tab/event/:id',
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['id']!);
          return EventDetailPage(
            tab: AppTab.fromSlug(state.pathParameters['tab']),
            eventId: eventId,
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
