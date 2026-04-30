import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets('group card title is capped to two lines at large text sizes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupsProvider.overrideWith(
            (ref) async => const <GroupSummary>[
              GroupSummary(
                id: 7,
                title: 'OFC Physiotherapists',
                description:
                    'A group to discuss best practice and general chat.',
                type: 'public',
                statusLabel: 'Public',
                createdOn: '',
                imageUrl: '',
                authorImageUrl: '',
                organizerName: '',
                isMember: true,
              ),
            ],
          ),
        ],
        child: const MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            textScaler: TextScaler.linear(2.6),
          ),
          child: MaterialApp(
            home: Scaffold(body: GroupsPage(initialTab: 'my')),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final title = tester.renderObject<RenderParagraph>(
      find.text('OFC Physiotherapists'),
    );

    expect(title.maxLines, 2);
    expect(tester.takeException(), isNull);
  });
}
