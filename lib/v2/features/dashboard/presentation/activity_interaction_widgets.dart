import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/v2_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/async_state_view.dart';
import '../domain/activity_comment.dart';
import 'activity_action_controller.dart';
import 'activity_html_content.dart';

class ActivityAvatarBadge extends StatelessWidget {
  const ActivityAvatarBadge({
    required this.imageUrl,
    required this.fallbackLabel,
    this.radius = 24,
    super.key,
  });

  final String imageUrl;
  final String fallbackLabel;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = V2Palette.navIndicator;
    final hasImage = imageUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage ? null : Text(fallbackLabel),
    );
  }
}

class ActivityActionPillButton extends StatelessWidget {
  const ActivityActionPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = active ? V2Palette.foliage : V2Palette.seaGlass;
    final foreground =
        active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityCommentsSheet extends ConsumerStatefulWidget {
  const ActivityCommentsSheet({
    required this.activityId,
    required this.config,
    required this.initialCommentCount,
    required this.onCommentPosted,
    super.key,
  });

  final int activityId;
  final AppConfig config;
  final int initialCommentCount;
  final VoidCallback onCommentPosted;

  @override
  ConsumerState<ActivityCommentsSheet> createState() =>
      _ActivityCommentsSheetState();
}

class _ActivityCommentsSheetState extends ConsumerState<ActivityCommentsSheet> {
  late final TextEditingController _commentController;
  late int _commentCount;
  final Set<int> _expandedCommentIds = <int>{};
  ActivityComment? _replyTarget;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _commentCount = widget.initialCommentCount;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final result = await ref
          .read(activityActionControllerProvider.notifier)
          .createComment(
            activityId: widget.activityId,
            message: message,
            parentCommentId: _replyTarget?.id,
          );
      _commentController.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _commentCount += 1;
        _replyTarget = null;
      });
      widget.onCommentPosted();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsState =
        ref.watch(activityCommentsProvider(widget.activityId));
    final actionState = ref.watch(activityActionControllerProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: V2Palette.mist,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '$_commentCount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: commentsState.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const AsyncStateView(
                      icon: Icons.mode_comment_outlined,
                      message: 'No comments yet. Start the conversation.',
                    );
                  }

                  final commentById = <int, ActivityComment>{
                    for (final comment in comments) comment.id: comment,
                  };
                  final commentIds =
                      comments.map((comment) => comment.id).toSet();
                  final topLevelComments = comments.where((comment) {
                    return comment.depth == 0 ||
                        comment.parentCommentId == 0 ||
                        !commentIds.contains(comment.parentCommentId);
                  }).toList(growable: false);

                  int topLevelAncestorId(ActivityComment comment) {
                    var current = comment;
                    final visited = <int>{};
                    while (current.parentCommentId != 0 &&
                        commentById.containsKey(current.parentCommentId) &&
                        !visited.contains(current.parentCommentId)) {
                      visited.add(current.parentCommentId);
                      current = commentById[current.parentCommentId]!;
                    }
                    return current.id;
                  }

                  final descendantRepliesByTopLevel =
                      <int, List<ActivityComment>>{};
                  for (final comment in comments) {
                    final ancestorId = topLevelAncestorId(comment);
                    if (ancestorId == comment.id) {
                      continue;
                    }
                    descendantRepliesByTopLevel
                        .putIfAbsent(ancestorId, () => <ActivityComment>[])
                        .add(comment);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemBuilder: (context, index) => _CommentThreadTile(
                      comment: topLevelComments[index],
                      config: widget.config,
                      commentById: commentById,
                      replies: descendantRepliesByTopLevel[
                              topLevelComments[index].id] ??
                          const <ActivityComment>[],
                      expandedCommentIds: _expandedCommentIds,
                      onReply: (comment) {
                        setState(() {
                          _replyTarget = comment;
                          _expandedCommentIds.add(topLevelComments[index].id);
                        });
                      },
                      onToggleReplies: (commentId) {
                        setState(() {
                          if (_expandedCommentIds.contains(commentId)) {
                            _expandedCommentIds.remove(commentId);
                          } else {
                            _expandedCommentIds.add(commentId);
                          }
                        });
                      },
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: topLevelComments.length,
                  );
                },
                error: (error, _) => AsyncStateView(
                  message: error.toString(),
                  onRetry: () => ref
                      .invalidate(activityCommentsProvider(widget.activityId)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_replyTarget != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: V2Palette.seaGlass,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Replying to ${_replyTarget!.authorName}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _replyTarget = null;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submitComment(),
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed:
                            actionState.isLoading ? null : _submitComment,
                        child: Text(_replyTarget == null ? 'Comment' : 'Reply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentThreadTile extends StatelessWidget {
  const _CommentThreadTile({
    required this.comment,
    required this.config,
    required this.commentById,
    required this.replies,
    required this.expandedCommentIds,
    required this.onReply,
    required this.onToggleReplies,
  });

  final ActivityComment comment;
  final AppConfig config;
  final Map<int, ActivityComment> commentById;
  final List<ActivityComment> replies;
  final Set<int> expandedCommentIds;
  final ValueChanged<ActivityComment> onReply;
  final ValueChanged<int> onToggleReplies;

  @override
  Widget build(BuildContext context) {
    final hasReplies = replies.isNotEmpty;
    final isExpanded = expandedCommentIds.contains(comment.id);
    final replyLabel =
        replies.length == 1 ? 'View 1 reply' : 'View ${replies.length} replies';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _CommentTile(
          comment: comment,
          config: config,
          onReply: () => onReply(comment),
        ),
        if (hasReplies) ...<Widget>[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onToggleReplies(comment.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 18,
                      color: V2Palette.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpanded ? 'Hide replies' : replyLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: V2Palette.primaryBlue,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (hasReplies && isExpanded) ...<Widget>[
          const SizedBox(height: 8),
          ...replies.map(
            (reply) => Padding(
              padding: const EdgeInsets.only(left: 20, top: 8),
              child: _CommentTile(
                comment: reply,
                config: config,
                inset: 12,
                replyToName: _replyToName(reply),
                onReply: () => onReply(reply),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _replyToName(ActivityComment reply) {
    final parent = commentById[reply.parentCommentId];
    if (parent == null || parent.id == comment.id) {
      return null;
    }

    return parent.authorName;
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.config,
    this.replyToName,
    this.onReply,
    this.inset = 0,
  });

  final ActivityComment comment;
  final AppConfig config;
  final String? replyToName;
  final VoidCallback? onReply;
  final double inset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: V2Palette.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14 + inset, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ActivityAvatarBadge(
              imageUrl: config.resolveMediaUrl(comment.authorAvatarUrl),
              fallbackLabel: comment.initials,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    comment.authorName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (replyToName != null &&
                      replyToName!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      'Replying to $replyToName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: V2Palette.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  ActivityHtmlContent(
                    html: activityContentHtml(
                      rendered: comment.contentHtml,
                      plainText: comment.content,
                    ),
                    fontSize: 14,
                    lineHeight: 1.45,
                    paragraphBottomMargin: 10,
                    onOpenLink: (url) => _openCommentLink(context, url),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onReply,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        'Reply',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: V2Palette.primaryBlue,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCommentLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link.')),
      );
    }
  }
}
