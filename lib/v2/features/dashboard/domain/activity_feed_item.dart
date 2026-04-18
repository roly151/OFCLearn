import '../../../core/network/json_helpers.dart';
import 'activity_attachment.dart';

class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.userId,
    required this.sourceBlogId,
    required this.name,
    required this.component,
    required this.contentRendered,
    required this.contentStripped,
    required this.date,
    required this.link,
    required this.primaryItemId,
    required this.secondaryItemId,
    required this.status,
    required this.type,
    required this.favorited,
    required this.favoriteCount,
    required this.commentCount,
    required this.canEdit,
    required this.canDelete,
    required this.privacy,
    required this.groupId,
    required this.groupName,
    required this.groupAvatar,
    required this.avatarFullUrl,
    required this.avatarThumbUrl,
    required this.mediaItems,
    required this.documentItems,
  });

  final int id;
  final int userId;
  final int sourceBlogId;
  final String name;
  final String component;
  final String contentRendered;
  final String contentStripped;
  final String date;
  final String link;
  final int primaryItemId;
  final int secondaryItemId;
  final String status;
  final String type;
  final bool favorited;
  final int favoriteCount;
  final int commentCount;
  final bool canEdit;
  final bool canDelete;
  final String privacy;
  final int groupId;
  final String groupName;
  final String groupAvatar;
  final String avatarFullUrl;
  final String avatarThumbUrl;
  final List<ActivityImageAttachment> mediaItems;
  final List<ActivityDocumentAttachment> documentItems;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final activityData = json['activity_data'];
    final avatarUrls = json['avatar_urls'];
    final mediaItems = json['media_items'];
    final documentItems = json['document_items'];

    return ActivityFeedItem(
      id: intValue(json['id']),
      userId: intValue(json['user_id']),
      sourceBlogId: _sourceBlogIdFromJson(json),
      name: stringValue(json['name']),
      component: stringValue(json['component']),
      contentRendered: content is Map<String, dynamic>
          ? stringValue(content['rendered'])
          : '',
      contentStripped: stringValue(json['content_stripped']),
      date: stringValue(json['date']),
      link: stringValue(json['link']),
      primaryItemId: intValue(json['primary_item_id']),
      secondaryItemId: intValue(json['secondary_item_id']),
      status: stringValue(json['status']),
      type: stringValue(json['type']),
      favorited: boolValue(json['favorited']),
      favoriteCount: intValue(json['favorite_count']),
      commentCount: intValue(json['comment_count']),
      canEdit: boolValue(json['can_edit']),
      canDelete: boolValue(json['can_delete']),
      privacy: stringValue(json['privacy']),
      groupId: activityData is Map<String, dynamic>
          ? intValue(activityData['group_id'])
          : 0,
      groupName: activityData is Map<String, dynamic>
          ? stringValue(activityData['group_name'])
          : '',
      groupAvatar: activityData is Map<String, dynamic>
          ? stringValue(activityData['group_avatar'])
          : '',
      avatarFullUrl: avatarUrls is Map<String, dynamic>
          ? stringValue(avatarUrls['full'])
          : '',
      avatarThumbUrl: avatarUrls is Map<String, dynamic>
          ? stringValue(avatarUrls['thumb'])
          : '',
      mediaItems: mediaItems is List<dynamic>
          ? mediaItems
                .whereType<Map<String, dynamic>>()
                .map(ActivityImageAttachment.fromJson)
                .toList(growable: false)
          : const <ActivityImageAttachment>[],
      documentItems: documentItems is List<dynamic>
          ? documentItems
                .whereType<Map<String, dynamic>>()
                .map(ActivityDocumentAttachment.fromJson)
                .toList(growable: false)
          : const <ActivityDocumentAttachment>[],
    );
  }

  static int _sourceBlogIdFromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    if (meta is Map<String, dynamic>) {
      final sourceBlogMeta = meta['_source_blog'] ?? meta['source_blog'];
      if (sourceBlogMeta is List && sourceBlogMeta.isNotEmpty) {
        return intValue(sourceBlogMeta.first);
      }
      return intValue(sourceBlogMeta);
    }

    return intValue(json['source_blog']);
  }
}
