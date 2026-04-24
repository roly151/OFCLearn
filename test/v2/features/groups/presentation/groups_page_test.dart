import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/core/providers.dart';
import 'package:ofc_learn_v2/v2/features/groups/domain/group_summary.dart';
import 'package:ofc_learn_v2/v2/features/groups/presentation/groups_page.dart';

void main() {
  testWidgets('groups page excludes child groups from my groups listing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupsProvider.overrideWith(
            (ref) async => const <GroupSummary>[
              GroupSummary(
                id: 4,
                title: 'Parent Group',
                description: '',
                type: 'public',
                statusLabel: 'Public',
                createdOn: '',
                imageUrl: '',
                authorImageUrl: '',
                organizerName: '',
                isMember: true,
              ),
              GroupSummary(
                id: 18,
                title: 'Child Group',
                description: '',
                type: 'public',
                statusLabel: 'Public',
                createdOn: '',
                imageUrl: '',
                authorImageUrl: '',
                organizerName: '',
                isMember: true,
                parentId: 4,
              ),
            ],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: GroupsPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('My Groups'));
    await tester.pumpAndSettle();

    expect(find.text('Parent Group'), findsOneWidget);
    expect(find.text('Child Group'), findsNothing);
  });
}
