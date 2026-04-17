import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/event_summary.dart';

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(previousEventsProvider);

    return events.when(
      data: (items) => _EventsList(items: items),
      error: (error, _) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.items});

  final List<EventSummary> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No events available yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final event = items[index];
        return SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(event.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(event.excerpt.isEmpty
                  ? 'No summary available.'
                  : event.excerpt),
              const SizedBox(height: 14),
              Text(
                [
                  if (event.startDate.isNotEmpty) event.startDate,
                  if (event.endDate.isNotEmpty) event.endDate,
                ].join(' - '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
