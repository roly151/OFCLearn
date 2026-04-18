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

  String resolveMediaUrl(String url) {
    if (url.isEmpty) {
      return url;
    }

    final source = Uri.tryParse(url);
    final targetBase = publicBaseUrl == null ? null : Uri.tryParse(publicBaseUrl!);
    if (source == null || targetBase == null || source.host.isEmpty) {
      return url;
    }

    final hostHeader = defaultHeaders['Host']?.toString();
    if (hostHeader == null || source.host != hostHeader) {
      return url;
    }

    return source.replace(
      scheme: targetBase.scheme,
      host: targetBase.host,
      port: targetBase.hasPort ? targetBase.port : null,
    ).toString();
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
        baseUrl: 'http://10.0.2.2:10018/wp-json/ofc-mobile/v1',
        appName: 'OFC Learn v2',
        publicBaseUrl: 'http://10.0.2.2:10018',
        defaultHeaders: <String, Object>{'Host': 'ofcmulti.test'},
      );
    }

    return const AppConfig(
      baseUrl: 'https://ofcmulti.test/wp-json/ofc-mobile/v1',
      appName: 'OFC Learn v2',
      publicBaseUrl: 'https://ofcmulti.test',
    );
  }
}
