import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/app/app_shell_page.dart';
import 'package:ofc_learn_v2/v2/core/config/app_config.dart';
import 'package:ofc_learn_v2/v2/core/dependencies.dart';
import 'package:ofc_learn_v2/v2/core/domain/action_result.dart';
import 'package:ofc_learn_v2/v2/core/providers.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/domain/activity_feed_item.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_detail.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_discussion.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_document.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_notification_settings.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_subgroup.dart';
import 'package:ofc_learn_v2/v2/features/groups/presentation/group_discussion_reply_controller.dart';
import 'package:ofc_learn_v2/v2/features/groups/presentation/group_detail_page.dart';
import 'package:ofc_learn_v2/v2/features/groups/presentation/group_join_controller.dart';
import 'package:ofc_learn_v2/v2/features/groups/presentation/group_notifications_controller.dart';
import 'package:ofc_learn_v2/v2/features/groups/presentation/group_post_controller.dart';

void main() {
  testWidgets(
      'group detail page exposes feed, discussions, docs, groups, and alerts tabs',
      (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          groupDetailProvider.overrideWith(
            (ref, groupId) async => const GroupDetail(
              id: 4,
              type: 'coaching',
              title: 'Youth Coaching',
              content: '<p>A group for youth coaches.</p>',
              status: 'Public',
              time: 'Active today',
              organizerImage: '',
              organizer: 'Sean Douglas',
              isMember: true,
              imageLink: '',
              forumId: 49296,
            ),
          ),
          groupFeedProvider.overrideWith(
            (ref, groupId) async => const <ActivityFeedItem>[],
          ),
          groupDiscussionsProvider.overrideWith(
            (ref, groupId) async => const <GroupDiscussion>[
              GroupDiscussion(
                id: 49297,
                userName: 'Sean Douglas',
                userImage: '',
                title: 'Welcome discussion',
                primaryLink: 'https://example.test/groups/youth/forum/topic/1/',
                dateRecorded: '2026-04-23',
                replyCount: 3,
              ),
            ],
          ),
          groupDocumentsProvider.overrideWith(
            (ref, groupId) async => const <GroupDocument>[
              GroupDocument(
                id: 1,
                attachmentId: 0,
                type: 'folder',
                folderId: 0,
                title: 'Day 1',
                description: '',
                fileName: '',
                downloadUrl: '',
                previewUrl: '',
                extension: '',
                mimeType: '',
                sizeLabel: '',
                authorName: 'Sean Douglas',
              ),
              GroupDocument(
                id: 2,
                attachmentId: 101,
                type: 'document',
                folderId: 1,
                title: 'Session Plan',
                description: 'Weekly session plan',
                fileName: 'session-plan.pdf',
                downloadUrl: 'https://example.test/session-plan.pdf',
                previewUrl: '',
                extension: 'pdf',
                mimeType: 'application/pdf',
                sizeLabel: '1 MB',
                authorName: 'Coach Example',
              ),
              GroupDocument(
                id: 3,
                attachmentId: 102,
                type: 'document',
                folderId: 0,
                title: 'Practical Guide',
                description: 'Reference material',
                fileName: 'practical-guide.docx',
                downloadUrl: 'https://example.test/practical-guide.docx',
                previewUrl: '',
                extension: '',
                mimeType: '',
                sizeLabel: '2 MB',
                authorName: 'Sean Douglas',
              ),
            ],
          ),
          groupDocumentFolderProvider.overrideWith(
            (ref, query) async => query.folderId == 1
                ? const <GroupDocument>[
                    GroupDocument(
                      id: 2,
                      attachmentId: 101,
                      type: 'document',
                      folderId: 1,
                      title: 'Session Plan',
                      description: 'Weekly session plan',
                      fileName: 'session-plan.pdf',
                      downloadUrl: 'https://example.test/session-plan.pdf',
                      previewUrl: '',
                      extension: 'pdf',
                      mimeType: 'application/pdf',
                      sizeLabel: '1 MB',
                      authorName: 'Coach Example',
                    ),
                    GroupDocument(
                      id: 4,
                      attachmentId: 103,
                      type: 'document',
                      folderId: 1,
                      title: 'Syncing Video',
                      description: '',
                      fileName: 'syncing-video.mp4',
                      downloadUrl: 'https://example.test/syncing-video.mp4',
                      previewUrl: '',
                      extension: 'mp4',
                      mimeType: 'video/mp4',
                      sizeLabel: '8 MB',
                      authorName: 'Coach Example',
                    ),
                  ]
                : const <GroupDocument>[
                    GroupDocument(
                      id: 1,
                      attachmentId: 0,
                      type: 'folder',
                      folderId: 0,
                      title: 'Day 1',
                      description: '',
                      fileName: '',
                      downloadUrl: '',
                      previewUrl: '',
                      extension: '',
                      mimeType: '',
                      sizeLabel: '',
                      authorName: 'Sean Douglas',
                    ),
                    GroupDocument(
                      id: 2,
                      attachmentId: 101,
                      type: 'document',
                      folderId: 1,
                      title: 'Session Plan',
                      description: 'Weekly session plan',
                      fileName: 'session-plan.pdf',
                      downloadUrl: 'https://example.test/session-plan.pdf',
                      previewUrl: '',
                      extension: 'pdf',
                      mimeType: 'application/pdf',
                      sizeLabel: '1 MB',
                      authorName: 'Coach Example',
                    ),
                    GroupDocument(
                      id: 3,
                      attachmentId: 102,
                      type: 'document',
                      folderId: 0,
                      title: 'Practical Guide',
                      description: 'Reference material',
                      fileName: 'practical-guide.docx',
                      downloadUrl: 'https://example.test/practical-guide.docx',
                      previewUrl: '',
                      extension: '',
                      mimeType: '',
                      sizeLabel: '2 MB',
                      authorName: 'Sean Douglas',
                    ),
                  ],
          ),
          groupSubgroupsProvider.overrideWith(
            (ref, groupId) async => const <GroupSubgroup>[
              GroupSubgroup(
                id: 18,
                title: 'Regional Youth Coaches',
                description: 'A subgroup for regional collaboration.',
                status: 'public',
                membersCount: '18',
                imageUrl: '',
              ),
            ],
          ),
          groupNotificationSettingsProvider.overrideWith(
            (ref, groupId) async => const GroupNotificationSettings(
              groupId: 4,
              title: 'Email Subscription Options',
              prompt: 'How do you want to read this group?',
              currentStatus: 'dig',
              currentLabel: 'Daily Digest',
              options: <GroupNotificationOption>[
                GroupNotificationOption(
                  value: 'no',
                  label: 'No Email',
                  description: 'I will read this group on the web',
                ),
                GroupNotificationOption(
                  value: 'sum',
                  label: 'Weekly Summary',
                  description: 'Get a summary of topics each week',
                ),
                GroupNotificationOption(
                  value: 'dig',
                  label: 'Daily Digest',
                  description: "Get the day's activity bundled into one email",
                ),
                GroupNotificationOption(
                  value: 'sub',
                  label: 'New Topics',
                  description:
                      'Send new topics as they arrive (but no replies)',
                ),
                GroupNotificationOption(
                  value: 'supersub',
                  label: 'All Email',
                  description: 'Send all group activity as it arrives',
                ),
              ],
            ),
          ),
          groupJoinControllerProvider
              .overrideWith(() => _TestGroupJoinController()),
          groupPostControllerProvider
              .overrideWith(() => _TestGroupPostController()),
          groupNotificationsControllerProvider.overrideWith(
            () => _TestGroupNotificationsController(),
          ),
        ],
        child: const MaterialApp(
          home: GroupDetailPage(tab: AppTab.groups, groupId: 4),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Feed'), findsWidgets);
    expect(find.text('Discuss'), findsOneWidget);
    expect(find.text('Docs'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);

    await tester.tap(find.text('Discuss'));
    await tester.pumpAndSettle();

    expect(find.text('Discussions'), findsOneWidget);
    expect(find.text('Welcome discussion'), findsOneWidget);
    expect(find.text('Sean Douglas - 2026-04-23 - 3 replies'), findsOneWidget);

    await tester.tap(find.text('Docs'));
    await tester.pumpAndSettle();

    expect(find.text('All documents'), findsOneWidget);
    expect(find.text('Day 1'), findsWidgets);
    expect(find.text('practical-guide.docx'), findsOneWidget);
    expect(find.text('session-plan.pdf'), findsNothing);
    expect(find.text('FALSE'), findsNothing);

    final dayOneFolderIcon = find.byIcon(Icons.folder_outlined).first;
    await tester.scrollUntilVisible(
      dayOneFolderIcon,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(dayOneFolderIcon);
    await tester.pumpAndSettle();

    expect(find.text('session-plan.pdf'), findsOneWidget);
    expect(find.text('syncing-video.mp4'), findsOneWidget);

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();

    expect(find.text('Regional Youth Coaches'), findsOneWidget);

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('Email Subscription Options'), findsOneWidget);
    expect(find.text('Daily Digest'), findsOneWidget);
    expect(find.text('I will read this group on the web'), findsOneWidget);
    expect(find.text('Get a summary of topics each week'), findsOneWidget);
    expect(
      find.text("Get the day's activity bundled into one email"),
      findsOneWidget,
    );
    expect(
      find.text('Send new topics as they arrive (but no replies)'),
      findsOneWidget,
    );
    expect(find.text('Send all group activity as it arrives'), findsOneWidget);
    expect(find.text('Save Settings'), findsOneWidget);
  });

  testWidgets('group detail hides composer when posting is not allowed', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          groupDetailProvider.overrideWith(
            (ref, groupId) async => const GroupDetail(
              id: 4,
              type: 'coaching',
              title: 'Youth Coaching',
              content: '<p>A group for youth coaches.</p>',
              status: 'Public',
              time: 'Active today',
              organizerImage: '',
              organizer: 'Sean Douglas',
              isMember: true,
              imageLink: '',
              forumId: 49296,
              canPostToFeed: false,
            ),
          ),
          groupFeedProvider.overrideWith(
            (ref, groupId) async => const <ActivityFeedItem>[],
          ),
          groupDiscussionsProvider.overrideWith(
            (ref, groupId) async => const <GroupDiscussion>[],
          ),
          groupDocumentsProvider.overrideWith(
            (ref, groupId) async => const <GroupDocument>[],
          ),
          groupDocumentFolderProvider.overrideWith(
            (ref, query) async => const <GroupDocument>[],
          ),
          groupSubgroupsProvider.overrideWith(
            (ref, groupId) async => const <GroupSubgroup>[],
          ),
          groupNotificationSettingsProvider.overrideWith(
            (ref, groupId) async => const GroupNotificationSettings(
              groupId: 4,
              title: 'Email Subscription Options',
              prompt: 'How do you want to read this group?',
              currentStatus: 'no',
              currentLabel: 'No Email',
              options: <GroupNotificationOption>[],
            ),
          ),
          groupJoinControllerProvider
              .overrideWith(() => _TestGroupJoinController()),
          groupPostControllerProvider
              .overrideWith(() => _TestGroupPostController()),
          groupNotificationsControllerProvider.overrideWith(
            () => _TestGroupNotificationsController(),
          ),
        ],
        child: const MaterialApp(
          home: GroupDetailPage(tab: AppTab.groups, groupId: 4),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Post an Update'), findsNothing);
    expect(find.text('Post update'), findsNothing);
    expect(find.text('Alerts'), findsOneWidget);
  });

  testWidgets('subgroup detail shows parent group breadcrumb', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          groupDetailProvider.overrideWith(
            (ref, groupId) async => groupId == 4
                ? const GroupDetail(
                    id: 4,
                    type: 'coaching',
                    title: 'Parent Coaches',
                    content: '<p>Parent group.</p>',
                    status: 'Public',
                    time: '',
                    organizerImage: '',
                    organizer: '',
                    isMember: true,
                    imageLink: '',
                    forumId: 0,
                  )
                : const GroupDetail(
                    id: 18,
                    type: 'coaching',
                    title: 'Regional Youth Coaches',
                    content: '<p>Child group.</p>',
                    status: 'Public',
                    time: '',
                    organizerImage: '',
                    organizer: '',
                    isMember: true,
                    imageLink: '',
                    forumId: 0,
                    parentId: 4,
                  ),
          ),
          groupFeedProvider.overrideWith(
            (ref, groupId) async => const <ActivityFeedItem>[],
          ),
          groupDiscussionsProvider.overrideWith(
            (ref, groupId) async => const <GroupDiscussion>[],
          ),
          groupDocumentsProvider.overrideWith(
            (ref, groupId) async => const <GroupDocument>[],
          ),
          groupDocumentFolderProvider.overrideWith(
            (ref, query) async => const <GroupDocument>[],
          ),
          groupSubgroupsProvider.overrideWith(
            (ref, groupId) async => const <GroupSubgroup>[],
          ),
          groupNotificationSettingsProvider.overrideWith(
            (ref, groupId) async => const GroupNotificationSettings(
              groupId: 18,
              title: 'Email Subscription Options',
              prompt: 'How do you want to read this group?',
              currentStatus: 'no',
              currentLabel: 'No Email',
              options: <GroupNotificationOption>[],
            ),
          ),
          groupJoinControllerProvider
              .overrideWith(() => _TestGroupJoinController()),
          groupPostControllerProvider
              .overrideWith(() => _TestGroupPostController()),
          groupNotificationsControllerProvider.overrideWith(
            () => _TestGroupNotificationsController(),
          ),
        ],
        child: const MaterialApp(
          home: GroupDetailPage(
            tab: AppTab.groups,
            groupId: 18,
            source: 'my',
            parentGroupId: 4,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Regional Youth Coaches'), findsOneWidget);
    expect(find.text('Parent Coaches'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
  });

  testWidgets('group discussion page reads and replies in app', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          groupDiscussionProvider.overrideWith(
            (ref, query) async => const GroupDiscussionDetail(
              id: 49297,
              groupId: 4,
              forumId: 49296,
              authorName: 'Sean Douglas',
              authorAvatarUrl: '',
              title: 'Welcome discussion',
              content: 'Welcome to the group.',
              contentHtml: '<p>Welcome to the group.</p>',
              primaryLink: 'https://example.test/groups/topic/1/',
              dateRecorded: '2026-04-23',
              replyCount: 1,
              replies: <GroupDiscussionReply>[
                GroupDiscussionReply(
                  id: 49310,
                  authorName: 'Coach Example',
                  authorAvatarUrl: '',
                  content: 'Thanks Sean.',
                  contentHtml: '<p>Thanks Sean.</p>',
                  primaryLink:
                      'https://example.test/groups/topic/1/#post-49310',
                  dateRecorded: '2026-04-24',
                ),
              ],
            ),
          ),
          groupDiscussionReplyControllerProvider
              .overrideWith(() => _TestGroupDiscussionReplyController()),
        ],
        child: const MaterialApp(
          home: GroupDiscussionPage(
            tab: AppTab.groups,
            groupId: 4,
            discussionId: 49297,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome discussion'), findsOneWidget);
    expect(find.text('Replies'), findsOneWidget);
    expect(find.text('Coach Example'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'I agree.');
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(find.text('Reply saved'), findsOneWidget);
  });
}

class _TestGroupJoinController extends GroupJoinController {
  @override
  Future<void> build() async {}

  @override
  Future<ActionResult> joinGroup(int groupId) async {
    return const ActionResult(message: 'Joined');
  }
}

class _TestGroupPostController extends GroupPostController {
  @override
  Future<void> build() async {}

  @override
  Future<ActionResult> createPost({
    required int groupId,
    required String content,
  }) async {
    return const ActionResult(message: 'Posted');
  }
}

class _TestGroupNotificationsController extends GroupNotificationsController {
  @override
  Future<void> build() async {}

  @override
  Future<ActionResult> saveGroupNotifications({
    required int groupId,
    required String subscription,
  }) async {
    return const ActionResult(message: 'Saved');
  }
}

class _TestGroupDiscussionReplyController
    extends GroupDiscussionReplyController {
  @override
  Future<void> build() async {}

  @override
  Future<ActionResult> createReply({
    required int groupId,
    required int discussionId,
    required String message,
  }) async {
    return const ActionResult(message: 'Reply saved');
  }
}
