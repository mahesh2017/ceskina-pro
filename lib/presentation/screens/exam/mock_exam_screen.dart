import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/exam_result.dart';
import '../../../domain/repositories/exam_repository.dart';
import '../../providers/database_providers.dart';
import '../../providers/gamification_providers.dart';

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
  final Map<int, dynamic> _answers = {};
  Timer? _timer;
  int _secondsLeft = 0;
  bool _examStarted = false;
  bool _examComplete = false;
  ExamResult? _result;

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
    // Build a sample exam for the given level
    _exam = _buildSampleExam(widget.level);
  }

  void _startExam() {
    if (_exam == null) return;
    setState(() {
      _examStarted = true;
      _currentSection = 0;
      _currentQuestion = 0;
      _answers.clear();
      _examComplete = false;
    });
    _startSectionTimer();
  }

  void _startSectionTimer() {
    _timer?.cancel();
    final section = _exam!.sections[_currentSection];
    _secondsLeft = section.timeLimitMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          timer.cancel();
          _nextSection();
        }
      });
    });
  }

  void _answer(dynamic answer) {
    final questionIdx = _currentQuestion;
    setState(() {
      _answers[questionIdx] = answer;
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

  void _finishExam() {
    _timer?.cancel();
    final score = _calculateScore();

    setState(() {
      _examComplete = true;
      _result = ExamResult(
        id: DateTime.now().millisecondsSinceEpoch,
        level: widget.level,
        takenAt: DateTime.now(),
        readingScore: score['reading'] ?? 0,
        listeningScore: score['listening'] ?? 0,
        writingScore: score['writing'] ?? 0,
        speakingScore: score['speaking'] ?? 0,
        totalScore: ((score['reading'] ?? 0) +
                (score['listening'] ?? 0) +
                (score['writing'] ?? 0) +
                (score['speaking'] ?? 0)) ~/
            4,
        passed: (score['total'] ?? 0) >= 60,
      );
    });

    // Award XP + record exam pass
    final gamification = ref.read(gamificationProvider.notifier);
    gamification.onLessonCompleted(accuracy: _result!.totalScore / 100);

    final progressRepo = ref.read(progressRepositoryProvider);
    if (_result!.passed) {
      progressRepo.recordExamPassed(widget.level.name);
    }
  }

  Map<String, int> _calculateScore() {
    final scores = <String, int>{};
    for (var i = 0; i < _exam!.sections.length; i++) {
      final section = _exam!.sections[i];
      int correct = 0;
      for (var q = 0; q < section.questions.length; q++) {
        final userAnswer = _answers[q];
        final correctAnswer = section.questions[q]['correct_answer'];
        if (userAnswer == correctAnswer) {
          correct++;
        }
      }
      final percent = section.questions.isEmpty
          ? 0
          : ((correct / section.questions.length) * 100).round();
      scores[section.type.name] = percent;
    }
    scores['total'] = scores.values.reduce((a, b) => a + b) ~/
        _exam!.sections.length;
    return scores;
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
          title: Text('Mock Exam — ${widget.level.name.toUpperCase()}')),
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
                '🎤 Speaking — pronunciation practice\n\n'
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
    final section = _exam!.sections[_currentSection];
    final question = section.questions[_currentQuestion];
    final totalQuestions = section.questions.length;
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text('${section.type.name[0].toUpperCase()}${section.type.name.substring(1)} — ${minutes}:${seconds.toString().padLeft(2, '0')}'),
        actions: [
          Text(
            'Q${_currentQuestion + 1}/$totalQuestions',
            style: const TextStyle(fontSize: 14),
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
                    onPressed: () =>
                        setState(() => _currentQuestion--),
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
    );
  }

  Widget _buildQuestion(ExamSectionType type, Map<String, dynamic> question) {
    switch (type) {
      case ExamSectionType.reading:
      case ExamSectionType.listening:
        return _buildReadingQuestion(question);
      case ExamSectionType.writing:
        return _buildWritingQuestion(question);
      case ExamSectionType.speaking:
        return _buildSpeakingQuestion(question);
    }
  }

  Widget _buildReadingQuestion(Map<String, dynamic> question) {
    final prompt = question['prompt'] as String;
    final options = (question['options'] as List<dynamic>).cast<String>();
    final selected = _answers[_currentQuestion];

    return Column(
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
                    ? const Icon(Icons.check_circle,
                        color: Colors.blue)
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWritingQuestion(Map<String, dynamic> question) {
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Napište svou odpověď v češtině...',
            ),
            onChanged: _answer,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakingQuestion(Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['prompt'] as String,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              question['target_text'] as String,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Practice saying the text above. Your pronunciation will be evaluated.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        // For now, auto-pass speaking section
        FilledButton(
          onPressed: () => _answer(question['target_text']),
          child: const Text('I said it → Continue'),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final passed = _result!.passed;
    final color = passed ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: Center(
        child: Padding(
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
                passed ? 'Gratulujeme! Passed!' : 'Neprošli. Not passed.',
                style: Theme.of(context).textTheme.headlineMedium,
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

/// Build a sample CCE-format mock exam.
MockExam _buildSampleExam(ExamLevel level) {
  final isA1 = level == ExamLevel.a1;

  final readingQuestions = [
    {
      'passage': isA1
          ? 'Ahoj, jmenuji se Petra. Bydlím v Praze. Ráda čtu knihy a poslouchám hudbu. Každé ráno piju kávu a jím rohlík.'
          : 'Dobrý den, jmenuji se Tomáš a pracuji v bance v centru Prahy. Každý den vstávám v šest hodin a jedu metrem do práce. V práci jsem od osmi do čtyř hodin odpoledne.',
      'prompt': 'What does Petra/Tomáš do every morning?',
      'options': [
        'Drinks coffee and eats bread',
        'Goes to work by car',
        'Reads books in the park',
        'Listens to music',
      ],
      'correct_answer': 0,
    },
    {
      'prompt': 'Where does the person live/work?',
      'options': ['Brno', 'Praha', 'Ostrava', 'Plzeň'],
      'correct_answer': 1,
    },
  ];

  final listeningQuestions = [
    {
      'prompt': 'You will hear: "Dobré ráno, jak se máte?" — What does the speaker say?',
      'options': ['Good morning, how are you?', 'Good evening, see you later', 'Good night, sleep well', 'Goodbye, take care'],
      'correct_answer': 0,
    },
    {
      'prompt': 'You will hear: "Mám hlad." — What does the speaker want?',
      'options': ['A drink', 'Food', 'Sleep', 'Help'],
      'correct_answer': 1,
    },
  ];

  final writingQuestion = {
    'prompt': isA1
        ? 'Write about yourself: your name, where you live, and what you like to do. (30+ words)'
        : 'Write about your typical day: when you wake up, what you do at work/school, and your evening routine. (50+ words)',
    'min_words': isA1 ? 30 : 50,
  };

  final speakingQuestion = {
    'prompt': 'Read the following Czech text aloud:',
    'target_text': isA1
        ? 'Ahoj, jmenuji se Student. Bydlím v Praze a učím se česky.'
        : 'Dobrý den, pracuji v kanceláři a každý den dojíždím metrem. V volném čase rád čtu a cestuji.',
  };

  return MockExam(
    level: level,
    totalTimeMinutes: isA1 ? 30 : 45,
    sections: [
      MockExamSection(
        type: ExamSectionType.reading,
        timeLimitMinutes: 8,
        questions: readingQuestions,
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.listening,
        timeLimitMinutes: 8,
        questions: listeningQuestions,
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.writing,
        timeLimitMinutes: 10,
        questions: [writingQuestion],
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.speaking,
        timeLimitMinutes: 5,
        questions: [speakingQuestion],
        maxScore: 100,
      ),
    ],
  );
}