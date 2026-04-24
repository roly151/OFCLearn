import '../../../core/network/json_helpers.dart';

class GroupSubgroup {
  const GroupSubgroup({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.membersCount,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String description;
  final String status;
  final String membersCount;
  final String imageUrl;

  factory GroupSubgroup.fromJson(Map<String, dynamic> json) {
    final description = json['description'];

    return GroupSubgroup(
      id: intValue(json['id']),
      title: decodedTextValue(
        json['name'],
        fallback: decodedTextValue(
          json['title'],
          fallback: decodedTextValue(json['Title']),
        ),
      ),
      description: description is Map<String, dynamic>
          ? plainTextValue(description['rendered'])
          : plainTextValue(
              description,
              fallback: decodedTextValue(json['Description']),
            ),
      status:
          stringValue(json['status'], fallback: stringValue(json['Status'])),
      membersCount: stringValue(json['members_count']),
      imageUrl: stringValue(json['cover_url'],
          fallback: stringValue(json['Image_link'])),
    );
  }
}
