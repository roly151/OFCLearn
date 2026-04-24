import '../../../core/network/json_helpers.dart';

class CourseDetail {
  const CourseDetail({
    required this.authorName,
    required this.date,
    required this.title,
    required this.excerpt,
    required this.slug,
    required this.type,
    required this.status,
    required this.content,
    required this.featuredImageUrl,
    required this.link,
    required this.lessonLink,
  });

  final String authorName;
  final String date;
  final String title;
  final String excerpt;
  final String slug;
  final String type;
  final String status;
  final String content;
  final String featuredImageUrl;
  final String link;
  final String lessonLink;

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      authorName: decodedTextValue(json['display_name']),
      date: stringValue(json['course_date']),
      title: decodedTextValue(json['course_title']),
      excerpt: plainTextValue(json['course_excerpt']),
      slug: stringValue(json['course_name']),
      type: stringValue(json['course_type']),
      status: stringValue(json['course_status']),
      content: stringValue(json['course_content']),
      featuredImageUrl: stringValue(json['course_featured_image_link']),
      link: stringValue(json['course_link']),
      lessonLink: stringValue(json['course_lesson_link']),
    );
  }
}
