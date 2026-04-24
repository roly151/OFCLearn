import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.appName,
    this.publicBaseUrl,
    this.defaultHeaders = const <String, Object>{},
  });

  final String baseUrl;
  final String appName;
  final String? publicBaseUrl;
  final Map<String, Object> defaultHeaders;

  String get wpJsonBaseUrl {
    final publicBase = publicBaseUrl?.trim();
    if (publicBase != null && publicBase.isNotEmpty) {
      return '${publicBase.replaceFirst(RegExp(r'/$'), '')}/wp-json';
    }

    return baseUrl.replaceFirst(RegExp(r'/ofc-mobile/v1/?$'), '');
  }

  String get siteBaseUrl {
    final publicBase = publicBaseUrl?.trim();
    if (publicBase != null && publicBase.isNotEmpty) {
      return publicBase.replaceFirst(RegExp(r'/$'), '');
    }

    return wpJsonBaseUrl.replaceFirst(RegExp(r'/wp-json/?$'), '');
  }

  Uri buddyBossMemberUri({
    required String username,
    required String section,
  }) {
    return Uri.parse(siteBaseUrl).replace(
      pathSegments: <String>[
        ...Uri.parse(siteBaseUrl).pathSegments.where((segment) {
          return segment.isNotEmpty;
        }),
        'members',
        username.trim(),
        section,
      ],
    );
  }

  String resolveMediaUrl(String url) {
    if (url.isEmpty) {
      return url;
    }

    final source = Uri.tryParse(url);
    final targetBase =
        publicBaseUrl == null ? null : Uri.tryParse(publicBaseUrl!);
    if (source == null || targetBase == null || source.host.isEmpty) {
      return url;
    }

    final hostHeader = defaultHeaders['Host']?.toString();
    if (hostHeader == null || source.host != hostHeader) {
      return url;
    }

    return source
        .replace(
          scheme: targetBase.scheme,
          host: targetBase.host,
          port: targetBase.hasPort ? targetBase.port : null,
        )
        .toString();
  }

  Map<String, String> mediaHeadersForUrl(String url) {
    final headers = defaultHeaders.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final hostHeader = headers['Host'];
    if (hostHeader == null || hostHeader.isEmpty) {
      return headers;
    }

    final source = Uri.tryParse(url);
    if (source != null && source.host == hostHeader) {
      return headers;
    }

    return Map<String, String>.of(headers)..remove('Host');
  }

  factory AppConfig.fromEnvironment() {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
    const configuredHostHeader = String.fromEnvironment('API_HOST_HEADER');

    if (configuredBaseUrl.isNotEmpty) {
      return AppConfig(
        baseUrl: configuredBaseUrl,
        appName: 'OFC Learn v2',
        publicBaseUrl: configuredBaseUrl,
        defaultHeaders: configuredHostHeader.isEmpty
            ? <String, Object>{}
            : <String, Object>{'Host': configuredHostHeader},
      );
    }

    // Android emulators cannot resolve Local's `.test` domains directly.
    if (!kIsWeb && Platform.isAndroid) {
      return const AppConfig(
        baseUrl:
            'https://ofclearn.com/wp-json/ofc-mobile/v1', //'http://10.0.2.2:10018/wp-json/ofc-mobile/v1',
        appName: 'OFC Learn v2',
        publicBaseUrl: 'https://ofclearn.com', //'http://10.0.2.2:10018',
        defaultHeaders: <String, Object>{
          'Host': 'ofclearn.com'
        }, //<String, Object>{'Host': 'ofcmulti.test'},
      );
    }

    return const AppConfig(
      baseUrl:
          'https://ofclearn.com/wp-json/ofc-mobile/v1', //'https://ofcmulti.test/wp-json/ofc-mobile/v1',
      appName: 'OFC Learn v2',
      publicBaseUrl: 'https://ofclearn.com', //'https://ofcmulti.test',
    );
  }
}
