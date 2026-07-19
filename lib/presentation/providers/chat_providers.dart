import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/llm_service_exception.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/enums.dart';
import 'database_providers.dart';
import 'llm_providers.dart';
import 'settings_providers.dart';

/// State of the AI conversation.
class ChatState {
  final String? conversationId;

  /// The scenario prompt sent to the LLM.
  final String scenario;

  /// Human-readable scenario name for the app bar (e.g. "At the Doctor").
  final String scenarioTitle;
  final CEFRLevel level;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  /// Short Czech replies suggested for the learner's next turn. Cleared
  /// when the learner sends a message.
  final List<String> suggestedReplies;

  const ChatState({
    this.conversationId,
    this.scenario = 'Casual conversation',
    this.scenarioTitle = 'AI Tutor',
    this.level = CEFRLevel.a1,
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.suggestedReplies = const [],
  });

  ChatState copyWith({
    String? conversationId,
    String? scenario,
    String? scenarioTitle,
    CEFRLevel? level,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    List<String>? suggestedReplies,
  }) {
    return ChatState(
      conversationId: conversationId ?? this.conversationId,
      scenario: scenario ?? this.scenario,
      scenarioTitle: scenarioTitle ?? this.scenarioTitle,
      level: level ?? this.level,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      suggestedReplies: suggestedReplies ?? this.suggestedReplies,
    );
  }
}

/// Conversation scenarios available for role-play.
class ChatScenario {
  final String title;
  final String description;
  final String prompt;

  const ChatScenario({
    required this.title,
    required this.description,
    required this.prompt,
  });

  static const List<ChatScenario> all = [
    ChatScenario(
      title: 'Casual Chat',
      description: 'Everyday small talk — greetings, weather, how are you',
      prompt: 'Casual conversation between two friends meeting in a café',
    ),
    ChatScenario(
      title: 'At the Restaurant',
      description: 'Order food, ask about menu, pay the bill',
      prompt:
          'You are a waiter at a Czech restaurant. The learner is a customer ordering food',
    ),
    ChatScenario(
      title: 'Asking Directions',
      description: 'Ask for and give directions in the city',
      prompt:
          'The learner is a tourist asking for directions to a landmark in Prague',
    ),
    ChatScenario(
      title: 'Shopping',
      description: 'Buy items, ask prices, negotiate',
      prompt: 'You are a shop assistant. The learner is buying groceries',
    ),
    ChatScenario(
      title: 'At the Doctor',
      description: 'Describe symptoms, make an appointment',
      prompt:
          'You are a Czech doctor. The learner is a patient describing symptoms',
    ),
    ChatScenario(
      title: 'Job Interview',
      description: 'Practice a basic job interview in Czech',
      prompt:
          'You are interviewing the learner for a basic job position. Ask simple questions',
    ),
  ];
}

/// Notifier that manages the AI conversation lifecycle.
class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  /// Start a new conversation with the given scenario.
  /// Defaults to the learner's level from onboarding/settings.
  Future<void> startConversation({
    required ChatScenario scenario,
    CEFRLevel? level,
  }) async {
    // Pre-A1 learners still converse at A1 — it's the simplest tutor level.
    final settingsLevel = ref.read(settingsProvider).startingLevel;
    final effectiveLevel =
        level ?? (settingsLevel == CEFRLevel.a2 ? CEFRLevel.a2 : CEFRLevel.a1);

    final convRepo = ref.read(conversationRepositoryProvider);

    final convId = await convRepo.createConversation(
      scenario.title,
      effectiveLevel.label,
    );

    state = ChatState(
      conversationId: convId,
      scenario: scenario.prompt,
      scenarioTitle: scenario.title,
      level: effectiveLevel,
      messages: [],
    );

    // Send initial greeting from tutor
    await _sendTutorGreeting();
  }

  /// Send a user message and get the AI tutor's response.
  Future<void> sendMessage(String text) async {
    if (state.conversationId == null) return;
    if (state.isLoading) return;

    // Capture the history BEFORE appending the new user message —
    // the orchestrator adds `text` itself, so including it in the
    // history would send it to the model twice.
    final history = state.messages;

    final userMsg = ChatMessage.user(
      text,
      conversationId: state.conversationId,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
      suggestedReplies: const [],
    );

    // Persist user message
    final convRepo = ref.read(conversationRepositoryProvider);
    await convRepo.saveMessage(userMsg);

    try {
      // Build LLM request via orchestrator
      final orchestrator = ref.read(llmOrchestratorProvider);
      final request = orchestrator.buildConversationRequest(
        level: state.level,
        scenario: state.scenario,
        userMessage: text,
        history: history,
      );

      // Call LLM
      final llm = ref.read(llmServiceProvider);
      final response = await llm.complete(request);

      // Parse response
      final tutorResponse = orchestrator.parseTutorResponse(response);

      final tutorMsg = ChatMessage.tutor(
        text: tutorResponse.tutorReplyCz,
        translation: tutorResponse.tutorReplyEn,
        corrections: tutorResponse.corrections,
        newVocabulary: tutorResponse.newVocabulary,
        conversationId: state.conversationId,
      );

      state = state.copyWith(
        messages: [...state.messages, tutorMsg],
        isLoading: false,
        suggestedReplies: tutorResponse.suggestedReplies,
      );

      // Persist tutor message
      await convRepo.saveMessage(tutorMsg);
    } on LlmServiceException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on FormatException {
      state = state.copyWith(
        isLoading: false,
        error: 'The tutor sent an unreadable reply. Please try again.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong getting the tutor\'s reply.',
      );
    }
  }

  /// Load an existing conversation by ID.
  Future<void> loadConversation(String conversationId) async {
    final convRepo = ref.read(conversationRepositoryProvider);
    final messages = await convRepo.getHistory(conversationId);
    state = state.copyWith(conversationId: conversationId, messages: messages);
  }

  /// Clear the current conversation.
  void resetConversation() {
    state = const ChatState();
  }

  /// Send an initial greeting from the tutor.
  Future<void> _sendTutorGreeting() async {
    try {
      final orchestrator = ref.read(llmOrchestratorProvider);
      final request = orchestrator.buildConversationRequest(
        level: state.level,
        scenario: state.scenario,
        userMessage: 'Start the conversation by greeting me.',
        history: [],
      );

      final llm = ref.read(llmServiceProvider);
      final response = await llm.complete(request);
      final tutorResponse = orchestrator.parseTutorResponse(response);

      final greeting = ChatMessage.tutor(
        text: tutorResponse.tutorReplyCz,
        translation: tutorResponse.tutorReplyEn,
        conversationId: state.conversationId,
      );

      state = state.copyWith(
        messages: [greeting],
        suggestedReplies: tutorResponse.suggestedReplies,
      );

      final convRepo = ref.read(conversationRepositoryProvider);
      await convRepo.saveMessage(greeting);
    } catch (e) {
      // If greeting fails, provide a fallback
      final greeting = ChatMessage.tutor(
        text: 'Ahoj! Jsem tvůj učitel češtiny. Jak se jmenuješ?',
        translation: 'Hi! I\'m your Czech teacher. What\'s your name?',
        conversationId: state.conversationId,
      );

      state = state.copyWith(messages: [greeting]);

      final convRepo = ref.read(conversationRepositoryProvider);
      await convRepo.saveMessage(greeting);
    }
  }
}

/// Provider for the chat state.
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
