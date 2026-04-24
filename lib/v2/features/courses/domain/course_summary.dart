import '../../../core/network/json_helpers.dart';

class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.authorName,
    required this.status,
    required this.slug,
    required this.type,
    required this.price,
    required this.thumbnailUrl,
    required this.link,
  });

  final int id;
  final String title;
  final String excerpt;
  final String authorName;
  final String status;
  final String slug;
  final String type;
  final String price;
  final String thumbnailUrl;
  final String link;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: intValue(json['id']),
      title: decodedTextValue(json['post_title']),
      excerpt: plainTextValue(json['post_excerpt']),
      authorName: decodedTextValue(json['post_author_name']),
      status: stringValue(json['post_status']),
      slug: stringValue(json['post_name']),
      type: stringValue(json['post_type']),
      price: stringValue(json['post_price']),
      thumbnailUrl: stringValue(json['post_thumbnail_link']),
      link: stringValue(json['post_link']),
    );
  }
}
