import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/v2_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/dependencies.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/library_post.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  static const int _pageSize = 20;
  static const double _loadMoreThreshold = 600;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;
  String _searchInput = '';
  String _submittedSearchQuery = '';
  List<LibraryPostSummary> _items = const <LibraryPostSummary>[];
  List<LibraryPostSummary> _bufferedItems = const <LibraryPostSummary>[];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _nextPage = 1;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_reloadPosts());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);

    return Column(
      children: <Widget>[
        const PageHeader(title: 'Library'),
        Expanded(
          child: _LibraryList(
            items: _items,
            config: config,
            searchController: _searchController,
            searchQuery: _searchInput,
            isSearching: _submittedSearchQuery.trim().isNotEmpty,
            isInitialLoading: _isInitialLoading,
            isLoadingMore: _isLoadingMore,
            hasMore: _hasMore,
            errorMessage: _errorMessage,
            scrollController: _scrollController,
            onSearchChanged: (value) {
              _searchDebounce?.cancel();
              setState(() {
                _searchInput = value;
              });
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _submittedSearchQuery = value.trim();
                });
                unawaited(_reloadPosts());
              });
            },
            onRetry: _reloadPosts,
            onRefresh: _reloadPosts,
          ),
        ),
      ],
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || _isInitialLoading) {
      return;
    }
    final remaining = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining <= _loadMoreThreshold) {
      unawaited(_loadNextPage());
    }
  }

  Future<void> _reloadPosts() async {
    _requestVersion += 1;
    final requestVersion = _requestVersion;
    _searchDebounce?.cancel();

    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _errorMessage = null;
      _nextPage = 1;
      _items = const <LibraryPostSummary>[];
      _bufferedItems = const <LibraryPostSummary>[];
    });

    await _loadNextPage(requestVersion: requestVersion);
  }

  Future<void> _loadNextPage({int? requestVersion}) async {
    final activeRequestVersion = requestVersion ?? _requestVersion;
    if (!_hasMore || _isLoadingMore) {
      return;
    }

    if (_bufferedItems.isNotEmpty) {
      _consumeBufferedItems(activeRequestVersion);
      return;
    }

    setState(() {
      _isLoadingMore = true;
      if (_items.isNotEmpty) {
        _errorMessage = null;
      }
    });

    final query = LibraryPostsQuery(
      page: _nextPage,
      perPage: _pageSize,
      search: _submittedSearchQuery.trim(),
    );

    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final pageItems =
          await container.read(libraryPostsPageProvider(query).future);
      if (!mounted || activeRequestVersion != _requestVersion) {
        return;
      }

      final dedupedItems = _filterNewItems(pageItems);
      final chunk = dedupedItems.take(_pageSize).toList(growable: false);
      final overflow = dedupedItems.skip(_pageSize).toList(growable: false);

      setState(() {
        _items = <LibraryPostSummary>[..._items, ...chunk];
        _bufferedItems = overflow;
        _nextPage += 1;
        _hasMore = overflow.isNotEmpty || dedupedItems.length == _pageSize;
        if (chunk.isEmpty && overflow.isEmpty) {
          _hasMore = false;
        }
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted || activeRequestVersion != _requestVersion) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted || activeRequestVersion != _requestVersion) {
        return;
      }
      setState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _consumeBufferedItems(int requestVersion) {
    if (!mounted || requestVersion != _requestVersion) {
      return;
    }

    final nextChunk = _bufferedItems.take(_pageSize).toList(growable: false);
    final remaining = _bufferedItems.skip(_pageSize).toList(growable: false);
    setState(() {
      _items = <LibraryPostSummary>[..._items, ...nextChunk];
      _bufferedItems = remaining;
      _hasMore = remaining.isNotEmpty;
      _isInitialLoading = false;
      _isLoadingMore = false;
      _errorMessage = null;
    });
  }

  List<LibraryPostSummary> _filterNewItems(
      List<LibraryPostSummary> candidates) {
    final existingIds = <int>{
      for (final item in _items) item.id,
      for (final item in _bufferedItems) item.id,
    };
    return candidates
        .where((item) => existingIds.add(item.id))
        .toList(growable: false);
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({
    required this.items,
    required this.config,
    required this.searchController,
    required this.searchQuery,
    required this.isSearching,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.scrollController,
    required this.onSearchChanged,
    required this.onRetry,
    required this.onRefresh,
  });

  final List<LibraryPostSummary> items;
  final AppConfig config;
  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearching;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final ScrollController scrollController;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRetry;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SectionCard(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Articles',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Clear search',
                        ),
                ),
              ),
            );
          }

          if (index == 1) {
            return const SizedBox(height: 14);
          }

          if (isInitialLoading) {
            return const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (items.isEmpty) {
            if (errorMessage != null) {
              return AsyncStateView(
                message: errorMessage!,
                onRetry: onRetry,
              );
            }

            return AsyncStateView(
              icon: isSearching
                  ? Icons.search_off_rounded
                  : Icons.library_books_outlined,
              message: isSearching
                  ? 'No blog posts match your search.'
                  : 'No library posts are available right now.',
            );
          }

          final footerIndex = index - 2;
          if (footerIndex >= items.length) {
            if (errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: AsyncStateView(
                  message: errorMessage!,
                  onRetry: onRetry,
                ),
              );
            }

            if (isLoadingMore || hasMore) {
              return const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return const SizedBox.shrink();
          }

          final post = items[footerIndex];
          final imageUrl = config.resolveMediaUrl(post.imageUrl);
          return Padding(
            padding: EdgeInsets.only(
              bottom: footerIndex == items.length - 1 ? 0 : 14,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => context.go('/app/library/post/${post.id}'),
              child: SectionCard(
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
                      const SizedBox(height: 14),
                    ],
                    Text(
                      post.title.isEmpty ? 'Untitled post' : post.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.excerpt.isEmpty ? 'No summary yet.' : post.excerpt,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int get _itemCount {
    final baseCount = 2;
    if (isInitialLoading || items.isEmpty) {
      return baseCount + 1;
    }
    return baseCount +
        items.length +
        ((isLoadingMore || hasMore || errorMessage != null) ? 1 : 0);
  }
}
