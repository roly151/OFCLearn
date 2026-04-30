import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../app/v2_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/dependencies.dart';
import '../../../core/device_orientation_policy.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/group_document.dart';

class GroupDocumentsTab extends ConsumerStatefulWidget {
  const GroupDocumentsTab({required this.groupId, super.key});

  final int groupId;

  @override
  ConsumerState<GroupDocumentsTab> createState() => _GroupDocumentsTabState();
}

class _GroupDocumentsTabState extends ConsumerState<GroupDocumentsTab> {
  final List<GroupDocument> _folderStack = <GroupDocument>[];

  int get _currentFolderId => _folderStack.isEmpty ? 0 : _folderStack.last.id;

  Future<void> _refreshDocuments() async {
    final query = GroupDocumentsQuery(
      groupId: widget.groupId,
      folderId: _currentFolderId,
    );
    ref.invalidate(groupDocumentFolderProvider(query));
    await ref.read(groupDocumentFolderProvider(query).future);
  }

  List<GroupDocument> _visibleItems(List<GroupDocument> items) {
    final currentFolderId = _currentFolderId;
    final visibleItems = items
        .where((item) => item.folderId == currentFolderId)
        .toList(growable: false);
    visibleItems.sort((left, right) {
      if (left.isFolder != right.isFolder) {
        return left.isFolder ? -1 : 1;
      }

      return left.displayName.toLowerCase().compareTo(
            right.displayName.toLowerCase(),
          );
    });

    return visibleItems;
  }

  void _openRoot() {
    setState(_folderStack.clear);
  }

  void _openBreadcrumbFolder(int folderId) {
    final folderIndex = _folderStack.indexWhere((item) => item.id == folderId);
    if (folderIndex == -1) {
      return;
    }

    setState(() {
      _folderStack.removeRange(folderIndex + 1, _folderStack.length);
    });
  }

  void _openFolder(GroupDocument folder) {
    setState(() {
      _folderStack.add(folder);
    });
  }

  Future<void> _openFile(
    BuildContext context,
    GroupDocument item,
    AppConfig config,
  ) async {
    final mediaHeaders = config.mediaHeadersForUrl(item.downloadUrl);
    final resolvedUrl = config.resolveMediaUrl(item.downloadUrl);
    if (resolvedUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document.')),
      );
      return;
    }

    if (item.isPdf) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _GroupDocumentPdfViewerPage(
            title: item.displayName,
            url: resolvedUrl,
          ),
        ),
      );
      return;
    }

    if (item.isImage) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _GroupDocumentImageViewerPage(
            title: item.displayName,
            imageUrl: resolvedUrl,
          ),
        ),
      );
      return;
    }

    if (item.isVideo) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _GroupDocumentVideoPlayerPage(
            title: item.displayName,
            url: resolvedUrl,
            headers: mediaHeaders,
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final query = GroupDocumentsQuery(
      groupId: widget.groupId,
      folderId: _currentFolderId,
    );
    final documents = ref.watch(groupDocumentFolderProvider(query));

    return RefreshIndicator(
      onRefresh: _refreshDocuments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: <Widget>[
          Text('Documents', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          documents.when(
            data: (items) {
              final visibleItems = _visibleItems(items);
              final folderCount =
                  visibleItems.where((item) => item.isFolder).length;
              final fileCount = visibleItems.length - folderCount;
              final currentFolderLabel = _folderStack.isEmpty
                  ? 'All documents'
                  : _folderStack.last.title;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DocumentFolderSummary(
                    label: currentFolderLabel,
                    folderCount: folderCount,
                    fileCount: fileCount,
                  ),
                  if (_folderStack.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    _DocumentBreadcrumbs(
                      breadcrumbs: _folderStack,
                      onOpenRoot: _openRoot,
                      onOpenFolder: _openBreadcrumbFolder,
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (visibleItems.isEmpty)
                    AsyncStateView(
                      icon: Icons.folder_open_rounded,
                      message: _currentFolderId == 0
                          ? 'No documents are available right now.'
                          : 'This folder is empty.',
                    )
                  else
                    ...visibleItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DocumentExplorerRow(
                          item: item,
                          onTap: () => item.isFolder
                              ? _openFolder(item)
                              : _openFile(context, item, config),
                        ),
                      ),
                    ),
                ],
              );
            },
            error: (error, _) => AsyncStateView(
              message: error.toString(),
              onRetry: () => ref.invalidate(groupDocumentFolderProvider(query)),
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

class _DocumentFolderSummary extends StatelessWidget {
  const _DocumentFolderSummary({
    required this.label,
    required this.folderCount,
    required this.fileCount,
  });

  final String label;
  final int folderCount;
  final int fileCount;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: V2Palette.navIndicator,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.folder_copy_outlined,
              color: V2Palette.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '$folderCount folders • $fileCount files',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentBreadcrumbs extends StatelessWidget {
  const _DocumentBreadcrumbs({
    required this.breadcrumbs,
    required this.onOpenRoot,
    required this.onOpenFolder,
  });

  final List<GroupDocument> breadcrumbs;
  final VoidCallback onOpenRoot;
  final ValueChanged<int> onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        ActionChip(
          avatar: const Icon(Icons.home_outlined, size: 18),
          label: const Text('Root'),
          onPressed: onOpenRoot,
        ),
        ...breadcrumbs.map(
          (folder) => ActionChip(
            avatar: const Icon(Icons.folder_outlined, size: 18),
            label: Text(folder.title),
            onPressed: () => onOpenFolder(folder.id),
          ),
        ),
      ],
    );
  }
}

class _DocumentExplorerRow extends StatelessWidget {
  const _DocumentExplorerRow({
    required this.item,
    required this.onTap,
  });

  final GroupDocument item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (item.isFolder) 'Folder',
      if (item.authorName.isNotEmpty) item.authorName,
      if (!item.isFolder && item.sizeLabel.isNotEmpty) item.sizeLabel,
      if (!item.isFolder && item.extension.isNotEmpty)
        item.extension.toUpperCase(),
    ];

    return Material(
      color: V2Palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: V2Palette.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.isFolder
                      ? V2Palette.seaGlass.withValues(alpha: 0.35)
                      : V2Palette.navIndicator,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _documentIcon(item),
                  color: V2Palette.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitleParts.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        subtitleParts.join(' • '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (item.description.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                item.isFolder
                    ? Icons.chevron_right_rounded
                    : Icons.open_in_new_rounded,
                color: V2Palette.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _documentIcon(GroupDocument item) {
    if (item.isFolder) {
      return Icons.folder_outlined;
    }

    if (item.isPdf) {
      return Icons.picture_as_pdf_outlined;
    }

    if (item.isImage) {
      return Icons.image_outlined;
    }

    switch (item.extension.toLowerCase()) {
      case 'mp4':
      case 'mov':
      case 'm4v':
        return Icons.video_file_outlined;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Icons.audio_file_outlined;
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _GroupDocumentPdfViewerPage extends StatefulWidget {
  const _GroupDocumentPdfViewerPage({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<_GroupDocumentPdfViewerPage> createState() =>
      _GroupDocumentPdfViewerPageState();
}

class _GroupDocumentPdfViewerPageState
    extends State<_GroupDocumentPdfViewerPage> {
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

class _GroupDocumentImageViewerPage extends StatelessWidget {
  const _GroupDocumentImageViewerPage({
    required this.title,
    required this.imageUrl,
  });

  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupDocumentVideoPlayerPage extends StatefulWidget {
  const _GroupDocumentVideoPlayerPage({
    required this.title,
    required this.url,
    required this.headers,
  });

  final String title;
  final String url;
  final Map<String, String> headers;

  @override
  State<_GroupDocumentVideoPlayerPage> createState() =>
      _GroupDocumentVideoPlayerPageState();
}

class _GroupDocumentVideoPlayerPageState
    extends State<_GroupDocumentVideoPlayerPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialiseVideo;

  @override
  void initState() {
    super.initState();
    allowVideoPlayerOrientations();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: widget.headers,
    );
    _initialiseVideo = _controller.initialize();
  }

  @override
  void dispose() {
    lockToAppPortraitOrientations();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<void>(
        future: _initialiseVideo,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || _controller.value.hasError) {
            final message = _controller.value.errorDescription ??
                snapshot.error?.toString() ??
                'Unable to play video.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: V2Palette.seaGlass,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      IconButton.filled(
                        onPressed: _togglePlayback,
                        iconSize: 34,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
