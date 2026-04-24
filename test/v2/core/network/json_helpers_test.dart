import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/core/network/json_helpers.dart';

void main() {
  test('decodeHtmlText decodes common entities and excerpt artifacts', () {
    expect(decodeHtmlText('Football &amp; Futsal [&hellip;]'),
        'Football & Futsal ...');
    expect(decodeHtmlText('Tom&#39;s&nbsp;Team'), "Tom's Team");
    expect(decodeHtmlText(r"I\'m checking the Vision &amp; Philosophy task"),
        "I'm checking the Vision & Philosophy task");
  });

  test('plainTextFromHtml strips markup and decodes entities', () {
    expect(
      plainTextFromHtml('<p>Coach &amp; Player [&hellip;]</p>'),
      'Coach & Player ...',
    );
  });
}
