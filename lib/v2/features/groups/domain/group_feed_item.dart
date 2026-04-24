import '../../../core/network/json_helpers.dart';

class GroupFeedItem {
  const GroupFeedItem({
    required this.id,
    required this.userName,
    required this.type,
    required this.content,
    required this.primaryLink,
    required this.dateRecorded,
    required this.imageLink,
    required this.totalComment,
    required this.likeCount,
    required this.isLikedByCurrentUser,
  });

  final int id;
  final String userName;
  final String type;
  final String content;
  final String primaryLink;
  final String dateRecorded;
  final String imageLink;
  final int totalComment;
  final int likeCount;
  final bool isLikedByCurrentUser;

  factory GroupFeedItem.fromJson(Map<String, dynamic> json) {
    return GroupFeedItem(
      id: intValue(json['id']),
      userName: decodedTextValue(json['user_name']),
      type: stringValue(json['type']),
      content: plainTextValue(json['content']),
      primaryLink: stringValue(json['primary_link']),
      dateRecorded: stringValue(json['date_recorded']),
      imageLink: stringValue(json['image_link']),
      totalComment: intValue(json['total_comment']),
      likeCount: intValue(json['like_count']),
      isLikedByCurrentUser: boolValue(json['like_c_user']),
    );
  }
}
