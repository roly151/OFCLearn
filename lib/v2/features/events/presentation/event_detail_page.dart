import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/event_detail.dart';

class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({
    required this.tab,
    required this.eventId,
    super.key,
  });

  final AppTab tab;
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(eventDetailProvider(eventId));

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _TopBar(onBack: () => context.go('/app/${tab.slug}')),
          const PageHeader(
            title: 'Event detail',
            subtitle:
                'Event detail is resolved from the upcoming and archived feeds because the current API has no dedicated event detail route.',
          ),
          Expanded(
            child: detail.when(
              data: (event) => RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(eventDetailProvider(eventId).future),
                child: _EventDetailContent(event: event),
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text('Event detail', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent({required this.event});

  final EventDetail event;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(event.title,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(
                event.excerpt.isEmpty
                    ? 'No event summary provided.'
                    : event.excerpt,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  if (event.authorName.isNotEmpty)
                    _Chip(label: event.authorName),
                  if (event.status.isNotEmpty) _Chip(label: event.status),
                  if (_dateRange(event).isNotEmpty)
                    _Chip(label: _dateRange(event)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                event.content.isEmpty
                    ? 'No event content yet.'
                    : _stripHtml(event.content),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (event.link.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                Text('Event link',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                SelectableText(event.link),
              ],
              if (event.ervLink.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                Text('Recording link',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                SelectableText(event.ervLink),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _dateRange(EventDetail event) {
    if (event.startDate.isEmpty && event.endDate.isEmpty) {
      return '';
    }

    if (event.startDate.isNotEmpty && event.endDate.isNotEmpty) {
      return '${event.startDate} - ${event.endDate}';
    }

    return event.startDate.isNotEmpty ? event.startDate : event.endDate;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

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

String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
