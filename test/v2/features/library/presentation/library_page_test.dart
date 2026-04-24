import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/core/config/app_config.dart';
import 'package:ofc_learn_v2/v2/core/dependencies.dart';
import 'package:ofc_learn_v2/v2/core/providers.dart';
import 'package:ofc_learn_v2/v2/features/library/domain/library_post.dart';
import 'package:ofc_learn_v2/v2/features/library/presentation/library_page.dart';

void main() {
  LibraryPostSummary buildPost(int id, String title) {
    return LibraryPostSummary.fromJson(<String, dynamic>{
      'ID': id,
      'post_title': title,
      'post_content': '<p>Summary for $title.</p>',
      'post_date_gmt':
          '2026-04-${(30 - id).toString().padLeft(2, '0')} 12:00:00',
      'image': '',
    });
  }

  testWidgets('library page filters posts as the user types', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          libraryPostsPageProvider.overrideWith((ref, query) async {
            if (query.search.toLowerCase() == 'medical' && query.page == 1) {
              return <LibraryPostSummary>[
                buildPost(2, 'Medical Preparation Guide'),
              ];
            }

            if (query.page == 1) {
              return <LibraryPostSummary>[
                buildPost(1, 'Coach Development Plan'),
                buildPost(2, 'Medical Preparation Guide'),
              ];
            }

            return const <LibraryPostSummary>[];
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: LibraryPage())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Coach Development Plan'), findsOneWidget);
    expect(find.text('Medical Preparation Guide'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'medical');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Coach Development Plan'), findsNothing);
    expect(find.text('Medical Preparation Guide'), findsOneWidget);
  });

  testWidgets('library page loads the next batch near the end of the list', (
    WidgetTester tester,
  ) async {
    final requestedPages = <int>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://example.test/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://example.test',
            ),
          ),
          libraryPostsPageProvider.overrideWith((ref, query) async {
            requestedPages.add(query.page);
            if (query.page == 1) {
              return List<LibraryPostSummary>.generate(
                20,
                (index) => buildPost(index + 1, 'Post ${index + 1}'),
              );
            }
            if (query.page == 2) {
              return <LibraryPostSummary>[buildPost(21, 'Post 21')];
            }
            return const <LibraryPostSummary>[];
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: LibraryPage())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Post 1'), findsOneWidget);
    expect(requestedPages, contains(1));

    await tester.drag(find.byType(ListView), const Offset(0, -4000));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(requestedPages, contains(2));
    expect(find.text('Post 21'), findsOneWidget);
  });
}
