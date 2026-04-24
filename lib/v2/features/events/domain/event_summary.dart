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
    required this.thumbnailImageUrl,
    required this.recordingLink,
  });

  final int id;
  final String title;
  final String excerpt;
  final String slug;
  final String status;
  final String startDate;
  final String endDate;
  final String link;
  final String thumbnailImageUrl;
  final String recordingLink;

  bool get hasRecording => recordingLink.isNotEmpty;

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: intValue(json['ID']),
      title: decodedTextValue(json['event_title']),
      excerpt: plainTextValue(json['event_excerpt']),
      slug: stringValue(json['event_name']),
      status: stringValue(json['event_status']),
      startDate: stringValue(json['event_start_date']),
      endDate: stringValue(json['event_end_date']),
      link: stringValue(json['event_link']),
      thumbnailImageUrl: stringValue(json['event_thumbnail_image_link']),
      recordingLink: stringValue(
        json['recording_link'],
        fallback: stringValue(json['erv_link']),
      ),
    );
  }
}
