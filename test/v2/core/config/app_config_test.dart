import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/core/config/app_config.dart';

void main() {
  group('AppConfig media headers', () {
    test('keeps host header for matching site media', () {
      const config = AppConfig(
        baseUrl: 'http://10.0.2.2:10018/wp-json/ofc-mobile/v1',
        appName: 'OFC Learn v2',
        publicBaseUrl: 'http://10.0.2.2:10018',
        defaultHeaders: <String, Object>{'Host': 'ofcmulti.test'},
      );

      expect(
        config.mediaHeadersForUrl(
          'https://ofcmulti.test/wp-content/uploads/video.mp4',
        ),
        <String, String>{'Host': 'ofcmulti.test'},
      );
    });

    test('removes host header for external media urls', () {
      const config = AppConfig(
        baseUrl: 'https://ofclearn.com/wp-json/ofc-mobile/v1',
        appName: 'OFC Learn v2',
        publicBaseUrl: 'https://ofclearn.com',
        defaultHeaders: <String, Object>{'Host': 'ofclearn.com'},
      );

      expect(
        config.mediaHeadersForUrl(
          'https://ofclearn.s3.ap-southeast-2.amazonaws.com/video.mp4',
        ),
        isEmpty,
      );
    });
  });

  group('AppConfig BuddyBoss URLs', () {
    test('builds member messages URL from the public site URL', () {
      const config = AppConfig(
        baseUrl: 'https://ofclearn.com/wp-json/ofc-mobile/v1',
        appName: 'OFC Learn v2',
        publicBaseUrl: 'https://ofclearn.com',
      );

      expect(
        config
            .buddyBossMemberUri(username: 'sean', section: 'messages')
            .toString(),
        'https://ofclearn.com/members/sean/messages',
      );
    });

    test('preserves a subdirectory site path for notifications URLs', () {
      const config = AppConfig(
        baseUrl: 'https://example.test/subsite/wp-json/ofc-mobile/v1',
        appName: 'OFC Learn v2',
        publicBaseUrl: 'https://example.test/subsite/',
      );

      expect(
        config
            .buddyBossMemberUri(username: 'jane.doe', section: 'notifications')
            .toString(),
        'https://example.test/subsite/members/jane.doe/notifications',
      );
    });
  });
}
