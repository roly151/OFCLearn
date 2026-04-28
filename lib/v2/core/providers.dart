import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_shell_page.dart';
import '../app/v2_theme.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/change_password_page.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/courses/domain/course_detail.dart';
import '../features/courses/domain/course_summary.dart';
import '../features/courses/presentation/course_detail_page.dart';
import '../features/dashboard/domain/activity_comment.dart';
import '../features/dashboard/domain/activity_feed_item.dart';
import '../features/events/domain/event_detail.dart';
import '../features/events/domain/event_summary.dart';
import '../features/events/presentation/event_detail_page.dart';
import '../features/groups/domain/group_detail.dart';
import '../features/groups/domain/group_discussion.dart';
import '../features/groups/domain/group_document.dart';
import '../features/groups/domain/group_member.dart';
import '../features/groups/domain/group_notification_settings.dart';
import '../features/groups/domain/group_summary.dart';
import '../features/groups/domain/group_subgroup.dart';
import '../features/groups/presentation/group_detail_page.dart';
import '../features/library/domain/library_post.dart';
import '../features/library/presentation/library_post_detail_page.dart';
import '../features/messages/domain/message_thread.dart';
import '../features/messages/presentation/direct_message_page.dart';
import '../features/messages/presentation/message_thread_page.dart';
import '../features/messages/presentation/messages_inbox_page.dart';
import '../features/notifications/domain/user_notification_item.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/profile/domain/profile_models.dart';
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
    FutureProvider.family<List<ActivityFeedItem>, int>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).fetchGroupFeed(groupId);
});

final groupDiscussionsProvider =
    FutureProvider.family<List<GroupDiscussion>, int>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).fetchGroupDiscussions(groupId);
});

class GroupDiscussionQuery {
  const GroupDiscussionQuery({
    required this.groupId,
    required this.discussionId,
  });

  final int groupId;
  final int discussionId;

  @override
  bool operator ==(Object other) {
    return other is GroupDiscussionQuery &&
        other.groupId == groupId &&
        other.discussionId == discussionId;
  }

  @override
  int get hashCode => Object.hash(groupId, discussionId);
}

final groupDiscussionProvider =
    FutureProvider.family<GroupDiscussionDetail, GroupDiscussionQuery>((
  ref,
  query,
) {
  return ref.watch(groupsRepositoryProvider).fetchGroupDiscussion(
        groupId: query.groupId,
        discussionId: query.discussionId,
      );
});

final groupDocumentsProvider =
    FutureProvider.family<List<GroupDocument>, int>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).fetchGroupDocuments(groupId);
});

class GroupDocumentsQuery {
  const GroupDocumentsQuery({
    required this.groupId,
    required this.folderId,
  });

  final int groupId;
  final int folderId;

  @override
  bool operator ==(Object other) {
    return other is GroupDocumentsQuery &&
        other.groupId == groupId &&
        other.folderId == folderId;
  }

  @override
  int get hashCode => Object.hash(groupId, folderId);
}

final groupDocumentFolderProvider =
    FutureProvider.family<List<GroupDocument>, GroupDocumentsQuery>((
  ref,
  query,
) {
  return ref.watch(groupsRepositoryProvider).fetchGroupDocuments(
        query.groupId,
        folderId: query.folderId,
      );
});

final groupSubgroupsProvider =
    FutureProvider.family<List<GroupSubgroup>, int>((ref, groupId) {
  return ref.watch(groupsRepositoryProvider).fetchGroupSubgroups(groupId);
});

final groupNotificationSettingsProvider =
    FutureProvider.family<GroupNotificationSettings, int>((ref, groupId) {
  return ref
      .watch(groupsRepositoryProvider)
      .fetchGroupNotificationSettings(groupId);
});

class GroupMembersQuery {
  const GroupMembersQuery({
    required this.groupId,
    this.search = '',
  });

  final int groupId;
  final String search;

  @override
  bool operator ==(Object other) {
    return other is GroupMembersQuery &&
        other.groupId == groupId &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(groupId, search);
}

final groupMembersProvider =
    FutureProvider.family<List<GroupMember>, GroupMembersQuery>((ref, query) {
  return ref.watch(groupsRepositoryProvider).fetchGroupMembers(
        query.groupId,
        search: query.search,
      );
});

final previousEventsProvider = FutureProvider<List<EventSummary>>((ref) {
  return ref.watch(eventsRepositoryProvider).fetchPreviousEvents();
});

final recordedEventsProvider = FutureProvider<List<EventSummary>>((ref) {
  return ref.watch(eventsRepositoryProvider).fetchRecordedEvents();
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

final libraryPostsProvider = FutureProvider<List<LibraryPostSummary>>((ref) {
  return ref.watch(libraryRepositoryProvider).fetchPosts();
});

class LibraryPostsQuery {
  const LibraryPostsQuery({
    required this.page,
    required this.perPage,
    this.search = '',
  });

  final int page;
  final int perPage;
  final String search;

  @override
  bool operator ==(Object other) {
    return other is LibraryPostsQuery &&
        other.page == page &&
        other.perPage == perPage &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(page, perPage, search);
}

final libraryPostsPageProvider =
    FutureProvider.family<List<LibraryPostSummary>, LibraryPostsQuery>((
  ref,
  query,
) {
  return ref.watch(libraryRepositoryProvider).fetchPosts(
        search: query.search,
        page: query.page,
        perPage: query.perPage,
      );
});

final librarySearchPostsProvider =
    FutureProvider.family<List<LibraryPostSummary>, String>((ref, query) {
  return ref.watch(libraryRepositoryProvider).fetchPosts(search: query);
});

final libraryPostDetailProvider =
    FutureProvider.family<LibraryPostDetail, int>((ref, postId) {
  return ref.watch(libraryRepositoryProvider).fetchPostDetail(postId);
});

final activityCommentsProvider =
    FutureProvider.family<List<ActivityComment>, int>((ref, activityId) {
  return ref.watch(dashboardRepositoryProvider).fetchComments(activityId);
});

final messageThreadsProvider =
    FutureProvider<List<MessageThreadSummary>>((ref) {
  return ref.watch(messagesRepositoryProvider).fetchThreads();
});

final messageThreadProvider = FutureProvider.autoDispose
    .family<MessageThreadDetail, int>((ref, threadId) {
  return ref.watch(messagesRepositoryProvider).fetchThread(threadId);
});

final directMessageThreadProvider =
    FutureProvider.autoDispose.family<MessageThreadDetail, int>((ref, userId) {
  return ref.watch(messagesRepositoryProvider).fetchDirectThread(userId);
});

final notificationsProvider =
    FutureProvider.family<List<UserNotificationItem>, String>((ref, status) {
  return ref.watch(notificationsRepositoryProvider).fetchNotifications(
        status: status,
      );
});

final profileOverviewProvider = FutureProvider<ProfileOverview>((ref) {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});

final profileConnectionsProvider = FutureProvider<List<UserConnection>>((ref) {
  return ref.watch(profileRepositoryProvider).fetchConnections();
});

final profileQualificationsProvider =
    FutureProvider<QualificationsOverview>((ref) {
  return ref.watch(profileRepositoryProvider).fetchQualifications();
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/app/:tab/messages',
        builder: (context, state) => MessagesInboxPage(
          tab: AppTab.fromSlug(state.pathParameters['tab']),
        ),
      ),
      GoRoute(
        path: '/app/:tab/messages/direct/:userId',
        builder: (context, state) => DirectMessagePage(
          tab: AppTab.fromSlug(state.pathParameters['tab']),
          userId: int.parse(state.pathParameters['userId']!),
        ),
      ),
      GoRoute(
        path: '/app/:tab/messages/:id',
        builder: (context, state) => MessageThreadPage(
          tab: AppTab.fromSlug(state.pathParameters['tab']),
          threadId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/app/:tab/notifications',
        builder: (context, state) => NotificationsPage(
          tab: AppTab.fromSlug(state.pathParameters['tab']),
        ),
      ),
      GoRoute(
        path: '/app/:tab',
        builder: (context, state) {
          final tab = AppTab.fromSlug(state.pathParameters['tab']);
          return AppShellPage(
            currentTab: tab,
            groupsInitialTab: state.uri.queryParameters['groupsTab'],
            onTabSelected: (nextTab) =>
                GoRouter.of(context).go('/app/${nextTab.slug}'),
          );
        },
      ),
      GoRoute(
        path: '/app/:tab/post/:id',
        builder: (context, state) {
          final postId = int.parse(state.pathParameters['id']!);
          return LibraryPostDetailPage(
            tab: AppTab.fromSlug(state.pathParameters['tab']),
            postId: postId,
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
            source: state.uri.queryParameters['source'],
            parentGroupId: int.tryParse(
              state.uri.queryParameters['parentId'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: '/app/:tab/group/:groupId/discussion/:discussionId',
        builder: (context, state) {
          return GroupDiscussionPage(
            tab: AppTab.fromSlug(state.pathParameters['tab']),
            groupId: int.parse(state.pathParameters['groupId']!),
            discussionId: int.parse(state.pathParameters['discussionId']!),
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
      final isPublicAuthRoute =
          path == '/sign-in' || path == '/forgot-password';

      if (isLoading) {
        return path == '/loading' ? null : '/loading';
      }

      if (!isAuthenticated) {
        return isPublicAuthRoute ? null : '/sign-in';
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
      backgroundColor: V2Palette.deepBlue,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
