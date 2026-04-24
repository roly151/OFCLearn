import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/domain/activity_comment.dart';
import 'package:ofc_learn_v2/v2/features/dashboard/presentation/activity_html_content.dart';

void main() {
  test('activityContentHtml preserves plain-text paragraphs and linkifies URLs',
      () {
    final html = activityContentHtml(
      rendered: 'Hi Adrian,\n\nSee www.sporty.co.nz/report?id=1.',
    );

    expect(html, contains('Hi Adrian,<br><br>See '));
    expect(
      html,
      contains(
        '<a href="https://www.sporty.co.nz/report?id=1">'
        'https://www.sporty.co.nz/report?id=1</a>.',
      ),
    );
  });

  test('activityContentHtml decodes escaped plain-text feed content', () {
    final html = activityContentHtml(
      rendered:
          r"I\'m checking the C Licence Task 1 - Vision &amp; Philosophy Document",
    );

    expect(
      html,
      '<p>I&#39;m checking the C Licence Task 1 - Vision &amp; Philosophy Document</p>',
    );
  });

  test('ActivityComment keeps formatted comment content for rendering', () {
    final comment = ActivityComment.fromJson(<String, dynamic>{
      'comment_id': 12,
      'comment_owner_name': 'Damian Parker',
      'comment_content':
          '<p>Line one</p><p><a href="https://example.test">Line two</a></p>',
    });

    expect(comment.content, 'Line one Line two');
    expect(comment.contentHtml, contains('<p>Line one</p>'));
    expect(comment.contentHtml, contains('href="https://example.test"'));
  });

  test('activityContentHtml does not nest links inside existing anchors', () {
    final html = activityContentHtml(
      rendered:
          '<p><a href="https://example.test">https://example.test</a></p>',
    );

    expect(
      html,
      '<p><a href="https://example.test">https://example.test</a></p>',
    );
  });
}
