import '../../../core/network/api_client.dart';
import '../domain/library_post.dart';

class LibraryRepository {
  const LibraryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LibraryPostSummary>> fetchPosts({
    String search = '',
    int page = 1,
    int perPage = 20,
  }) async {
    final normalizedSearch = search.trim();
    final queryParameters = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (normalizedSearch.isNotEmpty)
        'search': Uri.encodeQueryComponent(normalizedSearch),
    };
    final path = queryParameters.isEmpty
        ? '/library'
        : '/library?${queryParameters.entries.map((entry) => '${entry.key}=${entry.value}').join('&')}';
    final response = await _apiClient.getList(path);
    final posts = response
        .whereType<Map<String, dynamic>>()
        .map(LibraryPostSummary.fromJson)
        .toList(growable: true);
    posts.sort((left, right) {
      final leftDate = left.publishedAt;
      final rightDate = right.publishedAt;
      if (leftDate != null && rightDate != null) {
        final byDate = rightDate.compareTo(leftDate);
        if (byDate != 0) {
          return byDate;
        }
      } else if (leftDate != null) {
        return -1;
      } else if (rightDate != null) {
        return 1;
      }
      return right.id.compareTo(left.id);
    });
    return List<LibraryPostSummary>.unmodifiable(posts);
  }

  Future<LibraryPostDetail> fetchPostDetail(int postId) async {
    final response = await _apiClient.getMap('/library/$postId');
    return LibraryPostDetail.fromSummary(
      LibraryPostSummary.fromJson(response),
    );
  }
}
