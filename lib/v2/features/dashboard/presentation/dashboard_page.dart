import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dependencies.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/section_card.dart';
import '../../../app/v2_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import 'activity_action_controller.dart';
import '../domain/activity_comment.dart';
import '../domain/activity_attachment.dart';
import '../domain/activity_feed_item.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final activityFeed = ref.watch(dashboardActivityProvider);
    final config = ref.watch(appConfigProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: <Widget>[
        Text(
          'Good to see you, ${session?.user.displayName.isNotEmpty == true ? session!.user.displayName : session?.user.username ?? 'coach'}.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Your dashboard now surfaces the BuddyBoss activity feed from the live API.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Text(
          'Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const _ActivityComposer(),
        const SizedBox(height: 16),
        activityFeed.when(
          data: (items) => _ActivityFeedList(items: items, config: config),
          error: (error, _) => AsyncStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(dashboardActivityProvider),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _ActivityComposer extends ConsumerStatefulWidget {
  const _ActivityComposer();

  @override
  ConsumerState<_ActivityComposer> createState() => _ActivityComposerState();
}

class _ActivityComposerState extends ConsumerState<_ActivityComposer> {
  late final TextEditingController _controller;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = <XFile>[];
  final List<PlatformFile> _selectedDocuments = <PlatformFile>[];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage();
    if (!mounted || images.isEmpty) {
      return;
    }

    setState(() {
      for (final image in images) {
        final exists = _selectedImages.any((item) => item.path == image.path);
        if (!exists) {
          _selectedImages.add(image);
        }
      }
    });
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      for (final file in result.files) {
        final path = file.path;
        if (path == null || path.isEmpty) {
          continue;
        }

        final exists = _selectedDocuments.any((item) => item.path == path);
        if (!exists) {
          _selectedDocuments.add(file);
        }
      }
    });
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty &&
        _selectedImages.isEmpty &&
        _selectedDocuments.isEmpty) {
      return;
    }

    try {
      final result = await ref
          .read(activityActionControllerProvider.notifier)
          .createActivityPost(
            content: content,
            imagePaths: _selectedImages.map((image) => image.path).toList(),
            documentPaths: _selectedDocuments
                .map((file) => file.path)
                .whereType<String>()
                .toList(),
          );
      _controller.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedImages.clear();
        _selectedDocuments.clear();
      });
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
    final actionState = ref.watch(activityActionControllerProvider);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Share an update with the community...',
            ),
          ),
          if (_selectedImages.isNotEmpty || _selectedDocuments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ..._selectedImages.map(
                  (image) => _SelectedAttachmentChip(
                    icon: Icons.image_outlined,
                    label: image.name,
                    onRemove: () {
                      setState(() {
                        _selectedImages.removeWhere(
                          (item) => item.path == image.path,
                        );
                      });
                    },
                  ),
                ),
                ..._selectedDocuments.map(
                  (document) => _SelectedAttachmentChip(
                    icon: Icons.description_outlined,
                    label: document.name,
                    onRemove: () {
                      setState(() {
                        _selectedDocuments.removeWhere(
                          (item) => item.path == document.path,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: actionState.isLoading ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Image'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: actionState.isLoading ? null : _pickDocuments,
                icon: const Icon(Icons.attach_file_outlined),
                label: const Text('Document'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: actionState.isLoading ? null : _submit,
                child: const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedAttachmentChip extends StatelessWidget {
  const _SelectedAttachmentChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: V2Palette.seaGlass,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: V2Palette.primaryBlue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityFeedList extends StatelessWidget {
  const _ActivityFeedList({
    required this.items,
    required this.config,
  });

  final List<ActivityFeedItem> items;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AsyncStateView(
        icon: Icons.dynamic_feed_outlined,
        message: 'No BuddyBoss activity yet for this user.',
      );
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ActivityCard(item: item, config: config),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ActivityCard extends ConsumerStatefulWidget {
  const _ActivityCard({
    required this.item,
    required this.config,
  });

  final ActivityFeedItem item;
  final AppConfig config;

  @override
  ConsumerState<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends ConsumerState<_ActivityCard> {
  late bool _favorited;
  late int _favoriteCount;
  late int _commentCount;
  bool _likeRequestInFlight = false;

  @override
  void initState() {
    super.initState();
    _syncFromItem();
  }

  @override
  void didUpdateWidget(covariant _ActivityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.favorited != widget.item.favorited ||
        oldWidget.item.favoriteCount != widget.item.favoriteCount ||
        oldWidget.item.commentCount != widget.item.commentCount) {
      _syncFromItem();
    }
  }

  void _syncFromItem() {
    _favorited = widget.item.favorited;
    _favoriteCount = widget.item.favoriteCount;
    _commentCount = widget.item.commentCount;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(activityActionControllerProvider);

    Future<void> onToggleLike() async {
      if (_likeRequestInFlight) {
        return;
      }

      final previousFavorited = _favorited;
      final previousFavoriteCount = _favoriteCount;

      setState(() {
        _likeRequestInFlight = true;
        if (_favorited) {
          _favorited = false;
          _favoriteCount = _favoriteCount > 0 ? _favoriteCount - 1 : 0;
        } else {
          _favorited = true;
          _favoriteCount += 1;
        }
      });

      try {
        await ref
            .read(activityActionControllerProvider.notifier)
            .toggleFavorite(widget.item.id);
        if (!mounted) {
          return;
        }
        setState(() {
          _likeRequestInFlight = false;
        });
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        setState(() {
          _favorited = previousFavorited;
          _favoriteCount = previousFavoriteCount;
          _likeRequestInFlight = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    Future<void> onOpenComments() async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) => _CommentsSheet(
          activity: widget.item,
          config: widget.config,
          initialCommentCount: _commentCount,
          onCommentPosted: () {
            if (!mounted) {
              return;
            }
            setState(() {
              _commentCount += 1;
            });
          },
        ),
      );
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _AvatarBadge(
                imageUrl: widget.config.resolveMediaUrl(
                  widget.item.avatarThumbUrl.isNotEmpty
                      ? widget.item.avatarThumbUrl
                      : widget.item.avatarFullUrl,
                ),
                fallbackLabel: widget.item.initials,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.item.name.isEmpty ? 'Member' : widget.item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.date,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.item.contentStripped.isEmpty
                ? 'No activity text available.'
                : widget.item.contentStripped,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (widget.item.mediaItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _ActivityMediaPreview(
              items: widget.item.mediaItems,
              config: widget.config,
            ),
          ],
          if (widget.item.documentItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _ActivityDocumentPreview(
              items: widget.item.documentItems,
              config: widget.config,
            ),
          ],
          if (widget.item.groupName.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _FeedChip(label: widget.item.groupName),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _ActionPillButton(
                icon: _favorited ? Icons.favorite : Icons.favorite_border,
                label: '$_favoriteCount',
                active: _favorited,
                onTap: _likeRequestInFlight ? null : onToggleLike,
              ),
              const SizedBox(width: 10),
              _ActionPillButton(
                icon: Icons.mode_comment_outlined,
                label: '$_commentCount',
                onTap: onOpenComments,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityMediaPreview extends StatelessWidget {
  const _ActivityMediaPreview({
    required this.items,
    required this.config,
  });

  final List<ActivityImageAttachment> items;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final previewItems = items.take(4).toList(growable: false);
    final imageCount = previewItems.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: imageCount == 1 ? 1 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: imageCount == 1 ? 1.6 : 1,
      ),
      itemBuilder: (context, index) {
        final item = previewItems[index];
        final imageUrl = config.resolveMediaUrl(
          item.thumbUrl.isNotEmpty ? item.thumbUrl : item.fullUrl,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: V2Palette.mist,
              border: Border.all(color: V2Palette.cardBorder),
            ),
            child: imageUrl.isEmpty
                ? const Center(child: Icon(Icons.image_outlined))
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _ActivityDocumentPreview extends StatelessWidget {
  const _ActivityDocumentPreview({
    required this.items,
    required this.config,
  });

  final List<ActivityDocumentAttachment> items;
  final AppConfig config;

  Future<void> _openDocument(BuildContext context, String url) async {
    final resolvedUrl = config.resolveMediaUrl(url);
    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) {
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open document.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: V2Palette.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: item.url.isEmpty ? null : () => _openDocument(context, item.url),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: V2Palette.cardBorder),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: V2Palette.seaGlass,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: V2Palette.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (item.extension.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  item.extension.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_new, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FeedChip extends StatelessWidget {
  const _FeedChip({required this.label});

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

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = active ? V2Palette.foliage : V2Palette.seaGlass;
    final foreground = active
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

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

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({
    required this.activity,
    required this.config,
    required this.initialCommentCount,
    required this.onCommentPosted,
  });

  final ActivityFeedItem activity;
  final AppConfig config;
  final int initialCommentCount;
  final VoidCallback onCommentPosted;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
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
            activityId: widget.activity.id,
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
    final commentsState = ref.watch(activityCommentsProvider(widget.activity.id));
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

                  final commentsByParent = <int, List<ActivityComment>>{};
                  for (final comment in comments) {
                    commentsByParent
                        .putIfAbsent(comment.parentCommentId, () => <ActivityComment>[])
                        .add(comment);
                  }

                  final commentById = <int, ActivityComment>{
                    for (final comment in comments) comment.id: comment,
                  };
                  final commentIds = comments.map((comment) => comment.id).toSet();
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

                  final descendantRepliesByTopLevel = <int, List<ActivityComment>>{};
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
                      replies: descendantRepliesByTopLevel[topLevelComments[index].id] ??
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
                  onRetry: () => ref.invalidate(
                    activityCommentsProvider(widget.activity.id),
                  ),
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
                        onPressed: actionState.isLoading ? null : _submitComment,
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
    final replyLabel = replies.length == 1
        ? 'View 1 reply'
        : 'View ${replies.length} replies';

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
        padding: EdgeInsets.fromLTRB(
          14 + inset,
          14,
          14,
          14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _AvatarBadge(
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
                  if (replyToName != null && replyToName!.isNotEmpty) ...<Widget>[
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
                  Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyMedium,
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
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.imageUrl,
    required this.fallbackLabel,
    this.radius = 24,
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
