import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_subgroup.dart';

void main() {
  test('parses OFC mobile subgroup payload shape', () {
    final subgroup = GroupSubgroup.fromJson(const <String, dynamic>{
      'id': 18,
      'Title': 'Regional Youth Coaches',
      'Description': 'A subgroup for regional collaboration.',
      'Status': 'Public',
      'members_count': '18',
      'Image_link': 'https://example.test/group.jpg',
    });

    expect(subgroup.id, 18);
    expect(subgroup.title, 'Regional Youth Coaches');
    expect(subgroup.description, 'A subgroup for regional collaboration.');
    expect(subgroup.status, 'Public');
    expect(subgroup.membersCount, '18');
    expect(subgroup.imageUrl, 'https://example.test/group.jpg');
  });
}
