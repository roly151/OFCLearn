import '../../../core/network/json_helpers.dart';
import 'activity_attachment.dart';

class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.userId,
    required this.sourceBlogId,
    required this.name,
    required this.action,
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
    required this.preview,
    required this.mediaItems,
    required this.documentItems,
  });

  final int id;
  final int userId;
  final int sourceBlogId;
  final String name;
  final String action;
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
  final ActivityPostPreview? preview;
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
    final avatarUrls = json['avatar_urls'] ?? json['user_avatar'];
    final previewData = json['preview_data'];
    final mediaItems = json['media_items'];
    final documentItems = json['document_items'];

    return ActivityFeedItem(
      id: intValue(json['id']),
      userId: intValue(json['user_id']),
      sourceBlogId: _sourceBlogIdFromJson(json),
      name: decodedTextValue(
        json['name'],
        fallback: decodedTextValue(json['user_name']),
      ),
      action: _normalizedActionText(decodedTextValue(json['action'])),
      component: stringValue(json['component']),
      contentRendered: content is Map<String, dynamic>
          ? stringValue(content['rendered'])
          : stringValue(content),
      contentStripped: plainTextValue(
        json['content_stripped'],
        fallback: plainTextValue(json['content']),
      ),
      date: stringValue(json['date'],
          fallback: stringValue(json['date_recorded'])),
      link: stringValue(
        json['link'],
        fallback: stringValue(json['primary_link']),
      ),
      primaryItemId: intValue(json['primary_item_id']),
      secondaryItemId: intValue(json['secondary_item_id']),
      status: stringValue(json['status']),
      type: stringValue(json['type']),
      favorited: boolValue(
        json['favorited'],
        fallback: boolValue(json['like_c_user']),
      ),
      favoriteCount: intValue(
        json['favorite_count'],
        fallback: intValue(json['like_count']),
      ),
      commentCount: intValue(
        json['comment_count'],
        fallback: intValue(json['total_comment']),
      ),
      canEdit: boolValue(json['can_edit']),
      canDelete: boolValue(json['can_delete']),
      privacy: stringValue(json['privacy']),
      groupId: activityData is Map<String, dynamic>
          ? intValue(activityData['group_id'])
          : 0,
      groupName: activityData is Map<String, dynamic>
          ? decodedTextValue(activityData['group_name'])
          : '',
      groupAvatar: activityData is Map<String, dynamic>
          ? stringValue(activityData['group_avatar'])
          : '',
      avatarFullUrl: avatarUrls is Map<String, dynamic>
          ? stringValue(
              avatarUrls['full'],
              fallback: stringValue(json['image_link']),
            )
          : stringValue(json['image_link']),
      avatarThumbUrl: avatarUrls is Map<String, dynamic>
          ? stringValue(
              avatarUrls['thumb'],
              fallback: stringValue(json['image_link']),
            )
          : stringValue(json['image_link']),
      preview: previewData is Map<String, dynamic>
          ? ActivityPostPreview.fromJson(previewData)
          : null,
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

  static String _normalizedActionText(String value) {
    if (value.isEmpty) {
      return '';
    }

    final collapsed = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed;
  }
}

class ActivityPostPreview {
  const ActivityPostPreview({
    required this.postId,
    required this.postType,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.link,
  });

  final int postId;
  final String postType;
  final String title;
  final String excerpt;
  final String imageUrl;
  final String link;

  bool get hasContent =>
      title.isNotEmpty || excerpt.isNotEmpty || imageUrl.isNotEmpty;

  factory ActivityPostPreview.fromJson(Map<String, dynamic> json) {
    return ActivityPostPreview(
      postId: intValue(json['post_id']),
      postType: stringValue(json['post_type']),
      title: decodedTextValue(json['title']),
      excerpt: plainTextValue(json['excerpt']),
      imageUrl: stringValue(json['image_url']),
      link: stringValue(json['link']),
    );
  }
}
