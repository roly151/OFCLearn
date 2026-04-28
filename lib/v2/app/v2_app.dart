import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../core/dependencies.dart';
import '../core/providers.dart';
import 'v2_theme.dart';

class V2App extends ConsumerStatefulWidget {
  const V2App({super.key});

  @override
  ConsumerState<V2App> createState() => _V2AppState();
}

class _V2AppState extends ConsumerState<V2App> {
  StreamSubscription<String>? _pushRouteSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePushNotifications();
    });
  }

  Future<void> _initializePushNotifications() async {
    final service = ref.read(pushNotificationServiceProvider);
    await service.initialize();
    _pushRouteSubscription = service.routeStream.listen((route) {
      if (!mounted) {
        return;
      }
      context.go(route);
    });

    if (ref.read(authControllerProvider).asData?.value != null) {
      await service.syncToken();
    }
  }

  @override
  void dispose() {
    _pushRouteSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.listen(authControllerProvider, (previous, next) {
      final service = ref.read(pushNotificationServiceProvider);
      if (next.asData?.value != null) {
        service.syncToken();
      } else if (previous?.asData?.value != null) {
        service.unregisterCurrentToken();
      }
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: V2Palette.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'OFC Learn v2',
      debugShowCheckedModeBanner: false,
      theme: buildV2Theme(),
      routerConfig: router,
    );
  }
}
