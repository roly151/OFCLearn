import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/domain/action_result.dart';
import '../domain/activity_comment.dart';
import '../domain/activity_feed_item.dart';

class DashboardRepository {
  static const int _ofcLearnSiteId = 1;
  static const int activityPageSize = 20;

  const DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardActivityFeedPage> fetchActivityFeedPage({
    int page = 1,
    String scope = 'all',
  }) async {
    final response =
        await _apiClient.getList('/activity?scope=$scope&page=$page');
    final items = response
        .whereType<Map<String, dynamic>>()
        .map(ActivityFeedItem.fromJson)
        .where((item) => item.sourceBlogId == _ofcLearnSiteId)
        .toList(growable: false);

    return DashboardActivityFeedPage(
      items: items,
      hasMore: response.length >= activityPageSize,
    );
  }

  Future<List<ActivityComment>> fetchComments(int activityId) async {
    final response = await _apiClient.getMap('/activity/$activityId/comments');
    final comments = response['comment_list'];
    if (comments is! List<dynamic>) {
      return const <ActivityComment>[];
    }

    return comments
        .whereType<Map<String, dynamic>>()
        .map(ActivityComment.fromJson)
        .toList(growable: false);
  }

  Future<ActionResult> toggleFavorite(int activityId) async {
    final response = await _apiClient.postMap('/activity/$activityId/favorite');
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Like updated successfully.',
    );
  }

  Future<ActionResult> createComment({
    required int activityId,
    required String message,
    int? parentCommentId,
  }) async {
    final response = await _apiClient.postMap(
      '/activity/$activityId/comments',
      data: <String, dynamic>{
        'message': message,
        if (parentCommentId != null) 'parent_id': parentCommentId,
      },
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Comment posted successfully.',
    );
  }

  Future<ActionResult> createActivityPost({
    required String content,
    List<String> imagePaths = const <String>[],
    List<String> documentPaths = const <String>[],
  }) async {
    final fields = <MapEntry<String, String>>[
      MapEntry<String, String>('content', content),
    ];

    final files = <MapEntry<String, MultipartFile>>[];

    for (final imagePath in imagePaths) {
      files.add(
        MapEntry<String, MultipartFile>(
          'media_files[]',
          await MultipartFile.fromFile(
            imagePath,
            filename: _basename(imagePath),
          ),
        ),
      );
    }

    for (final documentPath in documentPaths) {
      files.add(
        MapEntry<String, MultipartFile>(
          'document_files[]',
          await MultipartFile.fromFile(
            documentPath,
            filename: _basename(documentPath),
          ),
        ),
      );
    }

    final response = await _apiClient.postMultipartMap(
      '/activity',
      data: FormData()
        ..fields.addAll(fields)
        ..files.addAll(files),
    );

    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Post added successfully.',
    );
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/');
    return segments.isEmpty ? path : segments.last;
  }
}

class DashboardActivityFeedPage {
  const DashboardActivityFeedPage({
    required this.items,
    required this.hasMore,
  });

  final List<ActivityFeedItem> items;
  final bool hasMore;
}
