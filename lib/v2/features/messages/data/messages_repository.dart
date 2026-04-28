import '../../../core/domain/action_result.dart';
import '../../../core/network/api_client.dart';
import '../domain/message_thread.dart';

class MessagesRepository {
  const MessagesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MessageThreadSummary>> fetchThreads({
    String search = '',
    int page = 1,
    int perPage = 20,
  }) async {
    final query = StringBuffer('/messages?page=$page&per_page=$perPage');
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      query.write('&search=${Uri.encodeQueryComponent(trimmedSearch)}');
    }

    final response = await _apiClient.getList(query.toString());
    return response
        .whereType<Map<String, dynamic>>()
        .map(MessageThreadSummary.fromJson)
        .toList(growable: false);
  }

  Future<MessageThreadDetail> fetchThread(int threadId) async {
    final response = await _apiClient.getMap('/messages/$threadId');
    return MessageThreadDetail.fromJson(response);
  }

  Future<MessageThreadDetail> fetchDirectThread(int userId) async {
    final response = await _apiClient.getMap('/messages/direct/$userId');
    return MessageThreadDetail.fromJson(response);
  }

  Future<ActionResult> replyToThread({
    required int threadId,
    required String message,
  }) async {
    final response = await _apiClient.postMap(
      '/messages/$threadId/reply',
      data: <String, dynamic>{'message': message},
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Reply sent successfully.',
    );
  }

  Future<ActionResult> sendDirectMessage({
    required int userId,
    required String message,
  }) async {
    final response = await _apiClient.postMap(
      '/messages/direct/$userId',
      data: <String, dynamic>{'message': message},
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Message sent successfully.',
    );
  }

  Future<ActionResult> requestConnection({
    required int userId,
  }) async {
    final response = await _apiClient.postMap(
      '/connections/request',
      data: <String, dynamic>{'user_id': userId},
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Connection request sent.',
    );
  }
}
