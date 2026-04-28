import '../../../core/network/api_client.dart';
import '../../../core/domain/action_result.dart';
import '../../dashboard/domain/activity_feed_item.dart';
import '../domain/group_detail.dart';
import '../domain/group_discussion.dart';
import '../domain/group_document.dart';
import '../domain/group_member.dart';
import '../domain/group_notification_settings.dart';
import '../domain/group_summary.dart';
import '../domain/group_subgroup.dart';

class GroupsRepository {
  static const int _ofcLearnSiteId = 1;

  GroupsRepository(this._apiClient, {required String wpJsonBaseUrl})
      : _wpJsonBaseUrl = wpJsonBaseUrl.replaceFirst(RegExp(r'/$'), '');

  final ApiClient _apiClient;
  final String _wpJsonBaseUrl;

  Future<List<GroupSummary>> fetchGroups() async {
    final response = await _apiClient.getList('/groups');
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupSummary.fromJson)
        .where((group) => group.parentId == 0)
        .toList(growable: false);
  }

  Future<GroupDetail> fetchGroupDetail(int groupId) async {
    final response = await _apiClient.getMap('/groups/$groupId');
    return GroupDetail.fromJson(response);
  }

  Future<List<ActivityFeedItem>> fetchGroupFeed(int groupId) async {
    final response = await _apiClient.getList('/groups/$groupId/feed');
    return response
        .whereType<Map<String, dynamic>>()
        .map(ActivityFeedItem.fromJson)
        .where((item) => item.sourceBlogId == _ofcLearnSiteId)
        .toList(growable: false);
  }

  Future<List<GroupDiscussion>> fetchGroupDiscussions(int groupId) async {
    final response = await _apiClient.getList('/groups/$groupId/discussions');
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupDiscussion.fromJson)
        .toList(growable: false);
  }

  Future<GroupDiscussionDetail> fetchGroupDiscussion({
    required int groupId,
    required int discussionId,
  }) async {
    final response = await _apiClient.getMap(
      '/groups/$groupId/discussions/$discussionId',
    );
    return GroupDiscussionDetail.fromJson(response);
  }

  Future<ActionResult> createGroupDiscussionReply({
    required int groupId,
    required int discussionId,
    required String message,
  }) async {
    final response = await _apiClient.postMap(
      '/groups/$groupId/discussions/$discussionId',
      data: <String, dynamic>{'message': message},
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Reply posted successfully.',
    );
  }

  Future<ActionResult> createGroupPost({
    required int groupId,
    required String content,
  }) async {
    final response = await _apiClient.postMap(
      '/groups/$groupId/feed',
      data: <String, dynamic>{'content': content},
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Post published successfully.',
    );
  }

  Future<ActionResult> joinGroup(int groupId) async {
    final response = await _apiClient.postMap('/groups/$groupId/join');
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Group joined successfully.',
    );
  }

  Future<List<GroupDocument>> fetchGroupDocuments(
    int groupId, {
    int? folderId,
  }) async {
    final folderQuery =
        folderId == null || folderId == 0 ? '' : '&folder_id=$folderId';
    final response = await _apiClient.getList(
      _buddyBossPath(
        '/document?group_id=$groupId$folderQuery&per_page=100&type=both',
      ),
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupDocument.fromJson)
        .toList(growable: false);
  }

  Future<List<GroupSubgroup>> fetchGroupSubgroups(int groupId) async {
    final response = await _apiClient.getList('/groups/$groupId/subgroups');
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupSubgroup.fromJson)
        .toList(growable: false);
  }

  Future<List<GroupMember>> fetchGroupMembers(
    int groupId, {
    String search = '',
  }) async {
    final query = search.trim().isEmpty
        ? '/groups/$groupId/members?per_page=50&status=alphabetical'
        : '/groups/$groupId/members?per_page=50&status=alphabetical&search=${Uri.encodeQueryComponent(search.trim())}';
    final response = await _apiClient.getList(_buddyBossPath(query));
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupMember.fromJson)
        .toList(growable: false);
  }

  Future<GroupNotificationSettings> fetchGroupNotificationSettings(
    int groupId,
  ) async {
    final response = await _apiClient.getMap('/groups/$groupId/notifications');
    return GroupNotificationSettings.fromJson(response);
  }

  Future<ActionResult> updateGroupNotificationSettings({
    required int groupId,
    required String subscription,
  }) async {
    final response = await _apiClient.postMap(
      '/groups/$groupId/notifications',
      data: <String, dynamic>{'subscription': subscription},
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Notification settings updated.',
    );
  }

  Future<ActionResult> sendGroupEmail({
    required int groupId,
    required String message,
  }) async {
    final response = await _apiClient.postMap(
      _buddyBossPath('/messages/group'),
      data: <String, dynamic>{
        'group_id': groupId,
        'message': message,
        'users': 'all',
        'type': 'open',
      },
    );
    return ActionResult.fromJson(
      response,
      fallbackMessage: 'Group email sent successfully.',
    );
  }

  String _buddyBossPath(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$_wpJsonBaseUrl/buddyboss/v1$normalizedPath';
  }
}
