import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/app/app_shell_page.dart';
import 'package:ofc_learn_v2/v2/core/providers.dart';
import 'package:ofc_learn_v2/v2/features/notifications/domain/user_notification_item.dart';
import 'package:ofc_learn_v2/v2/features/notifications/presentation/notifications_page.dart';

void main() {
  testWidgets(
      'notifications header title stays on one line at large text sizes',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsProvider.overrideWith(
            (ref, status) async => const <UserNotificationItem>[],
          ),
        ],
        child: const MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            textScaler: TextScaler.linear(2.6),
          ),
          child: MaterialApp(
            home: NotificationsPage(tab: AppTab.dashboard),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final title = tester.renderObject<RenderParagraph>(
      find.text('Notifications'),
    );

    expect(title.maxLines, 1);
    expect(tester.takeException(), isNull);
  });
}
