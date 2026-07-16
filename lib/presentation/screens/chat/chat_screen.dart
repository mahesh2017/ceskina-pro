import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/chat_message.dart';
import '../../providers/chat_providers.dart';
import '../../providers/tts_providers.dart';

/// AI conversation screen — role-play scenarios with AI Czech tutor.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
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

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chat.conversationId != null
              ? chat.scenario.split('.').first
              : 'AI Tutor',
        ),
        actions: [
          if (chat.conversationId != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(chatProvider.notifier).resetConversation();
              },
              tooltip: 'End conversation',
            ),
        ],
      ),
      body: chat.conversationId == null
          ? _ScenarioPicker(ref: ref)
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chat.messages.length && chat.isLoading) {
                        return const _TypingIndicator();
                      }
                      return _MessageBubble(
                        message: chat.messages[index],
                        ref: ref,
                      );
                    },
                  ),
                ),
                // Error message
                if (chat.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Text(
                      chat.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                // Input bar
                _InputBar(
                  controller: _inputController,
                  onSend: _sendMessage,
                  isLoading: chat.isLoading,
                ),
              ],
            ),
    );
  }
}

/// Scenario picker — shown when no conversation is active.
class _ScenarioPicker extends StatelessWidget {
  final WidgetRef ref;

  const _ScenarioPicker({required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choose a conversation scenario',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Practice Czech with an AI tutor in real-life situations.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 24),
        ...ChatScenario.all.map((scenario) {
          return Card(
            child: ListTile(
              leading: _scenarioIcon(scenario.title),
              title: Text(scenario.title),
              subtitle: Text(scenario.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ref.read(chatProvider.notifier).startConversation(
                      scenario: scenario,
                    );
              },
            ),
          );
        }),
      ],
    );
  }

  Icon _scenarioIcon(String title) {
    return switch (title) {
      'Casual Chat' => const Icon(Icons.coffee, color: Colors.brown),
      'At the Restaurant' => const Icon(Icons.restaurant, color: Colors.orange),
      'Asking Directions' => const Icon(Icons.map, color: Colors.blue),
      'Shopping' => const Icon(Icons.shopping_bag, color: Colors.purple),
      'At the Doctor' => const Icon(Icons.medical_services, color: Colors.red),
      'Job Interview' => const Icon(Icons.work, color: Colors.teal),
      _ => const Icon(Icons.chat),
    };
  }
}

/// Chat message bubble with corrections and TTS.
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final WidgetRef ref;

  const _MessageBubble({required this.message, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Czech text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(width: 4),
                    _TtsIconButton(
                      text: message.content,
                      ref: ref,
                    ),
                  ],
                ],
              ),
              // English translation (tutor only)
              if (!isUser && message.translation != null) ...[
                const SizedBox(height: 6),
                Text(
                  message.translation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
              // Corrections
              if (message.corrections != null &&
                  message.corrections!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...message.corrections!.map((c) => _CorrectionCard(
                      correction: c,
                    )),
              ],
              // New vocabulary
              if (message.newVocabulary != null &&
                  message.newVocabulary!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: message.newVocabulary!.map((v) {
                    return Chip(
                      label: Text('${v.cz} = ${v.en}'),
                      avatar: const Icon(Icons.book, size: 16),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small TTS icon button for message bubbles.
class _TtsIconButton extends StatelessWidget {
  final String text;
  final WidgetRef ref;

  const _TtsIconButton({required this.text, required this.ref});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ref.read(czechTtsProvider).speak(text);
      },
      icon: const Icon(Icons.volume_up, size: 18),
      color: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip: 'Listen',
    );
  }
}

/// Correction card — shows a grammar correction inline.
class _CorrectionCard extends StatelessWidget {
  final Correction correction;

  const _CorrectionCard({required this.correction});

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (correction.severity) {
      Severity.error => Colors.red,
      Severity.minor => Colors.orange,
      Severity.stylistic => Colors.blue,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: severityColor),
              const SizedBox(width: 4),
              Text(
                correction.type.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: correction.userSaid,
                  style: TextStyle(
                    color: severityColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const TextSpan(text: ' → '),
                TextSpan(
                  text: correction.correct,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            correction.rule,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Typing indicator shown while waiting for LLM response.
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(0),
              const SizedBox(width: 4),
              _Dot(200),
              const SizedBox(width: 4),
              _Dot(400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot(this.delay);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: opacity * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Input bar with text field and send button.
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Type in Czech...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isLoading ? null : onSend,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}