import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/section_card.dart';
import '../../dashboard/presentation/activity_html_content.dart';
import '../../dashboard/presentation/activity_interaction_widgets.dart';
import '../domain/message_thread.dart';
import 'message_reply_controller.dart';

class MessageThreadPage extends ConsumerStatefulWidget {
  const MessageThreadPage({
    required this.tab,
    required this.threadId,
    super.key,
  });

  final AppTab tab;
  final int threadId;

  @override
  ConsumerState<MessageThreadPage> createState() => _MessageThreadPageState();
}

class _MessageThreadPageState extends ConsumerState<MessageThreadPage> {
  late final TextEditingController _replyController;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final messenger = ScaffoldMessenger.of(context);
    final message = _replyController.text.trim();
    if (message.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Write a reply before sending.')),
      );
      return;
    }

    try {
      final result = await ref
          .read(messageReplyControllerProvider.notifier)
          .sendReply(threadId: widget.threadId, message: message);
      _replyController.clear();
      ref.invalidate(messageThreadProvider(widget.threadId));
      ref.invalidate(messageThreadsProvider);
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(messageThreadProvider(widget.threadId));
    final replyState = ref.watch(messageReplyControllerProvider);

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _ThreadTopBar(
            onBack: () => context.go('/app/${widget.tab.slug}/messages'),
            title: 'Messages',
          ),
          Expanded(
            child: threadAsync.when(
              data: (thread) => Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: <Widget>[
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                thread.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (thread.subtitle.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Text(
                                  thread.subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...thread.messages.map(
                          (message) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MessageCommentTile(message: message),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ReplyComposer(
                    controller: _replyController,
                    isSending: replyState.isLoading,
                    canSend: thread.canSendMessage,
                    onSend: _sendReply,
                  ),
                ],
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(messageThreadProvider(widget.threadId)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadTopBar extends StatelessWidget {
  const _ThreadTopBar({
    required this.onBack,
    required this.title,
  });

  final VoidCallback onBack;
  final String title;

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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class MessageCommentTile extends StatelessWidget {
  const MessageCommentTile({required this.message, super.key});

  final ThreadMessage message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: V2Palette.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ActivityAvatarBadge(
              imageUrl: message.senderAvatarThumbUrl,
              fallbackLabel: _initialsFor(message.senderName),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          message.senderName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        _formatMessageDate(message.sentAt, message.displayDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (message.isMine) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      'You',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: V2Palette.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  ActivityHtmlContent(
                    html: activityContentHtml(
                      rendered: message.messageHtml,
                      plainText: message.messageText,
                    ),
                    onOpenLink: (url) => _openMessageLink(context, url),
                    fontSize: 14,
                    lineHeight: 1.45,
                    paragraphBottomMargin: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatMessageTimestamp(
                        message.sentAt, message.displayDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({
    required this.controller,
    required this.isSending,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SectionCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 5,
                enabled: canSend && !isSending,
                decoration: InputDecoration(
                  hintText: canSend
                      ? 'Reply to this conversation'
                      : 'Replies are disabled for this thread',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  if (!canSend)
                    Expanded(
                      child: Text(
                        'This conversation is read only.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: canSend && !isSending ? onSend : null,
                    icon: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatMessageDate(DateTime? dateTime, String fallback) {
  if (dateTime == null) {
    return fallback;
  }

  final local = dateTime.toLocal();
  return '${local.day} ${_monthLabel(local.month)}';
}

String _formatMessageTimestamp(DateTime? dateTime, String fallback) {
  if (dateTime == null) {
    return fallback;
  }

  final local = dateTime.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_monthLabel(local.month)} ${local.hour}:$minute';
}

String _monthLabel(int month) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}

String _initialsFor(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }

  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

Future<void> _openMessageLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open link.')),
    );
  }
}
