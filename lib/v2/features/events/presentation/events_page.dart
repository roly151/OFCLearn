import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_shell_page.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/event_summary.dart';

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final previousEvents = ref.watch(previousEventsProvider);

    return Column(
      children: <Widget>[
        const PageHeader(
          title: 'Events',
          subtitle:
              'Upcoming and archived event feeds both route into a shared detail page.',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(upcomingEventsProvider);
              ref.invalidate(previousEventsProvider);
              await Future.wait<void>(<Future<void>>[
                ref.read(upcomingEventsProvider.future).then((_) {}),
                ref.read(previousEventsProvider.future).then((_) {}),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: <Widget>[
                Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                upcomingEvents.when(
                  data: (items) => _EventsList(
                    items: items,
                    emptyMessage: 'No upcoming events available yet.',
                  ),
                  error: (error, _) => AsyncStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(upcomingEventsProvider),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 22),
                Text('Archive', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                previousEvents.when(
                  data: (items) => _EventsList(
                    items: items,
                    emptyMessage: 'No archived events available yet.',
                  ),
                  error: (error, _) => AsyncStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(previousEventsProvider),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.items,
    required this.emptyMessage,
  });

  final List<EventSummary> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AsyncStateView(
        icon: Icons.event_busy_outlined,
        message: emptyMessage,
      );
    }

    return Column(
      children: items
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () =>
                    context.go('/app/${AppTab.events.slug}/event/${event.id}'),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(event.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        event.excerpt.isEmpty
                            ? 'No summary available.'
                            : event.excerpt,
                      ),
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
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
