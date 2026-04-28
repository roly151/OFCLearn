import 'package:flutter/material.dart';

class CompactTextScale extends StatelessWidget {
  const CompactTextScale({
    required this.child,
    this.maxScaleFactor = 1.15,
    super.key,
  });

  final Widget child;
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return child;
    }

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          maxScaleFactor: maxScaleFactor,
        ),
      ),
      child: child,
    );
  }
}
