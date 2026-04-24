import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/dependencies.dart';
import '../../../core/network/json_helpers.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../../dashboard/domain/activity_feed_item.dart';
import '../../dashboard/presentation/activity_feed_widgets.dart';
import '../domain/group_detail.dart';
import '../domain/group_discussion.dart';
import '../domain/group_notification_settings.dart';
import '../domain/group_subgroup.dart';
import 'group_documents_tab.dart';
import 'group_join_controller.dart';
import 'group_notifications_controller.dart';
import 'group_post_controller.dart';

class GroupDetailPage extends ConsumerStatefulWidget {
  const GroupDetailPage({
    required this.tab,
    required this.groupId,
    this.source,
    this.parentGroupId,
    super.key,
  });

  final AppTab tab;
  final int groupId;
  final String? source;
  final int? parentGroupId;

  @override
  ConsumerState<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage> {
  late final TextEditingController _postController;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(groupDetailProvider(widget.groupId));

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _TopBar(
            onBack: () => context.go(
              _groupBackPath(
                tab: widget.tab,
                group: detail.asData?.value,
                source: widget.source,
                parentGroupId: widget.parentGroupId,
              ),
            ),
          ),
          PageHeader(
            title: detail.when(
              data: (group) =>
                  group.title.trim().isEmpty ? 'Group detail' : group.title,
              error: (_, __) => 'Group detail',
              loading: () => 'Group detail',
            ),
            subtitle: detail.when(
              data: _groupDescriptionText,
              error: (_, __) => '',
              loading: () => '',
            ),
          ),
          Expanded(
            child: detail.when(
              data: (group) => _GroupDetailTabs(
                tab: widget.tab,
                groupId: widget.groupId,
                group: group,
                source: widget.source,
                postController: _postController,
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(groupDetailProvider(widget.groupId)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupDetailTabs extends ConsumerWidget {
  const _GroupDetailTabs({
    required this.tab,
    required this.groupId,
    required this.group,
    required this.source,
    required this.postController,
  });

  final AppTab tab;
  final int groupId;
  final GroupDetail group;
  final String? source;
  final TextEditingController postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJoining = ref.watch(groupJoinControllerProvider).isLoading;

    return DefaultTabController(
      length: 5,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (group.parentId > 0) ...<Widget>[
                  _ParentGroupBreadcrumb(
                    tab: tab,
                    parentGroupId: group.parentId,
                    source: source,
                  ),
                  const SizedBox(height: 12),
                ],
                _GroupMetaCard(
                  group: group,
                  isJoining: isJoining,
                  onJoin: () async {
                    try {
                      final result = await ref
                          .read(groupJoinControllerProvider.notifier)
                          .joinGroup(groupId);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result.message)));
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: V2Palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: V2Palette.cardBorder),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: V2Palette.primaryBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorPadding: const EdgeInsets.all(6),
                labelPadding: EdgeInsets.zero,
                labelColor: Colors.white,
                unselectedLabelColor: V2Palette.ink,
                tabs: const <Widget>[
                  _DetailTabLabel(
                    icon: Icons.dynamic_feed_outlined,
                    label: 'Feed',
                  ),
                  _DetailTabLabel(
                    icon: Icons.forum_outlined,
                    label: 'Discuss',
                  ),
                  _DetailTabLabel(
                    icon: Icons.folder_copy_outlined,
                    label: 'Docs',
                  ),
                  _DetailTabLabel(
                    icon: Icons.groups_2_outlined,
                    label: 'Groups',
                  ),
                  _DetailTabLabel(
                    icon: Icons.notifications_outlined,
                    label: 'Alerts',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _GroupFeedTab(
                  groupId: groupId,
                  group: group,
                  parentTab: tab.slug,
                  postController: postController,
                ),
                _GroupDiscussionsTab(groupId: groupId),
                GroupDocumentsTab(groupId: groupId),
                _GroupSubgroupsTab(
                  parentTab: tab,
                  groupId: groupId,
                  source: source,
                ),
                _GroupNotificationsTab(
                  groupId: groupId,
                  canManageNotifications: group.isMember,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTabLabel extends StatelessWidget {
  const _DetailTabLabel({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 58,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 19),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text('Group detail', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ParentGroupBreadcrumb extends ConsumerWidget {
  const _ParentGroupBreadcrumb({
    required this.tab,
    required this.parentGroupId,
    required this.source,
  });

  final AppTab tab;
  final int parentGroupId;
  final String? source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = ref.watch(groupDetailProvider(parentGroupId));
    final label = parent.maybeWhen(
      data: (group) =>
          group.title.trim().isEmpty ? 'Parent group' : group.title,
      orElse: () => 'Parent group',
    );

    return TextButton.icon(
      onPressed: () => context.go(_parentGroupPath(tab, parentGroupId, source)),
      icon: const Icon(Icons.chevron_left_rounded),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

class _GroupMetaCard extends StatelessWidget {
  const _GroupMetaCard({
    required this.group,
    required this.isJoining,
    required this.onJoin,
  });

  final GroupDetail group;
  final bool isJoining;
  final Future<void> Function() onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              _MetaChip(
                icon: Icons.lock_outline_rounded,
                label: group.status.isEmpty ? 'Group' : group.status,
              ),
              _MetaChip(
                icon: group.isMember
                    ? Icons.check_circle_outline_rounded
                    : Icons.group_add_rounded,
                label: group.isMember ? 'Member' : 'Not joined',
              ),
            ],
          ),
        ),
        if (!group.isMember) ...<Widget>[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isJoining ? null : onJoin,
            icon: isJoining
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.group_add_rounded),
            label: Text(isJoining ? 'Joining...' : 'Join group'),
          ),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: V2Palette.primaryBlue),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}

class _GroupFeedTab extends ConsumerWidget {
  const _GroupFeedTab({
    required this.groupId,
    required this.group,
    required this.parentTab,
    required this.postController,
  });

  final int groupId;
  final GroupDetail group;
  final String parentTab;
  final TextEditingController postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(groupFeedProvider(groupId));
    final isPosting = ref.watch(groupPostControllerProvider).isLoading;
    final config = ref.watch(appConfigProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(groupDetailProvider(groupId));
        ref.invalidate(groupFeedProvider(groupId));
        await Future.wait<void>(<Future<void>>[
          ref.read(groupDetailProvider(groupId).future).then((_) {}),
          ref.read(groupFeedProvider(groupId).future).then((_) {}),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: <Widget>[
          if (group.isMember && group.canPostToFeed) ...<Widget>[
            _ComposerCard(
              controller: postController,
              isPosting: isPosting,
              onSubmit: () async {
                final content = postController.text.trim();
                if (content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Write something before posting.'),
                    ),
                  );
                  return;
                }

                try {
                  final result = await ref
                      .read(groupPostControllerProvider.notifier)
                      .createPost(groupId: groupId, content: content);
                  postController.clear();
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result.message)));
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
            ),
            const SizedBox(height: 16),
          ],
          Text('Feed', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          feed.when(
            data: (items) => _GroupFeedList(
              items: items,
              config: config,
              parentTab: parentTab,
              groupTitle: group.title.trim(),
            ),
            error: (error, _) => AsyncStateView(
              message: error.toString(),
              onRetry: () => ref.invalidate(groupFeedProvider(groupId)),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupDiscussionsTab extends ConsumerWidget {
  const _GroupDiscussionsTab({required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discussions = ref.watch(groupDiscussionsProvider(groupId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(groupDiscussionsProvider(groupId));
        await ref.read(groupDiscussionsProvider(groupId).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: <Widget>[
          Text('Discussions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          discussions.when(
            data: (items) {
              if (items.isEmpty) {
                return const AsyncStateView(
                  icon: Icons.forum_outlined,
                  message: 'No discussions have been started yet.',
                );
              }

              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DiscussionTile(item: item),
                      ),
                    )
                    .toList(growable: false),
              );
            },
            error: (error, _) => AsyncStateView(
              message: error.toString(),
              onRetry: () => ref.invalidate(groupDiscussionsProvider(groupId)),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionTile extends StatelessWidget {
  const _DiscussionTile({required this.item});

  final GroupDiscussion item;

  @override
  Widget build(BuildContext context) {
    final title =
        item.title.trim().isEmpty ? 'Untitled discussion' : item.title;
    final meta = <String>[
      if (item.userName.trim().isNotEmpty) item.userName.trim(),
      if (item.dateRecorded.trim().isNotEmpty) item.dateRecorded.trim(),
      '${item.replyCount} ${item.replyCount == 1 ? 'reply' : 'replies'}',
    ].join(' - ');

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: item.primaryLink.isEmpty
          ? null
          : () async {
              final uri = Uri.tryParse(item.primaryLink);
              if (uri == null) {
                return;
              }

              final opened = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to open discussion.')),
                );
              }
            },
      child: SectionCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DiscussionAvatar(item: item),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    meta,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (item.primaryLink.isNotEmpty) ...<Widget>[
              const SizedBox(width: 10),
              const Icon(Icons.open_in_new_rounded, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiscussionAvatar extends StatelessWidget {
  const _DiscussionAvatar({required this.item});

  final GroupDiscussion item;

  @override
  Widget build(BuildContext context) {
    if (item.userImage.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: V2Palette.navIndicator,
        child: Text(item.userName.isEmpty ? '?' : item.userName[0]),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(item.userImage),
      onBackgroundImageError: (_, __) {},
    );
  }
}

class _GroupSubgroupsTab extends ConsumerWidget {
  const _GroupSubgroupsTab({
    required this.parentTab,
    required this.groupId,
    required this.source,
  });

  final AppTab parentTab;
  final int groupId;
  final String? source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subgroups = ref.watch(groupSubgroupsProvider(groupId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(groupSubgroupsProvider(groupId));
        await ref.read(groupSubgroupsProvider(groupId).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: <Widget>[
          Text('Subgroups', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          subgroups.when(
            data: (items) {
              if (items.isEmpty) {
                return const AsyncStateView(
                  icon: Icons.groups_2_outlined,
                  message: 'This group does not have any subgroups.',
                );
              }

              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => context.go(
                            _subgroupPath(
                              parentTab,
                              item.id,
                              groupId,
                              source,
                            ),
                          ),
                          child: SectionCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SubgroupAvatar(item: item),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        item.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.status.isEmpty
                                            ? 'Group'
                                            : item.status,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      if (item.membersCount
                                          .trim()
                                          .isNotEmpty) ...<Widget>[
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.membersCount} members',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                      if (item.description
                                          .trim()
                                          .isNotEmpty) ...<Widget>[
                                        const SizedBox(height: 10),
                                        Text(
                                          item.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: V2Palette.ink),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
            error: (error, _) => AsyncStateView(
              message: error.toString(),
              onRetry: () => ref.invalidate(groupSubgroupsProvider(groupId)),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubgroupAvatar extends StatelessWidget {
  const _SubgroupAvatar({required this.item});

  final GroupSubgroup item;

  @override
  Widget build(BuildContext context) {
    if (item.imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: V2Palette.navIndicator,
        child: Text(item.title.isEmpty ? '?' : item.title[0].toUpperCase()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        item.imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CircleAvatar(
          radius: 36,
          backgroundColor: V2Palette.navIndicator,
          child: Text(item.title.isEmpty ? '?' : item.title[0].toUpperCase()),
        ),
      ),
    );
  }
}

class _GroupNotificationsTab extends ConsumerStatefulWidget {
  const _GroupNotificationsTab({
    required this.groupId,
    required this.canManageNotifications,
  });

  final int groupId;
  final bool canManageNotifications;

  @override
  ConsumerState<_GroupNotificationsTab> createState() =>
      _GroupNotificationsTabState();
}

class _GroupNotificationsTabState
    extends ConsumerState<_GroupNotificationsTab> {
  String? _pendingStatus;

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(groupNotificationsControllerProvider);
    final settings =
        ref.watch(groupNotificationSettingsProvider(widget.groupId));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _pendingStatus = null);
        ref.invalidate(groupNotificationSettingsProvider(widget.groupId));
        await ref
            .read(groupNotificationSettingsProvider(widget.groupId).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: <Widget>[
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (!widget.canManageNotifications)
            const AsyncStateView(
              icon: Icons.notifications_outlined,
              message: 'Join this group before changing notification settings.',
            )
          else ...<Widget>[
            settings.when(
              data: (value) {
                final selectedStatus = _pendingStatus ?? value.currentStatus;

                if (value.options.isEmpty) {
                  return const AsyncStateView(
                    icon: Icons.notifications_off_outlined,
                    message: 'No notification settings are available yet.',
                  );
                }

                return SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        value.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        value.prompt,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: V2Palette.primaryBlue,
                            ),
                      ),
                      const SizedBox(height: 18),
                      RadioGroup<String>(
                        groupValue: selectedStatus,
                        onChanged: (nextValue) {
                          if (nextValue == null) {
                            return;
                          }
                          setState(() => _pendingStatus = nextValue);
                        },
                        child: Column(
                          children: value.options
                              .map(
                                (option) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _NotificationOptionTile(
                                    option: option,
                                    groupValue: selectedStatus,
                                    onTap: () => setState(
                                      () => _pendingStatus = option.value,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: controllerState.isLoading
                            ? null
                            : () async {
                                try {
                                  final result = await ref
                                      .read(
                                        groupNotificationsControllerProvider
                                            .notifier,
                                      )
                                      .saveGroupNotifications(
                                        groupId: widget.groupId,
                                        subscription: selectedStatus,
                                      );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  setState(() => _pendingStatus = null);
                                  ref.invalidate(
                                    groupNotificationSettingsProvider(
                                      widget.groupId,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result.message)),
                                  );
                                } catch (error) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF53B6D8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controllerState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Settings'),
                      ),
                    ],
                  ),
                );
              },
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(
                  groupNotificationSettingsProvider(widget.groupId),
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationOptionTile extends StatelessWidget {
  const _NotificationOptionTile({
    required this.option,
    required this.groupValue,
    required this.onTap,
  });

  final GroupNotificationOption option;
  final String groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = option.value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEAF7FB)
              : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF53B6D8) : V2Palette.cardBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Radio<String>(
              value: option.value,
              activeColor: const Color(0xFF3E79F7),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      option.label,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                                color: V2Palette.primaryBlue,
                              ),
                    ),
                    if (option.description.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        option.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: V2Palette.muted,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _groupDescriptionText(GroupDetail group) {
  final description = plainTextFromHtml(group.content).trim();
  return description.isEmpty ? 'No description provided.' : description;
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    required this.controller,
    required this.isPosting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isPosting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Post an Update', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !isPosting,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Share a progress update, question, or resource.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: isPosting ? null : onSubmit,
              icon: isPosting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(isPosting ? 'Posting...' : 'Post update'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupFeedList extends StatelessWidget {
  const _GroupFeedList({
    required this.items,
    required this.config,
    required this.parentTab,
    required this.groupTitle,
  });

  final List<ActivityFeedItem> items;
  final AppConfig config;
  final String parentTab;
  final String groupTitle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AsyncStateView(
        icon: Icons.forum_outlined,
        message: 'No group feed items yet.',
      );
    }

    return Column(
      children: items
          .take(20)
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ActivityFeedCard(
                item: item,
                config: config,
                parentTab: parentTab,
                showGroupChip: false,
                fallbackActionText: _groupFeedActionText(item, groupTitle),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

String? _groupFeedActionText(ActivityFeedItem item, String groupTitle) {
  if (item.action.isNotEmpty || item.name.isEmpty) {
    return null;
  }

  if (groupTitle.isNotEmpty) {
    return '${item.name} posted an update in the group $groupTitle';
  }

  return '${item.name} posted an update';
}

String _groupBackPath({
  required AppTab tab,
  required GroupDetail? group,
  required String? source,
  required int? parentGroupId,
}) {
  final resolvedParentId =
      group != null && group.parentId > 0 ? group.parentId : parentGroupId;

  if (resolvedParentId != null && resolvedParentId > 0) {
    return _parentGroupPath(tab, resolvedParentId, source);
  }

  if (tab == AppTab.groups && source == 'my') {
    return '/app/${tab.slug}?groupsTab=my';
  }

  return '/app/${tab.slug}';
}

String _parentGroupPath(AppTab tab, int parentGroupId, String? source) {
  final query = source == null || source.isEmpty
      ? ''
      : '?source=${Uri.encodeQueryComponent(source)}';
  return '/app/${tab.slug}/group/$parentGroupId$query';
}

String _subgroupPath(
  AppTab tab,
  int subgroupId,
  int parentGroupId,
  String? source,
) {
  final query = <String, String>{
    'parentId': parentGroupId.toString(),
    if (source != null && source.isNotEmpty) 'source': source,
  };
  final queryString = Uri(queryParameters: query).query;
  return '/app/${tab.slug}/group/$subgroupId?$queryString';
}
