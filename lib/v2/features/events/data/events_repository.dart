import '../../../core/network/api_client.dart';
import '../domain/event_summary.dart';

class EventsRepository {
  const EventsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<EventSummary>> fetchUpcomingEvents() async {
    final response = await _apiClient.getList('/events/upcoming');
    return response
        .whereType<Map<String, dynamic>>()
        .map(EventSummary.fromJson)
        .toList(growable: false);
  }

  Future<List<EventSummary>> fetchPreviousEvents() async {
    final response = await _apiClient.getList('/events/previous');
    return response
        .whereType<Map<String, dynamic>>()
        .map(EventSummary.fromJson)
        .toList(growable: false);
  }
}
