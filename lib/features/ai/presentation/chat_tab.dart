import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';
import '../../ai/domain/entities/chat_message.dart';
import 'providers/chat_provider.dart';

/// AI financial advisor chat interface.
class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _messageController.clear();
    setState(() => _isTyping = true);
    _scrollToBottom();

    await ref.read(chatProvider.notifier).sendQuery(text);

    if (mounted) {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    ref.listen(chatProvider, (_, _) => _scrollToBottom());

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.15),
                                AppColors.secondary.withValues(alpha: 0.15),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'AI Financial Advisor',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask about spending, budgets, goals, or get personalized advice.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _SuggestionChip(
                              label: 'Where am I spending most?',
                              onTap: () {
                                _messageController.text =
                                    'Where am I spending the most?';
                                _sendMessage();
                              },
                            ),
                            _SuggestionChip(
                              label: 'How is my financial health?',
                              onTap: () {
                                _messageController.text =
                                    'How is my financial health?';
                                _sendMessage();
                              },
                            ),
                            _SuggestionChip(
                              label: 'Spending predictions',
                              onTap: () {
                                _messageController.text =
                                    'What are my spending predictions?';
                                _sendMessage();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == messages.length) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: messages[index]);
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask your financial advisor...',
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isTyping ? null : _sendMessage,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: isUser
              ? null
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppFormatters.time.format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isUser
                    ? Colors.white.withValues(alpha: 0.7)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return _AnimatedDot(index: index);
          }),
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot({required this.index});

  final int index;

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = widget.index * 0.2;
        final value = (_controller.value + delay) % 1.0;
        final opacity = value < 0.5 ? 0.3 + value : 1.3 - value;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: opacity.clamp(0.3, 1.0)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
    );
  }
}
