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

bool boolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }

  return fallback;
}
