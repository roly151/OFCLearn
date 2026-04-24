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
      title: decodedTextValue(json['title']),
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
    required this.previewUrl,
    required this.extension,
    required this.mimeType,
  });

  final int id;
  final int attachmentId;
  final String title;
  final String fileName;
  final String url;
  final String previewUrl;
  final String extension;
  final String mimeType;

  String get displayName => fileName.isNotEmpty ? fileName : title;
  bool get hasVisualPreview => previewUrl.isNotEmpty;
  bool get isImage {
    final normalizedExtension = extension.toLowerCase();
    final normalizedMimeType = mimeType.toLowerCase();
    return normalizedMimeType.startsWith('image/') ||
        const <String>{
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'heic',
          'heif',
        }.contains(normalizedExtension);
  }

  bool get isPdf {
    final normalizedExtension = extension.toLowerCase();
    final normalizedMimeType = mimeType.toLowerCase();
    final normalizedUrl = url.toLowerCase();
    return normalizedExtension == 'pdf' ||
        normalizedMimeType == 'application/pdf' ||
        normalizedUrl.endsWith('.pdf');
  }

  factory ActivityDocumentAttachment.fromJson(Map<String, dynamic> json) {
    return ActivityDocumentAttachment(
      id: intValue(json['id']),
      attachmentId: intValue(json['attachment_id']),
      title: decodedTextValue(json['title']),
      fileName: decodedTextValue(json['file_name']),
      url: stringValue(json['url']),
      previewUrl: stringValue(json['preview_url']),
      extension: stringValue(json['extension']),
      mimeType: stringValue(json['mime_type']),
    );
  }
}
