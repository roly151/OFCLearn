import '../../../core/network/json_helpers.dart';

class GroupSummary {
  const GroupSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.statusLabel,
    required this.createdOn,
    required this.imageUrl,
    required this.authorImageUrl,
    required this.organizerName,
    required this.isMember,
  });

  final int id;
  final String title;
  final String type;
  final String statusLabel;
  final String createdOn;
  final String imageUrl;
  final String authorImageUrl;
  final String organizerName;
  final bool isMember;

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      id: intValue(json['id']),
      title: stringValue(json['Title']),
      type: stringValue(json['type']),
      statusLabel: stringValue(json['Status']),
      createdOn: stringValue(json['Time']),
      imageUrl: stringValue(json['Image_link']),
      authorImageUrl: stringValue(json['author_image']),
      organizerName: stringValue(json['user_name']),
      isMember: boolValue(json['Have_in_group']),
    );
  }
}
