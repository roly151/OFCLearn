import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/group_detail.dart';
import '../domain/group_feed_item.dart';
import 'group_join_controller.dart';
import 'group_post_controller.dart';

class GroupDetailPage extends ConsumerStatefulWidget {
  const GroupDetailPage({
    required this.tab,
    required this.groupId,
    super.key,
  });

  final AppTab tab;
  final int groupId;

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
    final feed = ref.watch(groupFeedProvider(widget.groupId));
    final isPosting = ref.watch(groupPostControllerProvider).isLoading;
    final isJoining = ref.watch(groupJoinControllerProvider).isLoading;

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _TopBar(onBack: () => context.go('/app/${widget.tab.slug}')),
          const PageHeader(
            title: 'Group detail',
            subtitle:
                'Group detail and feed are loaded independently so failures stay scoped.',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(groupDetailProvider(widget.groupId));
                ref.invalidate(groupFeedProvider(widget.groupId));
                await Future.wait<void>(<Future<void>>[
                  ref
                      .read(groupDetailProvider(widget.groupId).future)
                      .then((_) {}),
                  ref
                      .read(groupFeedProvider(widget.groupId).future)
                      .then((_) {}),
                ]);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: <Widget>[
                  detail.when(
                    data: (group) => _GroupSummaryCard(
                      group: group,
                      isJoining: isJoining,
                      onJoin: () async {
                        try {
                          final result = await ref
                              .read(groupJoinControllerProvider.notifier)
                              .joinGroup(widget.groupId);
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        } catch (error) {
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      },
                    ),
                    error: (error, _) => AsyncStateView(
                      message: error.toString(),
                      onRetry: () =>
                          ref.invalidate(groupDetailProvider(widget.groupId)),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ComposerCard(
                    controller: _postController,
                    isPosting: isPosting,
                    onSubmit: () async {
                      final content = _postController.text.trim();
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
                            .createPost(
                              groupId: widget.groupId,
                              content: content,
                            );
                        _postController.clear();
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message)),
                        );
                      } catch (error) {
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Feed', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  feed.when(
                    data: (items) => _GroupFeedList(items: items),
                    error: (error, _) => AsyncStateView(
                      message: error.toString(),
                      onRetry: () =>
                          ref.invalidate(groupFeedProvider(widget.groupId)),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _GroupSummaryCard extends StatelessWidget {
  const _GroupSummaryCard({
    required this.group,
    required this.onJoin,
    required this.isJoining,
  });

  final GroupDetail group;
  final Future<void> Function() onJoin;
  final bool isJoining;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(group.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            group.content.isEmpty
                ? 'No description provided.'
                : _stripHtml(group.content),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Tag(label: group.status),
              _Tag(
                label: group.organizer.isEmpty
                    ? 'Unknown organizer'
                    : group.organizer,
              ),
              if (group.time.isNotEmpty) _Tag(label: group.time),
              _Tag(label: group.isMember ? 'Member' : 'Not joined'),
            ],
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
      ),
    );
  }
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
          Text('Post an update', style: Theme.of(context).textTheme.titleLarge),
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
  const _GroupFeedList({required this.items});

  final List<GroupFeedItem> items;

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
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: V2Palette.navIndicator,
                          child: Text(
                            item.userName.isEmpty
                                ? '?'
                                : item.userName[0].toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.userName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                item.dateRecorded,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.content.isEmpty
                          ? 'No content body.'
                          : _stripHtml(item.content),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        _Tag(label: item.type),
                        const SizedBox(width: 8),
                        _Tag(label: '${item.likeCount} likes'),
                        const SizedBox(width: 8),
                        _Tag(label: '${item.totalComment} comments'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: V2Palette.seaGlass,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label),
      ),
    );
  }
}

String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
