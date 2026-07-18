import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/chat_message.dart';
import '../../providers/chat_providers.dart';
import '../../providers/stt_providers.dart';
import '../../providers/tts_providers.dart';
import '../../providers/database_providers.dart';
import '../../providers/review_providers.dart';

/// AI conversation screen — role-play scenarios with AI Czech tutor.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isListening = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Capture Czech speech and put the transcription into the input field
  /// for the learner to review (and fix) before sending.
  Future<void> _startVoiceInput() async {
    if (_isListening) return;
    setState(() => _isListening = true);
    try {
      final stt = ref.read(sttServiceProvider) as NativeSttService;
      final transcription =
          await stt.listenFor(timeout: const Duration(seconds: 10));
      if (!mounted) return;
      if (transcription.isNotEmpty) {
        _inputController.text = transcription;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Speech recognition failed. Check microphone permissions.',),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isListening = false);
    }
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

    // Scroll to the bottom whenever a new message arrives (including the
    // async tutor reply) or the typing indicator toggles.
    ref.listen(chatProvider, (prev, next) {
      if (prev == null) return;
      if (prev.messages.length != next.messages.length ||
          prev.isLoading != next.isLoading) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chat.conversationId != null ? chat.scenarioTitle : 'AI Tutor',
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
          ? const _ScenarioPicker()
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
                      );
                    },
                  ),
                ),
                // Error message
                if (chat.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4,),
                    child: Text(
                      chat.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                // Suggested replies — tap to prefill, learner reviews
                // before sending.
                if (chat.suggestedReplies.isNotEmpty && !chat.isLoading)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: chat.suggestedReplies.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final suggestion = chat.suggestedReplies[i];
                        return ActionChip(
                          avatar: const Icon(Icons.lightbulb_outline,
                              size: 16,),
                          label: Text(suggestion),
                          onPressed: () {
                            _inputController.text = suggestion;
                          },
                        );
                      },
                    ),
                  ),
                // Input bar
                _InputBar(
                  controller: _inputController,
                  onSend: _sendMessage,
                  isLoading: chat.isLoading,
                  isListening: _isListening,
                  onMic: _startVoiceInput,
                ),
              ],
            ),
    );
  }
}

/// Scenario picker — shown when no conversation is active.
class _ScenarioPicker extends ConsumerWidget {
  const _ScenarioPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
class _MessageBubble extends ConsumerWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  /// Add a tutor-suggested word to the SRS deck and confirm via snackbar.
  Future<void> _addVocabToDeck(
      BuildContext context, WidgetRef ref, NewVocabulary v,) async {
    final repo = ref.read(vocabularyRepositoryProvider);
    final added = await repo.addManualCard(cz: v.cz, en: v.en, ipa: v.ipa);
    ref.invalidate(dueCardCountProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added
            ? 'Added "${v.cz}" to your review deck'
            : '"${v.cz}" is already in your deck'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    ),),
              ],
              // New vocabulary
              if (message.newVocabulary != null &&
                  message.newVocabulary!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: message.newVocabulary!.map((v) {
                    return ActionChip(
                      label: Text('${v.cz} = ${v.en}'),
                      avatar: const Icon(Icons.add, size: 16),
                      tooltip: 'Add to review deck',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _addVocabToDeck(context, ref, v),
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
class _TtsIconButton extends ConsumerWidget {
  final String text;

  const _TtsIconButton({required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(0),
              SizedBox(width: 4),
              _Dot(200),
              SizedBox(width: 4),
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

/// Input bar with text field, voice input, and send button.
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool isListening;
  final VoidCallback onMic;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.isListening,
    required this.onMic,
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
                  hintText: isListening
                      ? 'Listening... speak Czech'
                      : 'Type in Czech...',
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
            IconButton(
              onPressed: isLoading || isListening ? null : onMic,
              icon: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Speak your reply',
            ),
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