import '../../../core/network/json_helpers.dart';

class GroupDetail {
  const GroupDetail({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.status,
    required this.time,
    required this.organizerImage,
    required this.organizer,
    required this.isMember,
    required this.imageLink,
    required this.forumId,
    this.canPostToFeed = true,
    this.activityFeedStatus = '',
    this.parentId = 0,
  });

  final int id;
  final String type;
  final String title;
  final String content;
  final String status;
  final String time;
  final String organizerImage;
  final String organizer;
  final bool isMember;
  final String imageLink;
  final int forumId;
  final bool canPostToFeed;
  final String activityFeedStatus;
  final int parentId;

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      id: intValue(json['id']),
      type: stringValue(json['type']),
      title: decodedTextValue(json['Title']),
      content: stringValue(json['Content']),
      status: stringValue(json['Status']),
      time: stringValue(json['Time']),
      organizerImage: stringValue(json['organizer_image']),
      organizer: decodedTextValue(json['organizer']),
      isMember: boolValue(json['Have_in_group']),
      imageLink: stringValue(json['Image_link']),
      forumId: intValue(json['forum_id']),
      canPostToFeed: boolValue(
        json['can_post'],
        fallback: boolValue(json['canPost'], fallback: true),
      ),
      activityFeedStatus: stringValue(json['activity_feed_status']),
      parentId: intValue(json['parent_id']),
    );
  }
}
