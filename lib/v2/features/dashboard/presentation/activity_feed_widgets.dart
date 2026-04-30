import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/v2_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/device_orientation_policy.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/activity_attachment.dart';
import '../domain/activity_feed_item.dart';
import 'activity_action_controller.dart';
import 'activity_html_content.dart';
import 'activity_interaction_widgets.dart';

class ActivityFeedCard extends ConsumerStatefulWidget {
  const ActivityFeedCard({
    required this.item,
    required this.config,
    required this.parentTab,
    this.showGroupChip = true,
    this.fallbackActionText,
    this.onOpenExternalAttachment,
    this.onExternalAttachmentOpenFailed,
    super.key,
  });

  final ActivityFeedItem item;
  final AppConfig config;
  final String parentTab;
  final bool showGroupChip;
  final String? fallbackActionText;
  final VoidCallback? onOpenExternalAttachment;
  final VoidCallback? onExternalAttachmentOpenFailed;

  @override
  ConsumerState<ActivityFeedCard> createState() => _ActivityFeedCardState();
}

class _ActivityFeedCardState extends ConsumerState<ActivityFeedCard> {
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
  void didUpdateWidget(covariant ActivityFeedCard oldWidget) {
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
    final preview = widget.item.preview;
    final hasLinkedPreview = preview != null && preview.hasContent;
    final bodyHtml = activityContentHtml(
      rendered: widget.item.contentRendered,
      plainText: widget.item.contentStripped,
    );
    final bodyVideo = _firstEmbeddedVideoFromContent(
      widget.item,
      config: widget.config,
    );
    final previewVideo = hasLinkedPreview
        ? _embeddedVideoFromUrl(
            widget.config.resolveMediaUrl(preview.link),
            config: widget.config,
          )
        : null;
    final embeddedVideo = previewVideo ?? bodyVideo;
    final showLinkedPreview = hasLinkedPreview && previewVideo == null;
    final headingText = widget.item.action.isNotEmpty
        ? widget.item.action
        : (widget.fallbackActionText?.trim().isNotEmpty ?? false)
            ? widget.fallbackActionText!.trim()
            : (widget.item.name.isEmpty ? 'Member activity' : widget.item.name);
    final contentWidgets = <Widget>[
      if (bodyHtml.isNotEmpty)
        ActivityHtmlContent(
          html: bodyHtml,
          onOpenLink: (url) => _openBodyLink(context, url),
        )
      else if (widget.item.contentStripped.isNotEmpty)
        Text(
          widget.item.contentStripped,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      if (embeddedVideo != null) ...<Widget>[
        if (bodyHtml.isNotEmpty || widget.item.contentStripped.isNotEmpty)
          const SizedBox(height: 12),
        _EmbeddedVideoPreviewCard(
          video: embeddedVideo,
          title: _embeddedVideoTitle(
            bodyVideo: bodyVideo,
            previewVideo: previewVideo,
            preview: preview,
          ),
          onTap: () => _openEmbeddedVideo(
            context,
            embeddedVideo,
            title: _embeddedVideoTitle(
              bodyVideo: bodyVideo,
              previewVideo: previewVideo,
              preview: preview,
            ),
          ),
        ),
      ],
      if (showLinkedPreview) ...<Widget>[
        if (bodyHtml.isNotEmpty ||
            widget.item.contentStripped.isNotEmpty ||
            embeddedVideo != null)
          const SizedBox(height: 12),
        ActivityLinkedPreview(
          item: preview,
          config: widget.config,
          parentTab: widget.parentTab,
          onOpenExternalAttachment: widget.onOpenExternalAttachment,
          onExternalAttachmentOpenFailed: widget.onExternalAttachmentOpenFailed,
        ),
      ],
      if (bodyHtml.isEmpty &&
          widget.item.contentStripped.isEmpty &&
          embeddedVideo == null &&
          !showLinkedPreview)
        Text(
          'No activity text available.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
    ];

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
        if (!mounted) {
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
        builder: (context) => ActivityCommentsSheet(
          activityId: widget.item.id,
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
              ActivityAvatarBadge(
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
                      headingText,
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
          ...contentWidgets,
          if (widget.item.mediaItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            ActivityMediaPreview(
              items: widget.item.mediaItems,
              config: widget.config,
            ),
          ],
          if (widget.item.documentItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            ActivityDocumentPreview(
              items: widget.item.documentItems,
              config: widget.config,
              onOpenExternalAttachment: widget.onOpenExternalAttachment,
              onExternalAttachmentOpenFailed:
                  widget.onExternalAttachmentOpenFailed,
            ),
          ],
          if (widget.showGroupChip &&
              widget.item.groupName.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _FeedChip(label: widget.item.groupName),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              ActivityActionPillButton(
                icon: _favorited ? Icons.favorite : Icons.favorite_border,
                label: '$_favoriteCount',
                active: _favorited,
                onTap: _likeRequestInFlight ? null : onToggleLike,
              ),
              const SizedBox(width: 10),
              ActivityActionPillButton(
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

  Future<void> _openEmbeddedVideo(
    BuildContext context,
    EmbeddedVideoLink video, {
    required String title,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _EmbeddedVideoPage(
          title: title,
          video: video,
        ),
      ),
    );
  }

  Future<void> _openBodyLink(BuildContext context, String url) async {
    final uri = _resolvedLinkUri(url, config: widget.config);
    if (uri == null) {
      return;
    }

    final embeddedVideo = EmbeddedVideoLink.tryParse(
      uri,
      appIdentityUri: _appIdentityBaseUri(widget.config),
    );
    if (embeddedVideo != null) {
      await _openEmbeddedVideo(
        context,
        embeddedVideo,
        title: embeddedVideo.label,
      );
      return;
    }

    if (_looksLikePdf(uri)) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ActivityPdfViewerPage(
            title: _linkDisplayName(uri),
            url: uri.toString(),
          ),
        ),
      );
      return;
    }

    widget.onOpenExternalAttachment?.call();
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      widget.onExternalAttachmentOpenFailed?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link.')),
      );
    }
  }
}

class ActivityLinkedPreview extends StatelessWidget {
  const ActivityLinkedPreview({
    required this.item,
    required this.config,
    required this.parentTab,
    this.onOpenExternalAttachment,
    this.onExternalAttachmentOpenFailed,
    super.key,
  });

  final ActivityPostPreview item;
  final AppConfig config;
  final String parentTab;
  final VoidCallback? onOpenExternalAttachment;
  final VoidCallback? onExternalAttachmentOpenFailed;

  Future<void> _openPreview(BuildContext context) async {
    if (_isLibraryPost) {
      context.go('/app/$parentTab/post/${item.postId}');
      return;
    }

    final resolvedUrl = config.resolveMediaUrl(item.link);
    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) {
      return;
    }

    final embeddedVideo = EmbeddedVideoLink.tryParse(
      uri,
      appIdentityUri: _appIdentityBaseUri(config),
    );
    if (embeddedVideo != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _EmbeddedVideoPage(
            title: item.title.isNotEmpty ? item.title : embeddedVideo.label,
            video: embeddedVideo,
          ),
        ),
      );
      return;
    }

    if (_looksLikePdf(uri)) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ActivityPdfViewerPage(
            title: item.title.isNotEmpty ? item.title : _linkDisplayName(uri),
            url: uri.toString(),
          ),
        ),
      );
      return;
    }

    onOpenExternalAttachment?.call();
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      onExternalAttachmentOpenFailed?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open preview.')),
      );
    }
  }

  bool get _isLibraryPost =>
      item.postId > 0 &&
      (item.postType.toLowerCase() == 'post' ||
          item.postType.toLowerCase() == 'library');

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = config.resolveMediaUrl(item.imageUrl);

    return Material(
      color: V2Palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: (item.link.isEmpty && !_isLibraryPost)
            ? null
            : () => _openPreview(context),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: V2Palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (resolvedImageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.65,
                    child: Image.network(
                      resolvedImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: V2Palette.mist,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (item.title.isNotEmpty)
                      Text(
                        item.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: V2Palette.primaryBlue),
                      ),
                    if (item.title.isNotEmpty && item.excerpt.isNotEmpty)
                      const SizedBox(height: 10),
                    if (item.excerpt.isNotEmpty)
                      Text(
                        item.excerpt,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityMediaPreview extends StatelessWidget {
  const ActivityMediaPreview({
    required this.items,
    required this.config,
    super.key,
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
          child: Material(
            color: V2Palette.mist,
            child: InkWell(
              onTap: imageUrl.isEmpty
                  ? null
                  : () => _openImageViewer(context, previewItems, index),
              child: Ink(
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _openImageViewer(
    BuildContext context,
    List<ActivityImageAttachment> items,
    int initialIndex,
  ) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _ActivityImageViewerSheet(
          items: items,
          config: config,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ActivityImageViewerSheet extends StatefulWidget {
  const _ActivityImageViewerSheet({
    required this.items,
    required this.config,
    required this.initialIndex,
  });

  final List<ActivityImageAttachment> items;
  final AppConfig config;
  final int initialIndex;

  @override
  State<_ActivityImageViewerSheet> createState() =>
      _ActivityImageViewerSheetState();
}

class _ActivityImageViewerSheetState extends State<_ActivityImageViewerSheet> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final imageUrl = widget.config.resolveMediaUrl(
                  item.fullUrl.isNotEmpty ? item.fullUrl : item.thumbUrl,
                );

                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: imageUrl.isEmpty
                        ? const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 36,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (widget.items.length > 1)
              Positioned(
                top: 18,
                right: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.items.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ActivityDocumentPreview extends StatelessWidget {
  const ActivityDocumentPreview({
    required this.items,
    required this.config,
    this.onOpenExternalAttachment,
    this.onExternalAttachmentOpenFailed,
    super.key,
  });

  final List<ActivityDocumentAttachment> items;
  final AppConfig config;
  final VoidCallback? onOpenExternalAttachment;
  final VoidCallback? onExternalAttachmentOpenFailed;

  Future<void> _openDocument(BuildContext context, String url) async {
    final resolvedUrl = config.resolveMediaUrl(url);
    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) {
      return;
    }

    onOpenExternalAttachment?.call();
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      onExternalAttachmentOpenFailed?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open document.')));
    }
  }

  Future<void> _openPdfDocument(
    BuildContext context,
    ActivityDocumentAttachment item,
  ) async {
    final resolvedUrl = config.resolveMediaUrl(
      item.url.isNotEmpty ? item.url : item.previewUrl,
    );
    if (resolvedUrl.isEmpty) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ActivityPdfViewerPage(
          title: item.displayName,
          url: resolvedUrl,
        ),
      ),
    );
  }

  Future<void> _openImageDocumentViewer(
    BuildContext context,
    ActivityDocumentAttachment item,
  ) async {
    final imageAttachment = ActivityImageAttachment(
      id: item.id,
      attachmentId: item.attachmentId,
      title: item.title,
      url: item.url,
      thumbUrl: item.previewUrl,
      fullUrl: item.url.isNotEmpty ? item.url : item.previewUrl,
      mimeType: item.mimeType,
    );

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _ActivityImageViewerSheet(
          items: <ActivityImageAttachment>[imageAttachment],
          config: config,
          initialIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewItems =
        items.where((item) => item.hasVisualPreview).toList(growable: false);
    final fileItems =
        items.where((item) => !item.hasVisualPreview).toList(growable: false);

    return Column(
      children: <Widget>[
        if (previewItems.isNotEmpty)
          ...previewItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ActivityDocumentImagePreview(
                item: item,
                config: config,
                onOpenDocument: item.isPdf
                    ? (_) => _openPdfDocument(context, item)
                    : item.isImage
                        ? (_) => _openImageDocumentViewer(context, item)
                        : (url) => _openDocument(context, url),
              ),
            ),
          ),
        if (fileItems.isNotEmpty)
          ...fileItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: V2Palette.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: item.url.isEmpty
                      ? null
                      : () => item.isPdf
                          ? _openPdfDocument(context, item)
                          : item.isImage
                              ? _openImageDocumentViewer(context, item)
                              : _openDocument(context, item.url),
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
          ),
      ],
    );
  }
}

class _ActivityPdfViewerPage extends StatefulWidget {
  const _ActivityPdfViewerPage({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<_ActivityPdfViewerPage> createState() => _ActivityPdfViewerPageState();
}

class _ActivityPdfViewerPageState extends State<_ActivityPdfViewerPage> {
  late final PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(InternetFile.get(widget.url)),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: PdfViewPinch(
        controller: _pdfController,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to open PDF.\n$error'),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmbeddedVideoPreviewCard extends StatelessWidget {
  const _EmbeddedVideoPreviewCard({
    required this.video,
    required this.title,
    required this.onTap,
  });

  final EmbeddedVideoLink video;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: V2Palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: V2Palette.cardBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: V2Palette.mist,
                      alignment: Alignment.center,
                      child: const Icon(Icons.play_circle_outline, size: 40),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 42,
                  color: V2Palette.primaryBlue,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          video.label,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityDocumentImagePreview extends StatelessWidget {
  const _ActivityDocumentImagePreview({
    required this.item,
    required this.config,
    required this.onOpenDocument,
  });

  final ActivityDocumentAttachment item;
  final AppConfig config;
  final Future<void> Function(String url) onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final previewUrl = config.resolveMediaUrl(item.previewUrl);
    final openUrl = item.url.isNotEmpty ? item.url : item.previewUrl;

    return Material(
      color: V2Palette.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: openUrl.isEmpty ? null : () => onOpenDocument(openUrl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: V2Palette.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: previewUrl.isEmpty
                  ? const Center(child: Icon(Icons.image_outlined))
                  : Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
        ),
      ),
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

class EmbeddedVideoLink {
  const EmbeddedVideoLink({
    required this.embedUrl,
    required this.label,
    required this.thumbnailUrl,
    this.requestHeaders = const <String, String>{},
  });

  final String embedUrl;
  final String label;
  final String thumbnailUrl;
  final Map<String, String> requestHeaders;

  static EmbeddedVideoLink? tryParse(
    Uri uri, {
    Uri? appIdentityUri,
  }) {
    final youtubeId = _youtubeVideoId(uri);
    if (youtubeId != null && youtubeId.isNotEmpty) {
      final origin = _embedOrigin(appIdentityUri);
      final embedUri =
          Uri.parse('https://www.youtube.com/embed/$youtubeId').replace(
        queryParameters: <String, String>{
          'playsinline': '1',
          'autoplay': '1',
          'rel': '0',
          if (origin != null) 'origin': origin,
          if (origin != null) 'widget_referrer': origin,
        },
      );
      return EmbeddedVideoLink(
        embedUrl: embedUri.toString(),
        label: 'YouTube',
        thumbnailUrl: 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
        requestHeaders: <String, String>{
          if (origin != null) 'Referer': origin,
        },
      );
    }

    final vimeoId = _vimeoVideoId(uri);
    if (vimeoId != null && vimeoId.isNotEmpty) {
      return EmbeddedVideoLink(
        embedUrl: 'https://player.vimeo.com/video/$vimeoId?autoplay=1',
        label: 'Vimeo',
        thumbnailUrl: 'https://vumbnail.com/$vimeoId.jpg',
      );
    }

    return null;
  }

  static String? _youtubeVideoId(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == 'youtu.be') {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }

    if (!host.contains('youtube.com')) {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.isEmpty) {
      return uri.queryParameters['v'];
    }

    if (segments.first == 'watch') {
      return uri.queryParameters['v'];
    }

    if (segments.first == 'embed' && segments.length >= 2) {
      return segments[1];
    }

    if (segments.first == 'shorts' && segments.length >= 2) {
      return segments[1];
    }

    if (segments.first == 'live' && segments.length >= 2) {
      return segments[1];
    }

    return uri.queryParameters['v'];
  }

  static String? _vimeoVideoId(Uri uri) {
    final host = uri.host.toLowerCase();
    if (!host.contains('vimeo.com')) {
      return null;
    }

    for (final segment in uri.pathSegments.reversed) {
      if (RegExp(r'^\d+$').hasMatch(segment)) {
        return segment;
      }
    }

    return null;
  }
}

EmbeddedVideoLink? _firstEmbeddedVideoFromContent(
  ActivityFeedItem item, {
  required AppConfig config,
}) {
  for (final source in <String>[
    item.contentRendered,
    item.contentStripped,
    item.link,
  ]) {
    for (final match in _urlPattern.allMatches(source)) {
      final uri = _resolvedLinkUri(match.group(0) ?? '');
      if (uri == null) {
        continue;
      }

      final embeddedVideo = EmbeddedVideoLink.tryParse(
        uri,
        appIdentityUri: _appIdentityBaseUri(config),
      );
      if (embeddedVideo != null) {
        return embeddedVideo;
      }
    }
  }

  return null;
}

EmbeddedVideoLink? _embeddedVideoFromUrl(
  String url, {
  required AppConfig config,
}) {
  final uri = _resolvedLinkUri(url);
  if (uri == null) {
    return null;
  }

  return EmbeddedVideoLink.tryParse(
    uri,
    appIdentityUri: _appIdentityBaseUri(config),
  );
}

Uri? _resolvedLinkUri(String url, {AppConfig? config}) {
  var candidate = config != null ? config.resolveMediaUrl(url) : url;
  candidate = candidate.trim();
  if (candidate.isEmpty) {
    return null;
  }

  if (candidate.startsWith('www.')) {
    candidate = 'https://$candidate';
  }

  final trailingMatch = RegExp(r'[)\].,!?;:]+$').firstMatch(candidate);
  if (trailingMatch != null) {
    candidate = candidate.substring(0, trailingMatch.start);
  }

  return Uri.tryParse(candidate);
}

bool _looksLikePdf(Uri uri) {
  return uri.path.toLowerCase().endsWith('.pdf');
}

String _linkDisplayName(Uri uri) {
  if (uri.pathSegments.isNotEmpty) {
    final segment = uri.pathSegments.last.trim();
    if (segment.isNotEmpty) {
      return Uri.decodeComponent(segment);
    }
  }

  return uri.host.isNotEmpty ? uri.host : 'Document';
}

String _embeddedVideoTitle({
  required EmbeddedVideoLink? bodyVideo,
  required EmbeddedVideoLink? previewVideo,
  required ActivityPostPreview? preview,
}) {
  if (previewVideo != null && preview != null && preview.title.isNotEmpty) {
    return preview.title;
  }

  if (previewVideo != null) {
    return previewVideo.label;
  }

  if (bodyVideo != null) {
    return bodyVideo.label;
  }

  return 'Video';
}

final RegExp _urlPattern = RegExp(
  r'((?:https?:\/\/|www\.)[^\s<]+)',
  caseSensitive: false,
);

Uri? _appIdentityBaseUri(AppConfig config) {
  final publicBase = config.publicBaseUrl?.trim();
  if (publicBase != null && publicBase.isNotEmpty) {
    final parsed = Uri.tryParse(publicBase);
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      return parsed.replace(path: '', query: null, fragment: null);
    }
  }

  final parsedBase = Uri.tryParse(config.baseUrl);
  if (parsedBase == null || !parsedBase.hasScheme || parsedBase.host.isEmpty) {
    return null;
  }

  return parsedBase.replace(path: '', query: null, fragment: null);
}

String? _embedOrigin(Uri? uri) {
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return null;
  }

  final hasExplicitPort = (uri.scheme == 'http' && uri.port != 80) ||
      (uri.scheme == 'https' && uri.port != 443);

  if (hasExplicitPort) {
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  return '${uri.scheme}://${uri.host}';
}

class _EmbeddedVideoPage extends StatefulWidget {
  const _EmbeddedVideoPage({
    required this.title,
    required this.video,
  });

  final String title;
  final EmbeddedVideoLink video;

  @override
  State<_EmbeddedVideoPage> createState() => _EmbeddedVideoPageState();
}

class _EmbeddedVideoPageState extends State<_EmbeddedVideoPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    allowVideoPlayerOrientations();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.video.embedUrl),
        headers: widget.video.requestHeaders,
      );
  }

  @override
  void dispose() {
    lockToAppPortraitOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
