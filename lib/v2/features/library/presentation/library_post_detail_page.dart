import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/dependencies.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/library_post.dart';

class LibraryPostDetailPage extends ConsumerWidget {
  const LibraryPostDetailPage({
    required this.tab,
    required this.postId,
    super.key,
  });

  final AppTab tab;
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(libraryPostDetailProvider(postId));
    final config = ref.watch(appConfigProvider);

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _TopBar(onBack: () => context.go('/app/${tab.slug}')),
          Expanded(
            child: detail.when(
              data: (post) => _LibraryPostDetailContent(
                post: post,
                config: config,
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(libraryPostDetailProvider(postId)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
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
          Text('Library', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _LibraryPostDetailContent extends StatelessWidget {
  const _LibraryPostDetailContent({
    required this.post,
    required this.config,
  });

  final LibraryPostDetail post;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final imageUrl = config.resolveMediaUrl(post.imageUrl);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (imageUrl.isNotEmpty) ...<Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1.7,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: V2Palette.mist,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Text(
                post.title.isEmpty ? 'Untitled post' : post.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: post.content.isEmpty
              ? Text(
                  'No post content yet.',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              : Html(
                  data: post.content,
                  style: <String, Style>{
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: FontSize(16),
                      lineHeight: const LineHeight(1.5),
                    ),
                    'a': Style(color: V2Palette.primaryBlue),
                    'p': Style(margin: Margins.only(bottom: 14)),
                    'li': Style(margin: Margins.only(bottom: 8)),
                    'h1': Style(margin: Margins.only(bottom: 12)),
                    'h2': Style(margin: Margins.only(bottom: 12)),
                    'h3': Style(margin: Margins.only(bottom: 10)),
                  },
                ),
        ),
      ],
    );
  }
}
