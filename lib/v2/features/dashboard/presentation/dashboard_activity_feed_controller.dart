import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dependencies.dart';
import '../data/dashboard_repository.dart';
import '../domain/activity_feed_item.dart';

class DashboardActivityFeedController
    extends AsyncNotifier<DashboardActivityFeedState> {
  int _currentPage = 0;

  @override
  Future<DashboardActivityFeedState> build() async {
    final firstPage = await _fetchPage(1);
    _currentPage = 1;
    return DashboardActivityFeedState(
      items: firstPage.items,
      hasMore: firstPage.hasMore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firstPage = await _fetchPage(1);
      _currentPage = 1;
      return DashboardActivityFeedState(
        items: firstPage.items,
        hasMore: firstPage.hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    final currentState = state.asData?.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final pageResult = await _fetchPage(nextPage);
      _currentPage = nextPage;
      state = AsyncData(
        currentState.copyWith(
          items: <ActivityFeedItem>[
            ...currentState.items,
            ...pageResult.items,
          ],
          hasMore: pageResult.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'dashboard_activity_feed_controller',
          context: ErrorDescription('while loading more dashboard activity'),
        ),
      );
    }
  }

  Future<DashboardActivityFeedPage> _fetchPage(int page) {
    return ref
        .read(dashboardRepositoryProvider)
        .fetchActivityFeedPage(page: page);
  }
}

class DashboardActivityFeedState {
  const DashboardActivityFeedState({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<ActivityFeedItem> items;
  final bool hasMore;
  final bool isLoadingMore;

  DashboardActivityFeedState copyWith({
    List<ActivityFeedItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DashboardActivityFeedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final dashboardActivityFeedControllerProvider = AsyncNotifierProvider<
    DashboardActivityFeedController,
    DashboardActivityFeedState>(DashboardActivityFeedController.new);
