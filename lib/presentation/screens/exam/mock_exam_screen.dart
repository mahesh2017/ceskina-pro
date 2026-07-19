import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/engines/exam_grader.dart';
import '../../../domain/engines/pronunciation_scorer.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/exam_result.dart';
import '../../../domain/repositories/exam_repository.dart';
import '../../providers/database_providers.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/stt_providers.dart';
import '../../providers/writing_providers.dart';
import '../../widgets/lesson/exercise_widget.dart' show TtsButton;

/// Mock exam screen — timed sections matching CCE format.
class MockExamScreen extends ConsumerStatefulWidget {
  final ExamLevel level;

  const MockExamScreen({super.key, required this.level});

  @override
  ConsumerState<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends ConsumerState<MockExamScreen> {
  MockExam? _exam;
  int _currentSection = 0;
  int _currentQuestion = 0;

  /// Answers keyed by section index, then question index — sections must
  /// never share slots (grading regressed once because they did).
  final Map<int, Map<int, dynamic>> _answers = {};

  Timer? _timer;
  int _secondsLeft = 0;
  bool _examStarted = false;
  bool _examComplete = false;
  bool _finishing = false;
  ExamResult? _result;

  /// Externally produced section scores (0-100).
  int? _writingScore;
  int? _speakingScore;

  // Speaking section state
  bool _isRecordingSpeaking = false;
  String? _speakingTranscription;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadExam() async {
    final exam =
        await ref.read(examRepositoryProvider).getMockExam(widget.level);
    if (mounted) setState(() => _exam = exam);
  }

  void _startExam() {
    if (_exam == null) return;
    ref.read(writingEvalProvider.notifier).reset();
    setState(() {
      _examStarted = true;
      _currentSection = 0;
      _currentQuestion = 0;
      _answers.clear();
      _writingScore = null;
      _speakingScore = null;
      _speakingTranscription = null;
      _examComplete = false;
      _result = null;
    });
    _startSectionTimer();
  }

  void _startSectionTimer() {
    _timer?.cancel();
    final section = _exam!.sections[_currentSection];
    setState(() => _secondsLeft = section.timeLimitMinutes * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          timer.cancel();
          _nextSection();
        }
      });
    });
  }

  dynamic get _currentAnswer => _answers[_currentSection]?[_currentQuestion];

  void _answer(dynamic answer) {
    setState(() {
      _answers.putIfAbsent(_currentSection, () => {})[_currentQuestion] =
          answer;
    });
  }

  void _nextQuestion() {
    final section = _exam!.sections[_currentSection];
    if (_currentQuestion < section.questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      _nextSection();
    }
  }

  void _nextSection() {
    _timer?.cancel();
    if (_currentSection < _exam!.sections.length - 1) {
      setState(() {
        _currentSection++;
        _currentQuestion = 0;
      });
      _startSectionTimer();
    } else {
      _finishExam();
    }
  }

  Future<void> _finishExam() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();

    // Evaluate writing now if the learner wrote something but never
    // pressed "Evaluate with AI" before time ran out.
    if (_writingScore == null) {
      final writingText = _writingSectionText();
      if (writingText != null && writingText.trim().isNotEmpty) {
        setState(() {}); // show the "evaluating" spinner state
        final eval = await ref.read(writingEvalProvider.notifier).evaluate(
              level:
                  widget.level == ExamLevel.a1 ? CEFRLevel.a1 : CEFRLevel.a2,
              taskDescription: _writingSectionPrompt() ?? '',
              learnerText: writingText,
            );
        _writingScore = eval?.overall;
      }
    }

    final scores = ExamGrader().grade(
      exam: _exam!,
      answers: _answers,
      writingScore: _writingScore,
      speakingScore: _speakingScore,
    );

    final result = ExamResult(
      id: 0, // assigned by the database
      level: widget.level,
      takenAt: DateTime.now(),
      readingScore: scores.reading,
      listeningScore: scores.listening,
      writingScore: scores.writing,
      speakingScore: scores.speaking,
      totalScore: scores.total,
      passed: scores.passed,
    );

    // Persist the attempt, award XP, record the pass. None of these
    // should block showing the result screen.
    ExamResult persisted = result;
    try {
      persisted = await ref.read(examRepositoryProvider).saveResult(result);
    } catch (_) {
      // Result still shown; only history is lost — but say so.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Could not save this result to your exam history.'),
          ),
        );
      }
    }
    if (result.passed) {
      try {
        await ref
            .read(progressRepositoryProvider)
            .recordExamPassed(widget.level.name);
      } catch (_) {}
    }
    unawaited(
        ref.read(gamificationProvider.notifier).onMockExamCompleted(),);

    if (!mounted) return;
    setState(() {
      _examComplete = true;
      _result = persisted;
      _finishing = false;
    });
  }

  String? _writingSectionText() {
    for (var s = 0; s < _exam!.sections.length; s++) {
      if (_exam!.sections[s].type == ExamSectionType.writing) {
        return _answers[s]?[0] as String?;
      }
    }
    return null;
  }

  String? _writingSectionPrompt() {
    for (final section in _exam!.sections) {
      if (section.type == ExamSectionType.writing) {
        return section.questions.first['prompt'] as String?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_examStarted && !_examComplete) {
      return _buildIntroScreen();
    }
    if (_examComplete && _result != null) {
      return _buildResultScreen();
    }
    return _buildExamScreen();
  }

  Widget _buildIntroScreen() {
    return Scaffold(
      appBar: AppBar(
          title: Text('Mock Exam — ${widget.level.name.toUpperCase()}'),),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'CCE-${widget.level.name.toUpperCase()} Mock Exam',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'This exam has 4 timed sections:\n\n'
                '📖 Reading — comprehension questions\n'
                '🎧 Listening — audio + questions\n'
                '✍️ Writing — short text (AI evaluated)\n'
                '🎤 Speaking — read aloud, scored by speech recognition\n\n'
                'You can answer questions in order. The timer runs per section.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_exam != null) ...[
                Text(
                  'Total time: ${_exam!.totalTimeMinutes} minutes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _startExam,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Exam'),
                ),
              ] else ...[
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamScreen() {
    if (_finishing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grading...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Evaluating your answers...'),
            ],
          ),
        ),
      );
    }

    final section = _exam!.sections[_currentSection];
    final question = section.questions[_currentQuestion];
    final totalQuestions = section.questions.length;
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmExit();
        if (leave && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            final leave = await _confirmExit();
            if (leave && mounted) Navigator.of(context).pop();
          },
        ),
        title: Text(
            '${section.type.name[0].toUpperCase()}${section.type.name.substring(1)} — $minutes:${seconds.toString().padLeft(2, '0')}',),
        actions: [
          Center(
            child: Text(
              'Q${_currentQuestion + 1}/$totalQuestions',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _secondsLeft / (section.timeLimitMinutes * 60),
                minHeight: 4,
                backgroundColor: Colors.red.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _secondsLeft < 60 ? Colors.red : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Question
            Expanded(
              child: _buildQuestion(section.type, question),
            ),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestion > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentQuestion--),
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 80),
                FilledButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestion < totalQuestions - 1
                        ? 'Next'
                        : _currentSection < _exam!.sections.length - 1
                            ? 'Next Section'
                            : 'Finish Exam',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Confirm before abandoning an in-progress exam attempt.
  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave exam?'),
        content: const Text(
            'Your exam is in progress and will not be scored if you leave now.',),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildQuestion(ExamSectionType type, Map<String, dynamic> question) {
    switch (type) {
      case ExamSectionType.reading:
        return _buildChoiceQuestion(question);
      case ExamSectionType.listening:
        return _buildListeningQuestion(question);
      case ExamSectionType.writing:
        return _buildWritingQuestion(question);
      case ExamSectionType.speaking:
        return _buildSpeakingQuestion(question);
    }
  }

  Widget _buildChoiceQuestion(Map<String, dynamic> question) {
    final prompt = question['prompt'] as String;
    final options = (question['options'] as List<dynamic>).cast<String>();
    final selected = _currentAnswer;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question['passage'] != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question['passage'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            prompt,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isSelected = selected == idx;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  leading: Text(
                    String.fromCharCode(65 + idx),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Text(option),
                  onTap: () => _answer(idx),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListeningQuestion(Map<String, dynamic> question) {
    final audioText = question['audio_text'] as String? ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio player — the spoken text is deliberately never displayed.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TtsButton(text: audioText, size: 40),
                  const SizedBox(width: 8),
                  const Text('Tap to play the audio'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChoiceBody(question),
        ],
      ),
    );
  }

  Widget _buildChoiceBody(Map<String, dynamic> question) {
    final prompt = question['prompt'] as String;
    final options = (question['options'] as List<dynamic>).cast<String>();
    final selected = _currentAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isSelected = selected == idx;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: ListTile(
                leading: Text(
                  String.fromCharCode(65 + idx),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(option),
                onTap: () => _answer(idx),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,)
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWritingQuestion(Map<String, dynamic> question) {
    final writingState = ref.watch(writingEvalProvider);
    final learnerText = _currentAnswer as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['prompt'] as String,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Write ${question['min_words'] ?? 30}+ words in Czech.',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            enabled: !writingState.isEvaluating,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Napište svou odpověď v češtině...',
            ),
            onChanged: _answer,
          ),
        ),
        // AI evaluation feedback
        if (writingState.isEvaluating) ...[
          const SizedBox(height: 12),
          const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('AI evaluating your writing...'),
            ],
          ),
        ],
        if (writingState.evaluation != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Feedback — Score: ${writingState.evaluation!.overall}/100',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _MiniScoreRow(
                      label: 'Grammar',
                      score: writingState.evaluation!.grammar,),
                  _MiniScoreRow(
                      label: 'Vocabulary',
                      score: writingState.evaluation!.vocabulary,),
                  _MiniScoreRow(
                      label: 'Coherence',
                      score: writingState.evaluation!.coherence,),
                  const SizedBox(height: 8),
                  Text(
                    writingState.evaluation!.feedback,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (writingState.error != null) ...[
          const SizedBox(height: 12),
          Text(
            writingState.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (!writingState.isEvaluating &&
            writingState.evaluation == null &&
            learnerText.isNotEmpty) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final eval =
                  await ref.read(writingEvalProvider.notifier).evaluate(
                        level: widget.level == ExamLevel.a1
                            ? CEFRLevel.a1
                            : CEFRLevel.a2,
                        taskDescription: question['prompt'] as String,
                        learnerText: learnerText,
                      );
              if (eval != null) {
                setState(() => _writingScore = eval.overall);
              }
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Evaluate with AI'),
          ),
        ],
      ],
    );
  }

  Widget _buildSpeakingQuestion(Map<String, dynamic> question) {
    final targetText = question['target_text'] as String;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question['prompt'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    targetText,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TtsButton(text: targetText, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the microphone and read the text aloud. Speech recognition '
            'scores your pronunciation.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _isRecordingSpeaking ? null : () => _recordSpeaking(targetText),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecordingSpeaking
                      ? Colors.red.shade400
                      : Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  _isRecordingSpeaking ? Icons.hearing : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecordingSpeaking
                ? 'Listening...'
                : _speakingScore != null
                    ? 'Scored! Tap the mic to try again.'
                    : 'Tap to record',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (_speakingScore != null) ...[
            const SizedBox(height: 16),
            Text(
              '$_speakingScore / 100',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _speakingScore! >= 60 ? Colors.green : Colors.orange,
              ),
            ),
            if (_speakingTranscription != null &&
                _speakingTranscription!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Heard: "$_speakingTranscription"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _recordSpeaking(String targetText) async {
    setState(() => _isRecordingSpeaking = true);
    try {
      final stt = ref.read(sttServiceProvider) as NativeSttService;
      final transcription =
          await stt.listenFor(timeout: const Duration(seconds: 12));

      final result = PronunciationScorer().score(
        expectedText: targetText,
        actualTranscription: transcription,
      );

      if (!mounted) return;
      setState(() {
        _isRecordingSpeaking = false;
        _speakingTranscription = transcription;
        _speakingScore = (result.overallScore * 100).round();
      });
      _answer(_speakingScore); // mark the question as answered
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRecordingSpeaking = false;
        _speakingTranscription = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Speech recognition failed. Check microphone permissions.',),
        ),
      );
    }
  }

  Widget _buildResultScreen() {
    final passed = _result!.passed;
    final color = passed ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.cancel,
                size: 80,
                color: color,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Gratulujeme! Passed!' : 'Neprošli jste. Not passed.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ScoreRow(
                        label: 'Reading',
                        score: _result!.readingScore,
                      ),
                      const Divider(),
                      _ScoreRow(
                        label: 'Listening',
                        score: _result!.listeningScore,
                      ),
                      const Divider(),
                      _ScoreRow(
                        label: 'Writing',
                        score: _result!.writingScore,
                      ),
                      const Divider(),
                      _ScoreRow(
                        label: 'Speaking',
                        score: _result!.speakingScore,
                      ),
                      const Divider(),
                      _ScoreRow(
                        label: 'Overall',
                        score: _result!.totalScore,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Answer review — what was right and wrong, per question.
              _buildAnswerReview(),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Per-question review of the choice sections (reading + listening),
  /// shown after the exam so mistakes become learning material.
  Widget _buildAnswerReview() {
    final entries = <Widget>[];

    for (var s = 0; s < _exam!.sections.length; s++) {
      final section = _exam!.sections[s];
      if (section.type != ExamSectionType.reading &&
          section.type != ExamSectionType.listening) {
        continue;
      }

      entries.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            section.type == ExamSectionType.reading
                ? 'Reading'
                : 'Listening',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),);

      for (var q = 0; q < section.questions.length; q++) {
        final question = section.questions[q];
        final options =
            (question['options'] as List<dynamic>?)?.cast<String>();
        final correctIdx = question['correct_answer'];
        if (options == null || correctIdx is! int) continue;

        final userIdx = _answers[s]?[q];
        final isCorrect = userIdx == correctIdx;
        final audioText = question['audio_text'] as String?;

        entries.add(Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question['prompt'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (audioText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Audio said: "$audioText"',
                    style: const TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic,),
                  ),
                ],
                const SizedBox(height: 6),
                if (!isCorrect)
                  Text(
                    userIdx is int && userIdx < options.length
                        ? 'Your answer: ${options[userIdx]}'
                        : 'Not answered',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                Text(
                  'Correct: ${options[correctIdx]}',
                  style: const TextStyle(color: Colors.green, fontSize: 13),
                ),
              ],
            ),
          ),
        ),);
      }
    }

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Answer Review',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...entries,
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final bool isBold;

  const _ScoreRow({
    required this.label,
    required this.score,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$score / 100',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isBold ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniScoreRow extends StatelessWidget {
  final String label;
  final int score;

  const _MiniScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(fontSize: 12)),),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  score >= 80
                      ? Colors.green
                      : score >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text('$score', style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
