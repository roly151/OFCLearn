import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/features/library/domain/library_post.dart';

void main() {
  test('library post summary strips html when building the excerpt', () {
    final post = LibraryPostSummary.fromJson(<String, dynamic>{
      'ID': 42,
      'post_title': 'Coach &amp; Education Update',
      'post_content':
          '<p>This is a <strong>library</strong> post with&nbsp;markup [&hellip;]</p>',
      'image': 'https://example.test/image.jpg',
    });

    expect(post.id, 42);
    expect(post.title, 'Coach & Education Update');
    expect(post.excerpt, 'This is a library post with markup ...');
    expect(stripLibraryHtml('<p>Hello<br>world</p>'), 'Hello world');
  });
}
