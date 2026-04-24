import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    final recordedEvents = ref.watch(recordedEventsProvider);

    return Column(
      children: <Widget>[
        const PageHeader(
          title: 'Events',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(upcomingEventsProvider);
              ref.invalidate(recordedEventsProvider);
              await Future.wait<void>(<Future<void>>[
                ref.read(upcomingEventsProvider.future).then((_) {}),
                ref.read(recordedEventsProvider.future).then((_) {}),
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
                Text(
                  'Recorded webinars to view',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                recordedEvents.when(
                  data: (items) => _RecordedWebinarList(
                    items: items.where((event) => event.hasRecording).toList(),
                    emptyMessage: 'No recorded webinars available yet.',
                  ),
                  error: (error, _) => AsyncStateView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(recordedEventsProvider),
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

class _RecordedWebinarList extends StatelessWidget {
  const _RecordedWebinarList({
    required this.items,
    required this.emptyMessage,
  });

  final List<EventSummary> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AsyncStateView(
        icon: Icons.video_library_outlined,
        message: emptyMessage,
      );
    }

    return Column(
      children: items
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RecordedWebinarCard(event: event),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _RecordedWebinarCard extends StatelessWidget {
  const _RecordedWebinarCard({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(event.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: event.thumbnailImageUrl.isEmpty
                  ? const ColoredBox(
                      color: Color(0xFFE7EEF3),
                      child: Icon(Icons.video_library_outlined, size: 42),
                    )
                  : Image.network(
                      event.thumbnailImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFE7EEF3),
                        child: Icon(Icons.video_library_outlined, size: 42),
                      ),
                    ),
            ),
          ),
          if (_dateRange(event).isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              _dateRange(event),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (event.excerpt.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              event.excerpt,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => _openRecording(context, event),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Recording available - click to view'),
          ),
        ],
      ),
    );
  }

  String _dateRange(EventSummary event) {
    if (event.startDate.isEmpty && event.endDate.isEmpty) {
      return '';
    }

    if (event.startDate.isNotEmpty && event.endDate.isNotEmpty) {
      return '${event.startDate} - ${event.endDate}';
    }

    return event.startDate.isNotEmpty ? event.startDate : event.endDate;
  }

  Future<void> _openRecording(BuildContext context, EventSummary event) async {
    final videoUrl = _recordingPlaybackUrl(event.recordingLink);
    if (videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording link is not valid.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RecordingPlayerPage(
          title: event.title,
          url: videoUrl,
        ),
      ),
    );
  }
}

String? _recordingPlaybackUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme) {
    return null;
  }

  final vimeoUrl = _vimeoPlaybackUrl(uri);
  if (vimeoUrl != null) {
    return vimeoUrl;
  }

  return uri.toString();
}

String? _vimeoPlaybackUrl(Uri uri) {
  final host = uri.host.toLowerCase();
  if (!host.contains('vimeo.com')) {
    return null;
  }

  String? videoId;
  String? hash = uri.queryParameters['h'];
  final segments = uri.pathSegments;
  for (var index = 0; index < segments.length; index += 1) {
    final segment = segments[index];
    if (RegExp(r'^\d+$').hasMatch(segment)) {
      videoId = segment;
      if (hash == null &&
          index + 1 < segments.length &&
          segments[index + 1].isNotEmpty) {
        hash = segments[index + 1];
      }
      break;
    }
  }

  if (videoId == null) {
    return null;
  }

  final embedUri = Uri.parse('https://player.vimeo.com/video/$videoId').replace(
    queryParameters: <String, String>{
      'autoplay': '1',
      if (hash != null && hash.isNotEmpty) 'h': hash,
    },
  );

  return embedUri.toString();
}

class _RecordingPlayerPage extends StatefulWidget {
  const _RecordingPlayerPage({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<_RecordingPlayerPage> createState() => _RecordingPlayerPageState();
}

class _RecordingPlayerPageState extends State<_RecordingPlayerPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
