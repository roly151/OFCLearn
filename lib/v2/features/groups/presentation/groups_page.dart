import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/group_summary.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return Column(
      children: <Widget>[
        const PageHeader(
          title: 'Groups',
          subtitle:
              'List, inspect, and migrate community flows with real group detail and feed routes.',
        ),
        Expanded(
          child: groups.when(
            data: (items) => _GroupsList(items: items),
            error: (error, _) => AsyncStateView(
              message: error.toString(),
              onRetry: () => ref.invalidate(groupsProvider),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({required this.items});

  final List<GroupSummary> items;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final container = ProviderScope.containerOf(context, listen: false);
        container.invalidate(groupsProvider);
        await container.read(groupsProvider.future);
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final group = items[index];
          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => context.go('/app/groups/group/${group.id}'),
            child: SectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFD7E6E2),
                    child: Text(
                      group.title.isEmpty ? '?' : group.title[0].toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          group.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${group.organizerName} · ${group.statusLabel}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          group.isMember
                              ? 'You are already in this group.'
                              : 'Open for discovery.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
