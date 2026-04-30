import 'package:flutter/services.dart';

const List<DeviceOrientation> appPortraitOrientations = <DeviceOrientation>[
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
];

const List<DeviceOrientation> videoPlayerOrientations = <DeviceOrientation>[
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

Future<void> lockToAppPortraitOrientations() {
  return SystemChrome.setPreferredOrientations(appPortraitOrientations);
}

Future<void> allowVideoPlayerOrientations() {
  return SystemChrome.setPreferredOrientations(videoPlayerOrientations);
}
