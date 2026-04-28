import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/app/app_shell_page.dart';
import 'package:ofc_learn_v2/v2/core/config/app_config.dart';
import 'package:ofc_learn_v2/v2/core/dependencies.dart';
import 'package:ofc_learn_v2/v2/core/providers.dart';
import 'package:ofc_learn_v2/v2/features/auth/domain/api_user.dart';
import 'package:ofc_learn_v2/v2/features/auth/domain/auth_session.dart';
import 'package:ofc_learn_v2/v2/features/auth/presentation/auth_controller.dart';
import 'package:ofc_learn_v2/v2/features/library/domain/library_post.dart';
import 'package:ofc_learn_v2/v2/features/messages/domain/message_thread.dart';

void main() {
  testWidgets(
      'app shell keeps profile in the header and out of the bottom navigation',
      (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _TestAuthController()),
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://ofclearn.com/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://ofclearn.com',
            ),
          ),
          libraryPostsProvider.overrideWith(
            (ref) async => const <LibraryPostSummary>[],
          ),
          libraryPostsPageProvider.overrideWith(
            (ref, query) async => const <LibraryPostSummary>[],
          ),
          messageThreadsProvider.overrideWith(
            (ref) async => const <MessageThreadSummary>[],
          ),
        ],
        child: MaterialApp(
          home: AppShellPage(
            currentTab: AppTab.library,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Library'), findsWidgets);
    expect(find.text('Profile'), findsNothing);
    expect(find.byIcon(Icons.library_books_rounded), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
    expect(find.byTooltip('Messages'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
  });

  testWidgets('bottom navigation keeps labels at compact scale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _TestAuthController()),
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              baseUrl: 'https://ofclearn.com/wp-json/ofc-mobile/v1',
              appName: 'OFC Learn v2',
              publicBaseUrl: 'https://ofclearn.com',
            ),
          ),
          libraryPostsProvider.overrideWith(
            (ref) async => const <LibraryPostSummary>[],
          ),
          libraryPostsPageProvider.overrideWith(
            (ref, query) async => const <LibraryPostSummary>[],
          ),
          messageThreadsProvider.overrideWith(
            (ref) async => const <MessageThreadSummary>[],
          ),
        ],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            textScaler: TextScaler.linear(2.6),
          ),
          child: MaterialApp(
            home: AppShellPage(
              currentTab: AppTab.library,
              onTabSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final dashboardLabel =
        tester.renderObject<RenderParagraph>(find.text('Dashboard'));
    final coursesLabel =
        tester.renderObject<RenderParagraph>(find.text('Courses'));

    expect(dashboardLabel.textScaler.scale(12), 12);
    expect(coursesLabel.textScaler.scale(12), 12);
    expect(tester.takeException(), isNull);
  });
}

class _TestAuthController extends AuthController {
  @override
  Future<AuthSession?> build() async {
    return const AuthSession(
      token: 'token',
      siteName: 'OFC Learn',
      homeUrl: 'https://ofclearn.com',
      user: ApiUser(
        id: 1,
        username: 'coach',
        email: 'coach@example.test',
        displayName: 'Coach User',
        firstName: 'Coach',
        lastName: 'User',
        nickname: 'Coach',
        country: '',
        gender: '',
        dateOfBirth: '',
        regionalOrganisation: '',
        avatarUrl: '',
        avatarThumbUrl: '',
        coverUrl: '',
      ),
    );
  }
}
