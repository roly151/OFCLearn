import '../../../core/network/json_helpers.dart';

class LibraryPostSummary {
  const LibraryPostSummary({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
  });

  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime? publishedAt;

  String get excerpt {
    final stripped = _stripHtml(content);
    if (stripped.length <= 180) {
      return stripped;
    }
    return '${stripped.substring(0, 177).trimRight()}...';
  }

  factory LibraryPostSummary.fromJson(Map<String, dynamic> json) {
    return LibraryPostSummary(
      id: intValue(json['ID']),
      title: decodedTextValue(json['post_title']),
      content: stringValue(json['post_content']),
      imageUrl: stringValue(json['image']),
      publishedAt: _dateTimeValue(
        json['post_date_gmt'] ??
            json['post_date'] ??
            json['date_gmt'] ??
            json['date'],
      ),
    );
  }
}

class LibraryPostDetail {
  const LibraryPostDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String content;
  final String imageUrl;

  String get excerpt => _stripHtml(content);

  factory LibraryPostDetail.fromSummary(LibraryPostSummary summary) {
    return LibraryPostDetail(
      id: summary.id,
      title: summary.title,
      content: summary.content,
      imageUrl: summary.imageUrl,
    );
  }
}

String stripLibraryHtml(String html) => _stripHtml(html);

String _stripHtml(String html) {
  return plainTextFromHtml(html);
}

DateTime? _dateTimeValue(dynamic value) {
  final raw = stringValue(value);
  if (raw.isEmpty || raw == '0000-00-00 00:00:00') {
    return null;
  }

  final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized)?.toUtc();
}
