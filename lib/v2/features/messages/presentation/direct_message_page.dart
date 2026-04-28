import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_shell_page.dart';
import '../../../app/v2_theme.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/message_thread.dart';
import 'message_reply_controller.dart';
import 'message_thread_page.dart';

class DirectMessagePage extends ConsumerStatefulWidget {
  const DirectMessagePage({
    required this.tab,
    required this.userId,
    super.key,
  });

  final AppTab tab;
  final int userId;

  @override
  ConsumerState<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends ConsumerState<DirectMessagePage> {
  late final TextEditingController _messageController;
  late final ScrollController _messagesScrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messagesScrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(MessageThreadDetail thread) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Write a message before sending.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final result = await ref
          .read(messageReplyControllerProvider.notifier)
          .sendDirectMessage(userId: widget.userId, message: message);
      _messageController.clear();
      ref.invalidate(messageThreadsProvider);
      ref.invalidate(directMessageThreadProvider(widget.userId));

      if (!mounted) {
        return;
      }

      if (result.threadId > 0) {
        ref.invalidate(messageThreadProvider(result.threadId));
        context.go('/app/${widget.tab.slug}/messages/${result.threadId}');
        return;
      }

      messenger.showSnackBar(SnackBar(content: Text(result.message)));
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
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(directMessageThreadProvider(widget.userId));
    final replyState = ref.watch(messageReplyControllerProvider);

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _DirectMessageTopBar(
            onBack: () => context.go('/app/${widget.tab.slug}'),
          ),
          Expanded(
            child: threadAsync.when(
              data: (thread) => Column(
                children: <Widget>[
                  Expanded(
                    child: _DirectMessageContent(
                      thread: thread,
                      scrollController: _messagesScrollController,
                    ),
                  ),
                  if (thread.canSendMessage)
                    _DirectMessageComposer(
                      controller: _messageController,
                      isSending: replyState.isLoading,
                      onSend: () => _sendMessage(thread),
                    )
                  else
                    _DirectMessageDisabledNotice(thread: thread),
                ],
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(directMessageThreadProvider(widget.userId)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectMessageTopBar extends StatelessWidget {
  const _DirectMessageTopBar({required this.onBack});

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
          Text('Messages', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _DirectMessageContent extends StatelessWidget {
  const _DirectMessageContent({
    required this.thread,
    required this.scrollController,
  });

  final MessageThreadDetail thread;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final title = thread.title.trim().isEmpty ? 'Conversation' : thread.title;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (thread.subject.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            thread.subject,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: V2Palette.ink.withValues(alpha: 0.82),
                ),
          ),
        ],
        const SizedBox(height: 16),
        if (thread.messages.isEmpty)
          const SectionCard(
            child: _DirectMessageEmptyState(),
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
}

class _DirectMessageEmptyState extends StatelessWidget {
  const _DirectMessageEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.mail_outline_rounded,
          color: V2Palette.primaryBlue,
          size: 32,
        ),
        const SizedBox(height: 10),
        Text(
          'No messages yet.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Send a message to start this conversation.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _DirectMessageComposer extends StatelessWidget {
  const _DirectMessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
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
                enabled: !isSending,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Write a message',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isSending ? null : onSend,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectMessageDisabledNotice extends StatelessWidget {
  const _DirectMessageDisabledNotice({required this.thread});

  final MessageThreadDetail thread;

  @override
  Widget build(BuildContext context) {
    final targetName = thread.connectionRequestName.trim();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SectionCard(
          child: Text(
            targetName.isEmpty
                ? 'Messages are disabled for this member.'
                : 'Messages are disabled for $targetName.',
          ),
        ),
      ),
    );
  }
}
