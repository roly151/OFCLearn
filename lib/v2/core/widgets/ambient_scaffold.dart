import 'package:flutter/material.dart';

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
              Color(0xFFF6F1E7),
              Color(0xFFE4EFE8),
              Color(0xFFF5E7D8),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -60,
              right: -40,
              child: _GlowBubble(
                color: const Color(0xFF0E6B62).withValues(alpha: 0.14),
                size: 220,
              ),
            ),
            Positioned(
              bottom: -70,
              left: -10,
              child: _GlowBubble(
                color: const Color(0xFFC7922F).withValues(alpha: 0.18),
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
