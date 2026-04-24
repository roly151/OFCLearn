import '../../../core/network/json_helpers.dart';

class EventDetail {
  const EventDetail({
    required this.id,
    required this.authorName,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.excerpt,
    required this.slug,
    required this.type,
    required this.status,
    required this.content,
    required this.thumbnailImageUrl,
    required this.link,
    required this.ervLink,
  });

  final int id;
  final String authorName;
  final String startDate;
  final String endDate;
  final String title;
  final String excerpt;
  final String slug;
  final String type;
  final String status;
  final String content;
  final String thumbnailImageUrl;
  final String link;
  final String ervLink;

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      id: intValue(json['ID']),
      authorName: decodedTextValue(json['display_name']),
      startDate: stringValue(json['event_start_date']),
      endDate: stringValue(json['event_end_date']),
      title: decodedTextValue(json['event_title']),
      excerpt: plainTextValue(json['event_excerpt']),
      slug: stringValue(json['event_name']),
      type: stringValue(json['event_type']),
      status: stringValue(json['event_status']),
      content: stringValue(json['event_content']),
      thumbnailImageUrl: stringValue(json['event_thumbnail_image_link']),
      link: stringValue(json['event_link']),
      ervLink: stringValue(
        json['recording_link'],
        fallback: stringValue(json['erv_link']),
      ),
    );
  }
}
