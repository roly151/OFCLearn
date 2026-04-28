import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/message_thread.dart';
import 'message_read_state_controller.dart';
import 'message_reply_controller.dart';
import 'message_thread_page.dart';

class MessagesInboxPage extends ConsumerStatefulWidget {
  const MessagesInboxPage({
    required this.tab,
    super.key,
  });

  final AppTab tab;

  @override
  ConsumerState<MessagesInboxPage> createState() => _MessagesInboxPageState();
}

class _MessagesInboxPageState extends ConsumerState<MessagesInboxPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        setState(() {
          _query = _searchController.text.trim().toLowerCase();
        });
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(messageThreadsProvider);
    final readMarkers = ref.watch(messageReadStateProvider);

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _InboxTopBar(
            title: 'Messages',
            onBack: () => context.go('/app/${widget.tab.slug}'),
          ),
          Expanded(
            child: threadsAsync.when(
              data: (threads) {
                final filteredThreads = threads.where((thread) {
                  if (_query.isEmpty) {
                    return true;
                  }

                  final haystack =
                      '${thread.senderName} ${thread.subject}'.toLowerCase();
                  return haystack.contains(_query);
                }).toList(growable: false);

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(messageThreadsProvider.future),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: <Widget>[
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search by sender or subject',
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filteredThreads.isEmpty)
                        const SectionCard(
                          child: _EmptyState(
                            icon: Icons.mail_outline_rounded,
                            title: 'No conversations yet.',
                            subtitle:
                                'Your BuddyBoss inbox will appear here once messages arrive.',
                          ),
                        )
                      else
                        ...filteredThreads.map(
                          (thread) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ThreadCard(
                              thread: thread,
                              unreadCount: visibleUnreadCountForThread(
                                thread,
                                readMarkers,
                              ),
                              onTap: () => _openThreadSheet(
                                context,
                                thread,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(messageThreadsProvider),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openThreadSheet(
    BuildContext context,
    MessageThreadSummary thread,
  ) async {
    ref.invalidate(messageThreadProvider(thread.id));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _MessageThreadSheet(
        thread: thread,
        onThreadRead: () => _markThreadReadFromServer(thread),
      ),
    );
    if (mounted) {
      ref.invalidate(messageThreadsProvider);
    }
  }

  void _markThreadReadFromServer(MessageThreadSummary thread) {
    if (!mounted || thread.unreadCount <= 0) {
      return;
    }

    ref.read(messageReadStateProvider.notifier).markServerConfirmedRead(thread);
    ref.invalidate(messageThreadsProvider);
  }
}

class _InboxTopBar extends StatelessWidget {
  const _InboxTopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({
    required this.thread,
    required this.unreadCount,
    required this.onTap,
  });

  final MessageThreadSummary thread;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbUrl = thread.avatarThumbUrl.trim();
    final hasUnread = unreadCount > 0;
    final unreadLabel =
        unreadCount == 1 ? '1 new message' : '$unreadCount new messages';
    final cardBorder = hasUnread
        ? V2Palette.primaryBlue.withValues(alpha: 0.55)
        : V2Palette.cardBorder;
    final cardColor = hasUnread
        ? V2Palette.navIndicator.withValues(alpha: 0.55)
        : V2Palette.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: cardBorder,
              width: hasUnread ? 1.4 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (hasUnread) ...<Widget>[
                  Container(
                    width: 5,
                    height: 58,
                    decoration: BoxDecoration(
                      color: V2Palette.primaryBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    _AvatarThumb(url: thumbUrl),
                    if (hasUnread)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: V2Palette.foliage,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cardColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              thread.senderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: hasUnread
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatThreadDate(thread.updatedAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: hasUnread
                                      ? V2Palette.primaryBlue
                                      : V2Palette.muted,
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        thread.subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: V2Palette.ink.withValues(alpha: 0.9),
                              fontWeight:
                                  hasUnread ? FontWeight.w700 : FontWeight.w400,
                            ),
                      ),
                      if (hasUnread) ...<Widget>[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: V2Palette.primaryBlue,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.mark_email_unread_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  unreadLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageThreadSheet extends ConsumerStatefulWidget {
  const _MessageThreadSheet({
    required this.thread,
    required this.onThreadRead,
  });

  final MessageThreadSummary thread;
  final VoidCallback onThreadRead;

  @override
  ConsumerState<_MessageThreadSheet> createState() =>
      _MessageThreadSheetState();
}

class _MessageThreadSheetState extends ConsumerState<_MessageThreadSheet> {
  late final TextEditingController _replyController;
  late final ScrollController _messagesScrollController;
  bool _reportedReadState = false;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    _messagesScrollController = ScrollController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _messagesScrollController.dispose();
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

    FocusScope.of(context).unfocus();
    final existingMessageCount = ref
        .read(messageThreadProvider(widget.thread.id))
        .value
        ?.messages
        .length;

    try {
      final result = await ref
          .read(messageReplyControllerProvider.notifier)
          .sendReply(threadId: widget.thread.id, message: message);
      final refreshedThread =
          await ref.refresh(messageThreadProvider(widget.thread.id).future);
      if (existingMessageCount != null &&
          refreshedThread.messages.length <= existingMessageCount) {
        throw StateError(
          'The reply was not saved by BuddyBoss. Please try again.',
        );
      }

      _replyController.clear();
      ref.invalidate(messageThreadsProvider);
      if (!mounted) {
        return;
      }
      if (refreshedThread.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_messagesScrollController.hasClients) {
            return;
          }

          _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        });
      }
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      final _ =
          await ref.refresh(messageThreadProvider(widget.thread.id).future);
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _requestConnection(MessageThreadDetail thread) async {
    final messenger = ScaffoldMessenger.of(context);
    final userId = thread.connectionRequestUserId;
    if (userId <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Connection request is unavailable.')),
      );
      return;
    }

    try {
      final result = await ref
          .read(messageConnectionControllerProvider.notifier)
          .requestConnection(userId: userId);
      final _ =
          await ref.refresh(messageThreadProvider(widget.thread.id).future);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(messageThreadProvider(widget.thread.id));
    final replyState = ref.watch(messageReplyControllerProvider);
    final connectionState = ref.watch(messageConnectionControllerProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: V2Palette.mist,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: threadAsync.when(
                data: (detail) {
                  _reportThreadReadOnce();

                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: _MessageThreadSheetContent(
                          thread: detail,
                          fallbackSenderName: widget.thread.senderName,
                          scrollController: _messagesScrollController,
                        ),
                      ),
                      if (detail.canSendMessage)
                        _MessageReplyComposer(
                          controller: _replyController,
                          isSending: replyState.isLoading,
                          canSend: detail.canSendMessage,
                          onSend: _sendReply,
                        )
                      else
                        _MessageConnectionPrompt(
                          thread: detail,
                          isSending: connectionState.isLoading,
                          onRequestConnection: () => _requestConnection(detail),
                        ),
                    ],
                  );
                },
                error: (error, _) => AsyncStateView(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(messageThreadProvider(widget.thread.id)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reportThreadReadOnce() {
    if (_reportedReadState || widget.thread.unreadCount <= 0) {
      return;
    }

    _reportedReadState = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.onThreadRead();
    });
  }
}

class _MessageThreadSheetContent extends StatelessWidget {
  const _MessageThreadSheetContent({
    required this.thread,
    required this.fallbackSenderName,
    required this.scrollController,
  });

  final MessageThreadDetail thread;
  final String fallbackSenderName;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final originalSenderName =
        _originalMessage(thread.messages)?.senderName ?? fallbackSenderName;
    final subject = thread.subject.trim();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    originalSenderName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (subject.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: V2Palette.ink.withValues(alpha: 0.82),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (thread.messages.isEmpty)
          const SectionCard(
            child: _EmptyState(
              icon: Icons.mail_outline_rounded,
              title: 'No messages found.',
              subtitle: 'This conversation does not have any visible messages.',
            ),
          )
        else
          ...thread.messages.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MessageCommentTile(message: message),
            ),
          ),
      ],
    );
  }

  ThreadMessage? _originalMessage(List<ThreadMessage> messages) {
    if (messages.isEmpty) {
      return null;
    }

    ThreadMessage original = messages.first;
    for (final message in messages.skip(1)) {
      final sentAt = message.sentAt;
      final originalSentAt = original.sentAt;
      if (sentAt != null &&
          (originalSentAt == null || sentAt.isBefore(originalSentAt))) {
        original = message;
      }
    }

    return original;
  }
}

class _MessageConnectionPrompt extends StatelessWidget {
  const _MessageConnectionPrompt({
    required this.thread,
    required this.isSending,
    required this.onRequestConnection,
  });

  final MessageThreadDetail thread;
  final bool isSending;
  final VoidCallback onRequestConnection;

  @override
  Widget build(BuildContext context) {
    final targetName = thread.connectionRequestName.trim();
    final status = thread.connectionStatus;
    final canRequest = thread.connectionRequired &&
        thread.connectionRequestUserId > 0 &&
        status == 'not_friends';
    final hasPendingRequest = status == 'pending';
    final hasIncomingRequest = status == 'awaiting_response';

    final message = thread.connectionRequired
        ? 'You must be connected to this member to send them a message.'
        : 'Replies are disabled for this thread.';

    final buttonLabel = hasPendingRequest
        ? 'Connection Request Sent'
        : hasIncomingRequest
            ? 'Connection Request Received'
            : 'Send Connection Request';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SectionCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _ConnectionAvatar(
                    imageUrl: thread.connectionRequestAvatarUrl,
                    fallbackLabel:
                        targetName.isNotEmpty ? targetName : thread.title,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (targetName.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            targetName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (thread.connectionRequired) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      canRequest && !isSending ? onRequestConnection : null,
                  icon: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(buttonLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionAvatar extends StatelessWidget {
  const _ConnectionAvatar({
    required this.imageUrl,
    required this.fallbackLabel,
  });

  final String imageUrl;
  final String fallbackLabel;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: V2Palette.navIndicator,
        backgroundImage: NetworkImage(trimmedUrl),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: V2Palette.navIndicator,
      child: Text(_initialsForLabel(fallbackLabel)),
    );
  }
}

class _MessageReplyComposer extends StatelessWidget {
  const _MessageReplyComposer({
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
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                enabled: canSend && !isSending,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
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

class _AvatarThumb extends StatelessWidget {
  const _AvatarThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const CircleAvatar(
        radius: 28,
        backgroundColor: V2Palette.navIndicator,
        child: Icon(Icons.people_alt_outlined),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: V2Palette.navIndicator,
      backgroundImage: NetworkImage(url),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 38, color: V2Palette.muted),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

String _formatThreadDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  final local = dateTime.toLocal();
  final now = DateTime.now();
  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;

  return isToday
      ? DateFormat('h:mm a').format(local)
      : DateFormat('d MMM').format(local);
}

String _initialsForLabel(String value) {
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
