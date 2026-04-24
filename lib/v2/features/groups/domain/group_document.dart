import '../../../core/network/json_helpers.dart';

class GroupDocument {
  const GroupDocument({
    required this.id,
    required this.attachmentId,
    required this.type,
    required this.folderId,
    required this.title,
    required this.description,
    required this.fileName,
    required this.downloadUrl,
    required this.previewUrl,
    required this.extension,
    required this.mimeType,
    required this.sizeLabel,
    required this.authorName,
  });

  final int id;
  final int attachmentId;
  final String type;
  final int folderId;
  final String title;
  final String description;
  final String fileName;
  final String downloadUrl;
  final String previewUrl;
  final String extension;
  final String mimeType;
  final String sizeLabel;
  final String authorName;

  String get displayName =>
      isFolder ? title : (fileName.isNotEmpty ? fileName : title);
  bool get isFolder => type.toLowerCase() == 'folder' || attachmentId == 0;
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
    final normalizedUrl = downloadUrl.toLowerCase();
    return normalizedExtension == 'pdf' ||
        normalizedMimeType == 'application/pdf' ||
        normalizedUrl.endsWith('.pdf');
  }

  bool get isVideo {
    final normalizedExtension = extension.toLowerCase();
    final normalizedMimeType = mimeType.toLowerCase();
    final normalizedUrl = downloadUrl.toLowerCase();
    return normalizedMimeType.startsWith('video/') ||
        const <String>{
          'mp4',
          'm4v',
          'mov',
          'webm',
          'm3u8',
        }.contains(normalizedExtension) ||
        normalizedUrl.endsWith('.mp4') ||
        normalizedUrl.endsWith('.m4v') ||
        normalizedUrl.endsWith('.mov') ||
        normalizedUrl.endsWith('.webm') ||
        normalizedUrl.endsWith('.m3u8');
  }

  factory GroupDocument.fromJson(Map<String, dynamic> json) {
    final attachmentData = json['attachment_data'];
    final previewUrl = attachmentData is Map<String, dynamic>
        ? _safeStringValue(
            attachmentData['thumb'],
            fallback: _safeStringValue(attachmentData['full']),
          )
        : '';
    final extension = _safeStringValue(json['extension']);

    return GroupDocument(
      id: intValue(json['id']),
      attachmentId: intValue(json['attachment_id']),
      type: _safeStringValue(json['type']),
      folderId: intValue(json['folder_id']),
      title: decodedTextValue(json['title']),
      description: plainTextValue(json['description']),
      fileName: decodedTextValue(_safeStringValue(json['filename'])),
      downloadUrl: _safeStringValue(json['download_url']),
      previewUrl: previewUrl,
      extension: extension,
      mimeType: _mimeTypeForExtension(extension),
      sizeLabel: _safeStringValue(json['size']),
      authorName: decodedTextValue(json['display_name']),
    );
  }

  static String _safeStringValue(dynamic value, {String fallback = ''}) {
    if (value == null || value == false) {
      return fallback;
    }

    return stringValue(value, fallback: fallback);
  }

  static String _mimeTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
      case 'm4v':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      default:
        return '';
    }
  }
}
