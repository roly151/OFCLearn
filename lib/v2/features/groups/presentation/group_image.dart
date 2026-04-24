import 'package:flutter/material.dart';

import '../../../app/v2_theme.dart';

const String kGroupPlaceholderAsset = 'assets/images/ofc_group_placeholder.png';

class GroupImage extends StatelessWidget {
  const GroupImage({
    required this.imageUrl,
    required this.size,
    this.borderRadius = 20,
    super.key,
  });

  final String imageUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final trimmedImageUrl = imageUrl.trim();
    final shouldUsePlaceholder =
        trimmedImageUrl.isEmpty || _isGenericBuddyBossAvatar(trimmedImageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.square(
        dimension: size,
        child: shouldUsePlaceholder
            ? const _GroupPlaceholderImage()
            : Image.network(
                trimmedImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _GroupPlaceholderImage(),
              ),
      ),
    );
  }
}

bool _isGenericBuddyBossAvatar(String imageUrl) {
  final normalized = imageUrl.toLowerCase();
  return normalized.contains('mystery') ||
      normalized.contains('avatar-bp') ||
      normalized.contains('gravatar') ||
      normalized.contains('profile-avatar-buddyboss');
}

class _GroupPlaceholderImage extends StatelessWidget {
  const _GroupPlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: V2Palette.primaryBlue,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          kGroupPlaceholderAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
