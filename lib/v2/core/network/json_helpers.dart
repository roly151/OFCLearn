String stringValue(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  if (value is String) {
    return value;
  }

  return value.toString();
}

int intValue(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

String decodedTextValue(dynamic value, {String fallback = ''}) {
  return decodeHtmlText(stringValue(value, fallback: fallback));
}

String plainTextValue(dynamic value, {String fallback = ''}) {
  return plainTextFromHtml(stringValue(value, fallback: fallback));
}

String decodeHtmlText(String value) {
  if (value.isEmpty) {
    return '';
  }

  final decoded = value.replaceAllMapped(RegExp(r'&(#x?[0-9A-Fa-f]+|\w+);'), (
    match,
  ) {
    final entity = match.group(1) ?? '';
    if (entity.isEmpty) {
      return match.group(0) ?? '';
    }

    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      final codePoint = int.tryParse(entity.substring(2), radix: 16);
      return codePoint == null
          ? match.group(0) ?? ''
          : String.fromCharCode(codePoint);
    }

    if (entity.startsWith('#')) {
      final codePoint = int.tryParse(entity.substring(1));
      return codePoint == null
          ? match.group(0) ?? ''
          : String.fromCharCode(codePoint);
    }

    return _namedHtmlEntities[entity] ?? match.group(0) ?? '';
  });

  return decoded
      .replaceAll('[…]', '...')
      .replaceAll('[...]', '...')
      .replaceAll('\u00A0', ' ')
      .replaceAll(r"\'", "'")
      .replaceAll(r'\"', '"');
}

String plainTextFromHtml(String value) {
  return decodeHtmlText(
    value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim(),
  ).replaceAll(RegExp(r'\s+'), ' ').trim();
}

const Map<String, String> _namedHtmlEntities = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'hellip': '…',
  'ndash': '–',
  'mdash': '—',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
};

bool boolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }

  return fallback;
}
