import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/compact_text_scale.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/user_notification_item.dart';
import 'notification_action_controller.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({
    required this.tab,
    super.key,
  });

  final AppTab tab;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _status = 'unread';

  Future<void> _markAllRead() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref
          .read(notificationActionControllerProvider.notifier)
          .markAllRead();
      ref.invalidate(notificationsProvider(_status));
      ref.invalidate(notificationsProvider('all'));
      ref.invalidate(notificationsProvider('unread'));
      ref.invalidate(notificationsProvider('read'));
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider(_status));
    final actionState = ref.watch(notificationActionControllerProvider);

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _NotificationsTopBar(
            onBack: () => context.go('/app/${widget.tab.slug}'),
            onMarkAllRead: actionState.isLoading ? null : _markAllRead,
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (items) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _FilterChip(
                        label: 'Unread',
                        selected: _status == 'unread',
                        onSelected: () => setState(() => _status = 'unread'),
                      ),
                      _FilterChip(
                        label: 'Read',
                        selected: _status == 'read',
                        onSelected: () => setState(() => _status = 'read'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const SectionCard(
                      child: _NotificationsEmptyState(),
                    )
                  else
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationCard(
                          item: item,
                          isBusy: actionState.isLoading,
                        ),
                      ),
                    ),
                ],
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(notificationsProvider(_status)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTopBar extends StatelessWidget {
  const _NotificationsTopBar({
    required this.onBack,
    required this.onMarkAllRead,
  });

  final VoidCallback onBack;
  final VoidCallback? onMarkAllRead;

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
          Expanded(
            child: CompactTextScale(
              child: Text(
                'Notifications',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          CompactTextScale(
            child: TextButton(
              onPressed: onMarkAllRead,
              child: const Text(
                'Mark all read',
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return CompactTextScale(
      child: ChoiceChip(
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({
    required this.item,
    required this.isBusy,
  });

  final UserNotificationItem item;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> runAction(
      Future<void> Function() action,
    ) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await action();
        ref.invalidate(notificationsProvider('all'));
        ref.invalidate(notificationsProvider('read'));
        ref.invalidate(notificationsProvider('unread'));
      } catch (error) {
        messenger.showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: V2Palette.navIndicator,
                backgroundImage: item.avatarThumbUrl.trim().isEmpty
                    ? null
                    : NetworkImage(item.avatarThumbUrl),
                child: item.avatarThumbUrl.trim().isEmpty
                    ? const Icon(Icons.notifications_none_rounded)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _formatNotificationDate(item.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (item.isNew)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: V2Palette.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Html(
                      data: item.descriptionHtml.isEmpty
                          ? item.descriptionText
                          : item.descriptionHtml,
                      onLinkTap: (url, _, __) async {
                        if (url == null || url.isEmpty) {
                          return;
                        }
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      style: <String, Style>{
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          color: V2Palette.ink,
                          fontSize: FontSize(15),
                          lineHeight: const LineHeight(1.45),
                        ),
                        'p': Style(margin: Margins.only(bottom: 10)),
                        'a': Style(
                          color: V2Palette.primaryBlue,
                          textDecoration: TextDecoration.underline,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              if (item.link.trim().isNotEmpty)
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(item.link),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open'),
                ),
              if (item.isNew)
                FilledButton.tonalIcon(
                  onPressed: isBusy
                      ? null
                      : () => runAction(() async {
                            final result = await ref
                                .read(notificationActionControllerProvider
                                    .notifier)
                                .markRead(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.message)),
                            );
                          }),
                  icon: const Icon(Icons.done_rounded),
                  label: const Text('Mark read'),
                ),
              OutlinedButton.icon(
                onPressed: isBusy
                    ? null
                    : () => runAction(() async {
                          final result = await ref
                              .read(
                                  notificationActionControllerProvider.notifier)
                              .dismiss(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        }),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Dismiss'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const CircleAvatar(
          radius: 20,
          backgroundColor: V2Palette.primaryBlue,
          child: Icon(Icons.info_outline_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'You have no notifications in this view.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

String _formatNotificationDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat('d MMM yyyy, h:mm a').format(dateTime.toLocal());
}
