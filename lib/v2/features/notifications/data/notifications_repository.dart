import '../../../core/domain/action_result.dart';
import '../../../core/network/api_client.dart';
import '../domain/user_notification_item.dart';

class NotificationsRepository {
  const NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<UserNotificationItem>> fetchNotifications({
    String status = 'all',
    int page = 1,
    int perPage = 20,
  }) async {
    final normalizedStatus = _normalizeStatus(status);
    final response = await _apiClient.getList(
      '/notifications?status=$normalizedStatus&page=$page&per_page=$perPage',
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(UserNotificationItem.fromJson)
        .toList(growable: false);
  }

  Future<ActionResult> markRead(int notificationId) async {
    final response =
        await _apiClient.postMap('/notifications/$notificationId/read');
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Notification marked as read.',
    );
  }

  Future<ActionResult> dismiss(int notificationId) async {
    final response =
        await _apiClient.postMap('/notifications/$notificationId/dismiss');
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Notification dismissed.',
    );
  }

  Future<ActionResult> markAllRead() async {
    final response = await _apiClient.postMap('/notifications/read-all');
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'All notifications marked as read.',
    );
  }

  String _normalizeStatus(String status) {
    switch (status) {
      case 'read':
      case 'unread':
        return status;
      default:
        return 'all';
    }
  }
}
