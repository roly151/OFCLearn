import '../../../core/network/json_helpers.dart';
import '../../auth/domain/api_user.dart';

class ProfileOverview {
  const ProfileOverview({
    required this.user,
    required this.groups,
  });

  final ApiUser user;
  final List<ProfileFieldGroup> groups;

  factory ProfileOverview.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groups'];
    return ProfileOverview(
      user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
      groups: rawGroups is List<dynamic>
          ? rawGroups
              .whereType<Map<String, dynamic>>()
              .map(ProfileFieldGroup.fromJson)
              .toList(growable: false)
          : const <ProfileFieldGroup>[],
    );
  }
}

class ProfileFieldGroup {
  const ProfileFieldGroup({
    required this.id,
    required this.name,
    required this.fields,
  });

  final int id;
  final String name;
  final List<ProfileField> fields;

  factory ProfileFieldGroup.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    return ProfileFieldGroup(
      id: intValue(json['id']),
      name: decodedTextValue(json['name']),
      fields: rawFields is List<dynamic>
          ? rawFields
              .whereType<Map<String, dynamic>>()
              .map(ProfileField.fromJson)
              .toList(growable: false)
          : const <ProfileField>[],
    );
  }
}

class ProfileField {
  const ProfileField({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.required,
    required this.editable,
    required this.value,
    required this.values,
    required this.options,
  });

  final int id;
  final String name;
  final String description;
  final String type;
  final bool required;
  final bool editable;
  final String value;
  final List<String> values;
  final List<ProfileFieldOption> options;

  bool get hasOptions => options.isNotEmpty;
  bool get isMultiValue =>
      type == 'checkbox' || type == 'multiselectbox' || values.length > 1;

  factory ProfileField.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    final values = rawValue is List<dynamic>
        ? rawValue.map(decodedTextValue).toList(growable: false)
        : <String>[decodedTextValue(rawValue)];
    final rawOptions = json['options'];

    return ProfileField(
      id: intValue(json['id']),
      name: decodedTextValue(json['name']),
      description: decodedTextValue(json['description']),
      type: stringValue(json['type']),
      required: boolValue(json['required']),
      editable: boolValue(json['editable']),
      value: values.where((value) => value.trim().isNotEmpty).join(', '),
      values: values,
      options: rawOptions is List<dynamic>
          ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(ProfileFieldOption.fromJson)
              .toList(growable: false)
          : const <ProfileFieldOption>[],
    );
  }
}

class ProfileFieldOption {
  const ProfileFieldOption({
    required this.id,
    required this.label,
    required this.value,
  });

  final int id;
  final String label;
  final String value;

  factory ProfileFieldOption.fromJson(Map<String, dynamic> json) {
    return ProfileFieldOption(
      id: intValue(json['id']),
      label: decodedTextValue(json['label']),
      value: decodedTextValue(json['value']),
    );
  }
}

class UserConnection {
  const UserConnection({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
  });

  final int id;
  final String displayName;
  final String avatarUrl;

  factory UserConnection.fromJson(Map<String, dynamic> json) {
    return UserConnection(
      id: intValue(json['friend_id']),
      displayName: decodedTextValue(json['friend_display_name']),
      avatarUrl: stringValue(json['friend_image']),
    );
  }
}

class QualificationsOverview {
  const QualificationsOverview({
    required this.accreditations,
    required this.cpd,
  });

  final List<AccreditationItem> accreditations;
  final CpdOverview cpd;

  factory QualificationsOverview.fromJson(Map<String, dynamic> json) {
    final rawAccreditations = json['accreditations'];
    return QualificationsOverview(
      accreditations: rawAccreditations is List<dynamic>
          ? rawAccreditations
              .whereType<Map<String, dynamic>>()
              .map(AccreditationItem.fromJson)
              .toList(growable: false)
          : const <AccreditationItem>[],
      cpd: CpdOverview.fromJson(json['cpd'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AccreditationItem {
  const AccreditationItem({
    required this.id,
    required this.title,
    required this.expiryDate,
    required this.certificateLink,
  });

  final int id;
  final String title;
  final String expiryDate;
  final String certificateLink;

  factory AccreditationItem.fromJson(Map<String, dynamic> json) {
    return AccreditationItem(
      id: intValue(json['id']),
      title: decodedTextValue(json['title']),
      expiryDate: decodedTextValue(json['expiry_date']),
      certificateLink: stringValue(json['certificate_link']),
    );
  }
}

class CpdOverview {
  const CpdOverview({
    required this.total,
    required this.label,
    required this.thumbnail,
    required this.earnings,
  });

  final int total;
  final String label;
  final String thumbnail;
  final List<CpdEarning> earnings;

  factory CpdOverview.fromJson(Map<String, dynamic> json) {
    final rawEarnings = json['earnings'];
    return CpdOverview(
      total: intValue(json['total']),
      label: decodedTextValue(json['label'], fallback: 'Coaching CPD Points'),
      thumbnail: stringValue(json['thumbnail']),
      earnings: rawEarnings is List<dynamic>
          ? rawEarnings
              .whereType<Map<String, dynamic>>()
              .map(CpdEarning.fromJson)
              .toList(growable: false)
          : const <CpdEarning>[],
    );
  }
}

class CpdEarning {
  const CpdEarning({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.points,
    required this.pointsLabel,
    required this.thumbnail,
  });

  final int id;
  final String title;
  final String description;
  final String date;
  final int points;
  final String pointsLabel;
  final String thumbnail;

  factory CpdEarning.fromJson(Map<String, dynamic> json) {
    return CpdEarning(
      id: intValue(json['id']),
      title: decodedTextValue(json['title']),
      description: decodedTextValue(json['description']),
      date: decodedTextValue(json['date']),
      points: intValue(json['points']),
      pointsLabel: decodedTextValue(
        json['points_label'],
        fallback: 'Coaching CPD Points',
      ),
      thumbnail: stringValue(json['thumbnail']),
    );
  }
}
