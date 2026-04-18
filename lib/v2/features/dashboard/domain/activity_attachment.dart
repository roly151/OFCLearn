import '../../../core/network/json_helpers.dart';

class ActivityImageAttachment {
  const ActivityImageAttachment({
    required this.id,
    required this.attachmentId,
    required this.title,
    required this.url,
    required this.thumbUrl,
    required this.fullUrl,
    required this.mimeType,
  });

  final int id;
  final int attachmentId;
  final String title;
  final String url;
  final String thumbUrl;
  final String fullUrl;
  final String mimeType;

  factory ActivityImageAttachment.fromJson(Map<String, dynamic> json) {
    return ActivityImageAttachment(
      id: intValue(json['id']),
      attachmentId: intValue(json['attachment_id']),
      title: stringValue(json['title']),
      url: stringValue(json['url']),
      thumbUrl: stringValue(json['thumb_url']),
      fullUrl: stringValue(json['full_url']),
      mimeType: stringValue(json['mime_type']),
    );
  }
}

class ActivityDocumentAttachment {
  const ActivityDocumentAttachment({
    required this.id,
    required this.attachmentId,
    required this.title,
    required this.fileName,
    required this.url,
    required this.extension,
    required this.mimeType,
  });

  final int id;
  final int attachmentId;
  final String title;
  final String fileName;
  final String url;
  final String extension;
  final String mimeType;

  String get displayName => fileName.isNotEmpty ? fileName : title;

  factory ActivityDocumentAttachment.fromJson(Map<String, dynamic> json) {
    return ActivityDocumentAttachment(
      id: intValue(json['id']),
      attachmentId: intValue(json['attachment_id']),
      title: stringValue(json['title']),
      fileName: stringValue(json['file_name']),
      url: stringValue(json['url']),
      extension: stringValue(json['extension']),
      mimeType: stringValue(json['mime_type']),
    );
  }
}
