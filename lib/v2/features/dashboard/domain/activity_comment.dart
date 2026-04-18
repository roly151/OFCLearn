import '../../../core/network/json_helpers.dart';

class ActivityComment {
  const ActivityComment({
    required this.id,
    required this.parentCommentId,
    required this.depth,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.primaryLink,
  });

  final int id;
  final int parentCommentId;
  final int depth;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
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
      authorName: stringValue(json['comment_owner_name'], fallback: 'Member'),
      authorAvatarUrl: stringValue(json['comment_owner_image_link']),
      content: _stripHtml(stringValue(json['comment_content'])),
      primaryLink: stringValue(json['comment_primary_link']),
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
