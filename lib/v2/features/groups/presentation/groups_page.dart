import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/compact_text_scale.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/group_summary.dart';
import 'group_image.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({
    this.initialTab,
    super.key,
  });

  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return Column(
      children: <Widget>[
        const PageHeader(title: 'Groups'),
        Expanded(
          child: groups.when(
            data: (items) => _GroupsTabs(
              items: items,
              initialTab: initialTab,
            ),
            error: (error, _) => AsyncStateView(
              message: error.toString(),
              onRetry: () => ref.invalidate(groupsProvider),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _GroupsTabs extends StatelessWidget {
  const _GroupsTabs({
    required this.items,
    required this.initialTab,
  });

  final List<GroupSummary> items;
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    final topLevelGroups =
        items.where((group) => group.parentId == 0).toList(growable: false);
    final allGroups =
        topLevelGroups.where(_isPublicGroup).toList(growable: false);
    final myGroups =
        topLevelGroups.where((group) => group.isMember).toList(growable: false);

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab == 'my' ? 1 : 0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: V2Palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: V2Palette.cardBorder),
              ),
              child: CompactTextScale(
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: V2Palette.primaryBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorPadding: const EdgeInsets.all(6),
                  labelColor: Colors.white,
                  unselectedLabelColor: V2Palette.ink,
                  tabs: const <Widget>[
                    Tab(text: 'All Groups'),
                    Tab(text: 'My Groups'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _GroupsList(
                  items: allGroups,
                  emptyMessage:
                      'No public BuddyBoss groups are available right now.',
                  source: 'all',
                ),
                _GroupsList(
                  items: myGroups,
                  emptyMessage: 'You are not a member of any groups yet.',
                  source: 'my',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    required this.items,
    required this.emptyMessage,
    required this.source,
  });

  final List<GroupSummary> items;
  final String emptyMessage;
  final String source;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final container = ProviderScope.containerOf(context, listen: false);
        container.invalidate(groupsProvider);
        await container.read(groupsProvider.future);
      },
      child: items.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: <Widget>[
                SectionCard(
                  child: Text(
                    emptyMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final group = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => context
                      .go('/app/groups/group/${group.id}?source=$source'),
                  child: SectionCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _GroupAvatar(group: group),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                group.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                group.statusLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (group.description
                                  .trim()
                                  .isNotEmpty) ...<Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  group.description.trim(),
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
                );
              },
            ),
    );
  }
}

bool _isPublicGroup(GroupSummary group) {
  return group.statusLabel.trim().toLowerCase() == 'public';
}

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.group});

  final GroupSummary group;

  @override
  Widget build(BuildContext context) {
    return GroupImage(
      imageUrl: group.imageUrl,
      size: 72,
    );
  }
}
