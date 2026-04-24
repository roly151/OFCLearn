import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/v2_theme.dart';
import '../../../core/widgets/section_card.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final user = session?.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: V2Palette.navIndicator,
                child: Text(user.initials),
              ),
              const SizedBox(height: 16),
              Text(user.displayName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user.email),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _ProfileTag(
                      label: user.country.isEmpty
                          ? 'Country unset'
                          : user.country),
                  _ProfileTag(
                      label: user.regionalOrganisation.isEmpty
                          ? 'Region unset'
                          : user.regionalOrganisation),
                  _ProfileTag(
                      label:
                          user.gender.isEmpty ? 'Gender unset' : user.gender),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push('/change-password'),
          icon: const Icon(Icons.lock_reset_rounded),
          label: const Text('Change password'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: V2Palette.seaGlass,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label),
      ),
    );
  }
}
