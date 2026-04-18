import 'package:flutter/material.dart';

import '../../app/v2_theme.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    this.message,
    this.actionLabel,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
    super.key,
  });

  final String? message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 40, color: V2Palette.muted),
              const SizedBox(height: 12),
              Text(
                message ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: Text(actionLabel ?? 'Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
