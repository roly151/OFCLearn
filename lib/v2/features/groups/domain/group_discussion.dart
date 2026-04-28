import '../../../core/network/json_helpers.dart';

class GroupDiscussion {
  const GroupDiscussion({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.title,
    required this.primaryLink,
    required this.dateRecorded,
    required this.replyCount,
  });

  final int id;
  final String userName;
  final String userImage;
  final String title;
  final String primaryLink;
  final String dateRecorded;
  final int replyCount;

  factory GroupDiscussion.fromJson(Map<String, dynamic> json) {
    return GroupDiscussion(
      id: intValue(json['id']),
      userName: decodedTextValue(json['user_name']),
      userImage: stringValue(json['user_image']),
      title: decodedTextValue(json['Title']),
      primaryLink: stringValue(json['primary_link']),
      dateRecorded: stringValue(json['date_recorded']),
      replyCount: intValue(json['Total_member']),
    );
  }
}

class GroupDiscussionDetail {
  const GroupDiscussionDetail({
    required this.id,
    required this.groupId,
    required this.forumId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.title,
    required this.content,
    required this.contentHtml,
    required this.primaryLink,
    required this.dateRecorded,
    required this.replyCount,
    required this.replies,
  });

  final int id;
  final int groupId;
  final int forumId;
  final String authorName;
  final String authorAvatarUrl;
  final String title;
  final String content;
  final String contentHtml;
  final String primaryLink;
  final String dateRecorded;
  final int replyCount;
  final List<GroupDiscussionReply> replies;

  factory GroupDiscussionDetail.fromJson(Map<String, dynamic> json) {
    final replies = json['replies'];
    return GroupDiscussionDetail(
      id: intValue(json['id']),
      groupId: intValue(json['group_id']),
      forumId: intValue(json['forum_id']),
      authorName: decodedTextValue(json['author_name'], fallback: 'Member'),
      authorAvatarUrl: stringValue(json['author_avatar_url']),
      title: decodedTextValue(json['title'], fallback: 'Untitled discussion'),
      content: plainTextValue(json['content']),
      contentHtml: stringValue(json['content']),
      primaryLink: stringValue(json['primary_link']),
      dateRecorded: stringValue(json['date_recorded']),
      replyCount: intValue(json['reply_count']),
      replies: replies is List<dynamic>
          ? replies
              .whereType<Map<String, dynamic>>()
              .map(GroupDiscussionReply.fromJson)
              .toList(growable: false)
          : const <GroupDiscussionReply>[],
    );
  }
}

class GroupDiscussionReply {
  const GroupDiscussionReply({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.contentHtml,
    required this.primaryLink,
    required this.dateRecorded,
  });

  final int id;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final String contentHtml;
  final String primaryLink;
  final String dateRecorded;

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

  factory GroupDiscussionReply.fromJson(Map<String, dynamic> json) {
    return GroupDiscussionReply(
      id: intValue(json['id']),
      authorName: decodedTextValue(json['author_name'], fallback: 'Member'),
      authorAvatarUrl: stringValue(json['author_avatar_url']),
      content: plainTextValue(json['content']),
      contentHtml: stringValue(json['content']),
      primaryLink: stringValue(json['primary_link']),
      dateRecorded: stringValue(json['date_recorded']),
    );
  }
}
