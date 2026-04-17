import '../../../core/network/api_client.dart';
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
}
