import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/event_detail.dart';
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

  Future<EventDetail> fetchEventDetail(int eventId) async {
    final responses = await Future.wait<List<dynamic>>(<Future<List<dynamic>>>[
      _apiClient.getList('/events/upcoming'),
      _apiClient.getList('/events/previous'),
    ]);

    for (final response in responses) {
      for (final item in response.whereType<Map<String, dynamic>>()) {
        if (item['ID']?.toString() == eventId.toString()) {
          return EventDetail.fromJson(item);
        }
      }
    }

    throw const ApiException(
      message: 'Event not found in upcoming or archived event feeds.',
      statusCode: 404,
    );
  }
}
