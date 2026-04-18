import 'package:flutter/material.dart';

import '../../app/v2_theme.dart';

class AmbientScaffold extends StatelessWidget {
  const AmbientScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF6F3EA),
              Color(0xFFE8EDF3),
              Color(0xFFF3EBDA),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -60,
              right: -40,
              child: _GlowBubble(
                color: V2Palette.deepBlue.withValues(alpha: 0.22),
                size: 220,
              ),
            ),
            Positioned(
              bottom: -70,
              left: -10,
              child: _GlowBubble(
                color: V2Palette.foliage.withValues(alpha: 0.12),
                size: 240,
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
