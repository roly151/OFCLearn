import '../../../core/network/api_client.dart';
import '../domain/group_detail.dart';
import '../domain/group_feed_item.dart';
import '../domain/group_summary.dart';

class GroupsRepository {
  const GroupsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<GroupSummary>> fetchGroups() async {
    final response = await _apiClient.getList('/groups');
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupSummary.fromJson)
        .toList(growable: false);
  }

  Future<GroupDetail> fetchGroupDetail(int groupId) async {
    final response = await _apiClient.getMap('/groups/$groupId');
    return GroupDetail.fromJson(response);
  }

  Future<List<GroupFeedItem>> fetchGroupFeed(int groupId) async {
    final response = await _apiClient.getList('/groups/$groupId/feed');
    return response
        .whereType<Map<String, dynamic>>()
        .map(GroupFeedItem.fromJson)
        .toList(growable: false);
  }
}
