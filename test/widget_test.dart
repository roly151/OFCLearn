import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ofc_learn_v2/v2/features/auth/presentation/sign_in_page.dart';

void main() {
  testWidgets('sign-in page renders the v2 auth UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('OFC Learn v2'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email or username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
