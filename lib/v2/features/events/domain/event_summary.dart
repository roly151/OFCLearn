import '../../../core/network/json_helpers.dart';

class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.slug,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.link,
  });

  final int id;
  final String title;
  final String excerpt;
  final String slug;
  final String status;
  final String startDate;
  final String endDate;
  final String link;

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: intValue(json['ID']),
      title: stringValue(json['event_title']),
      excerpt: stringValue(json['event_excerpt']),
      slug: stringValue(json['event_name']),
      status: stringValue(json['event_status']),
      startDate: stringValue(json['event_start_date']),
      endDate: stringValue(json['event_end_date']),
      link: stringValue(json['event_link']),
    );
  }
}
