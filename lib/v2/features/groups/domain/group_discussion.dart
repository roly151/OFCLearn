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
