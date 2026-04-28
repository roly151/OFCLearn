import 'dart:async';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_repository.dart';

@pragma('vm:entry-point')
Future<void> ofcFirebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return;
  }
}

class PushNotificationService {
  PushNotificationService(this._repository);

  static const _channel = AndroidNotificationChannel(
    'ofc_learn_messages',
    'OFC Learn notifications',
    description: 'Messages and website notifications from OFC Learn.',
    importance: Importance.high,
  );

  final PushRepository _repository;
  final _routeController = StreamController<String>.broadcast();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseAvailable = false;
  String? _lastRegisteredToken;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;

  Stream<String> get routeStream => _routeController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      await Firebase.initializeApp();
      _firebaseAvailable = true;
    } catch (_) {
      return;
    }

    await _initializeLocalNotifications();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedMessage(initialMessage);
    }
  }

  Future<void> syncToken() async {
    if (!_firebaseAvailable) {
      return;
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }

    _tokenRefreshSubscription ??=
        FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
  }

  Future<void> unregisterCurrentToken() async {
    final token = _lastRegisteredToken;
    _lastRegisteredToken = null;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _repository.deleteToken(token: token);
      await AppBadgePlus.updateBadge(0);
    } catch (_) {
      return;
    }
  }

  Future<void> refreshBadgeCount() async {
    try {
      final count = await _repository.fetchBadgeCount();
      await _setBadge(count);
    } catch (_) {
      return;
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _openSubscription?.cancel();
    _routeController.close();
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _routeController.add(payload);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _registerToken(String token) async {
    try {
      await _repository.registerToken(
        token: token,
        platform: _platformName,
      );
      _lastRegisteredToken = token;
      await refreshBadgeCount();
    } catch (_) {
      return;
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _updateBadgeFromMessage(message);

    final notification = message.notification;
    if (notification == null || kIsWeb) {
      return;
    }

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title ?? 'OFC Learn',
      body: notification.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ofc_learn_messages',
          'OFC Learn notifications',
          channelDescription:
              'Messages and website notifications from OFC Learn.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _routeForMessage(message),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final route = _routeForMessage(message);
    if (route.isNotEmpty) {
      _routeController.add(route);
    }
  }

  Future<void> _updateBadgeFromMessage(RemoteMessage message) async {
    final rawBadge = message.data['badge'];
    final badge = int.tryParse(rawBadge?.toString() ?? '');
    if (badge == null) {
      await refreshBadgeCount();
      return;
    }
    await _setBadge(badge);
  }

  Future<void> _setBadge(int count) async {
    if (kIsWeb) {
      return;
    }

    try {
      await AppBadgePlus.updateBadge(count < 0 ? 0 : count);
    } catch (_) {
      return;
    }
  }

  String _routeForMessage(RemoteMessage message) {
    final route = message.data['route']?.toString().trim() ?? '';
    if (route.startsWith('/app/')) {
      return route;
    }

    final type = message.data['type']?.toString();
    if (type == 'message') {
      final threadId =
          int.tryParse(message.data['thread_id']?.toString() ?? '');
      if (threadId != null && threadId > 0) {
        return '/app/dashboard/messages/$threadId';
      }
      return '/app/dashboard/messages';
    }

    return '/app/dashboard/notifications';
  }

  String get _platformName {
    if (kIsWeb) {
      return 'web';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    return 'unknown';
  }
}
