import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/core/dependencies.dart';
import 'package:ofc_learn_v2/v2/core/config/app_config.dart';
import 'package:ofc_learn_v2/v2/features/auth/domain/api_user.dart';
import 'package:ofc_learn_v2/v2/features/auth/domain/auth_session.dart';
import 'package:ofc_learn_v2/v2/features/auth/presentation/auth_controller.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/domain/activity_attachment.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/domain/activity_feed_item.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/presentation/activity_action_controller.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/presentation/dashboard_activity_feed_controller.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/presentation/dashboard_page.dart';

void main() {
  testWidgets('dashboard supports pull to refresh for the activity feed', (
    WidgetTester tester,
  ) async {
    var fetchCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _TestAuthController()),
          activityActionControllerProvider
              .overrideWith(() => _TestActivityActionController()),
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          dashboardActivityFeedControllerProvider.overrideWith(
            () => _TestDashboardActivityFeedController(
              onFetch: () {
                fetchCount += 1;
                return DashboardActivityFeedState(
                  items: <ActivityFeedItem>[_sampleActivity()],
                  hasMore: false,
                );
              },
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DashboardPage())),
      ),
    );

    await tester.pumpAndSettle();

    expect(fetchCount, 1);

    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fetchCount, 2);
  });

  testWidgets('dashboard does not refresh the activity feed on a short resume',
      (
    WidgetTester tester,
  ) async {
    var fetchCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _TestAuthController()),
          activityActionControllerProvider
              .overrideWith(() => _TestActivityActionController()),
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          dashboardNowProvider.overrideWith((ref) {
            var current = DateTime(2026, 4, 21, 10, 0);
            return () => current;
          }),
          dashboardActivityFeedControllerProvider.overrideWith(
            () => _TestDashboardActivityFeedController(
              onFetch: () {
                fetchCount += 1;
                return DashboardActivityFeedState(
                  items: <ActivityFeedItem>[_sampleActivity()],
                  hasMore: false,
                );
              },
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DashboardPage())),
      ),
    );

    await tester.pumpAndSettle();

    expect(fetchCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fetchCount, 1);
  });

  testWidgets('dashboard refreshes the activity feed after a long idle resume',
      (
    WidgetTester tester,
  ) async {
    var fetchCount = 0;
    var current = DateTime(2026, 4, 21, 10, 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _TestAuthController()),
          activityActionControllerProvider
              .overrideWith(() => _TestActivityActionController()),
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          dashboardNowProvider.overrideWith((ref) => () => current),
          dashboardActivityFeedControllerProvider.overrideWith(
            () => _TestDashboardActivityFeedController(
              onFetch: () {
                fetchCount += 1;
                return DashboardActivityFeedState(
                  items: <ActivityFeedItem>[_sampleActivity()],
                  hasMore: false,
                );
              },
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DashboardPage())),
      ),
    );

    await tester.pumpAndSettle();

    expect(fetchCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    current = current.add(const Duration(minutes: 6));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fetchCount, 2);
  });

  testWidgets(
    'dashboard renders previewable document attachments as image previews',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => _TestAuthController()),
            activityActionControllerProvider
                .overrideWith(() => _TestActivityActionController()),
            appConfigProvider.overrideWith(
              (ref) => const AppConfig(
                baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
                appName: 'OFC Learn v2',
                publicBaseUrl: 'https://example.test',
              ),
            ),
            dashboardActivityFeedControllerProvider.overrideWith(
              () => _TestDashboardActivityFeedController(
                onFetch: () => DashboardActivityFeedState(
                  items: <ActivityFeedItem>[
                    _sampleActivity(
                      documentItems: <ActivityDocumentAttachment>[
                        ActivityDocumentAttachment.fromJson(<String, dynamic>{
                          'id': 201,
                          'attachment_id': 301,
                          'title': 'Training photo',
                          'file_name': 'training-photo.jpg',
                          'url': 'https://cdn.example.test/training-photo.jpg',
                          'preview_url':
                              'https://cdn.example.test/training-photo-medium.jpg',
                          'extension': 'jpg',
                          'mime_type': 'image/jpeg',
                        }),
                      ],
                    ),
                  ],
                  hasMore: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: DashboardPage())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('training-photo.jpg'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    },
  );
}

class _TestAuthController extends AuthController {
  @override
  Future<AuthSession?> build() async => AuthSession(
        token: 'test-token',
        user: const ApiUser(
          id: 1,
          username: 'coach',
          email: 'coach@example.com',
          displayName: 'Coach Example',
          firstName: 'Coach',
          lastName: 'Example',
          nickname: 'coach',
          country: 'Australia',
          gender: 'Other',
          dateOfBirth: '',
          regionalOrganisation: 'OFC',
          avatarUrl: '',
          avatarThumbUrl: '',
          coverUrl: '',
        ),
        siteName: 'OFC Learn',
        homeUrl: 'https://example.test',
      );
}

class _TestActivityActionController extends ActivityActionController {
  @override
  Future<void> build() async {}
}

class _TestDashboardActivityFeedController
    extends DashboardActivityFeedController {
  _TestDashboardActivityFeedController({
    required DashboardActivityFeedState Function() onFetch,
  }) : _onFetch = onFetch;

  final DashboardActivityFeedState Function() _onFetch;

  @override
  Future<DashboardActivityFeedState> build() async => _onFetch();

  @override
  Future<void> refresh() async {
    state = AsyncData(_onFetch());
  }
}

ActivityFeedItem _sampleActivity({
  List<ActivityImageAttachment> mediaItems = const <ActivityImageAttachment>[],
  List<ActivityDocumentAttachment> documentItems =
      const <ActivityDocumentAttachment>[],
}) {
  return ActivityFeedItem(
    id: 101,
    userId: 1,
    sourceBlogId: 1,
    name: 'Coach Example',
    action: 'Coach Example posted an update',
    component: 'activity',
    contentRendered: '<p>Hello team</p>',
    contentStripped: 'Hello team',
    date: '2026-04-20',
    link: 'https://example.test/activity/101',
    primaryItemId: 0,
    secondaryItemId: 0,
    status: 'published',
    type: 'activity_update',
    favorited: false,
    favoriteCount: 0,
    commentCount: 0,
    canEdit: false,
    canDelete: false,
    privacy: 'public',
    groupId: 0,
    groupName: '',
    groupAvatar: '',
    avatarFullUrl: '',
    avatarThumbUrl: '',
    preview: null,
    mediaItems: mediaItems,
    documentItems: documentItems,
  );
}
