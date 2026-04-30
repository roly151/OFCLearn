import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'v2/core/device_orientation_policy.dart';
import 'v2/core/push/push_notification_service.dart';
import 'v2/app/v2_app.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final crashlyticsAvailable = await _initializeCrashReporting();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (crashlyticsAvailable) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (!crashlyticsAvailable) {
        return false;
      }
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseMessaging.onBackgroundMessage(
        ofcFirebaseMessagingBackgroundHandler);
    await lockToAppPortraitOrientations();

    runApp(const ProviderScope(child: V2App()));
  }, (error, stack) async {
    await _recordFatalError(error, stack);
  });
}

Future<bool> _initializeCrashReporting() async {
  try {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _recordFatalError(Object error, StackTrace stack) async {
  try {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  } catch (_) {
    return;
  }
}
