import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ofc_learn_v2/v2/features/groups/presentation/group_image.dart';

void main() {
  testWidgets('group image uses OFC placeholder for generic BuddyBoss avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GroupImage(
            imageUrl:
                'https://example.test/wp-content/uploads/avatars/mystery-group.png',
            size: 72,
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      kGroupPlaceholderAsset,
    );
  });
}
