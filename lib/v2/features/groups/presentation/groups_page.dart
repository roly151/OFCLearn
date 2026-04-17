import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/group_summary.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return groups.when(
      data: (items) => _GroupsList(items: items),
      error: (error, _) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({required this.items});

  final List<GroupSummary> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final group = items[index];
        return SectionCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFD7E6E2),
                child: Text(
                    group.title.isEmpty ? '?' : group.title[0].toUpperCase()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(group.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '${group.organizerName} · ${group.statusLabel}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(group.isMember
                        ? 'You are already in this group.'
                        : 'Open for discovery.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
