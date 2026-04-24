import '../../../core/network/json_helpers.dart';

class ActivityComment {
  const ActivityComment({
    required this.id,
    required this.parentCommentId,
    required this.depth,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.contentHtml,
    required this.primaryLink,
  });

  final int id;
  final int parentCommentId;
  final int depth;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final String contentHtml;
  final String primaryLink;

  String get initials {
    final parts = authorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  factory ActivityComment.fromJson(Map<String, dynamic> json) {
    return ActivityComment(
      id: intValue(json['comment_id']),
      parentCommentId: intValue(json['parent_comment_id']),
      depth: intValue(json['depth']),
      authorName: decodedTextValue(
        json['comment_owner_name'],
        fallback: 'Member',
      ),
      authorAvatarUrl: stringValue(json['comment_owner_image_link']),
      content: plainTextValue(json['comment_content']),
      contentHtml: stringValue(json['comment_content']),
      primaryLink: stringValue(json['comment_primary_link']),
    );
  }
}
