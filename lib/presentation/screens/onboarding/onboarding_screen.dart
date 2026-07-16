import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_providers.dart';
import '../../providers/gamification_providers.dart';
import '../../../domain/entities/enums.dart';

/// Onboarding flow — welcome → level assessment → goal setting → API key (optional).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  CEFRLevel _selectedLevel = CEFRLevel.preA1;
  int _selectedGoal = 50;
  final _apiKeyController = TextEditingController();

  static const _totalSteps = 4;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Future<void> _finish() async {
    // Save settings
    await ref.read(settingsProvider.notifier).setDailyGoalXp(_selectedGoal);

    // Set gamification daily goal
    ref.read(gamificationProvider.notifier).setDailyGoal(_selectedGoal);

    // Save API key if entered
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      await ref.read(settingsProvider.notifier).setApiKey(apiKey);
    }

    // Mark onboarding complete
    await ref.read(settingsProvider.notifier).completeOnboarding();

    // Navigate to home
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_step + 1) / _totalSteps,
              minHeight: 4,
            ),
            // Step content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _buildStep(),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _back,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 60),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _step < _totalSteps - 1 ? 'Continue' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _buildWelcomeStep(),
      1 => _buildLevelStep(),
      2 => _buildGoalStep(),
      3 => _buildApiKeyStep(),
      _ => const SizedBox(),
    };
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.school, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Vítejte!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Welcome to Čeština Pro',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        const Text(
          'Learn Czech from zero to A2 with:\n\n'
              '📚 Interactive lessons with spaced repetition\n'
              '🎤 Pronunciation practice with speech recognition\n'
              '💬 AI conversation tutor (role-play scenarios)\n'
              '📝 Mock CCE exams with AI evaluation\n'
              '🔊 Czech text-to-speech on every word\n',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLevelStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.assessment, size: 60, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'What\'s your Czech level?',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'This helps us start you at the right place.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _LevelCard(
          level: CEFRLevel.preA1,
          title: 'Complete Beginner',
          subtitle: 'I don\'t know any Czech yet',
          isSelected: _selectedLevel == CEFRLevel.preA1,
          onTap: () => setState(() => _selectedLevel = CEFRLevel.preA1),
        ),
        const SizedBox(height: 12),
        _LevelCard(
          level: CEFRLevel.a1,
          title: 'Some Czech (A1)',
          subtitle: 'I know basic greetings and simple phrases',
          isSelected: _selectedLevel == CEFRLevel.a1,
          onTap: () => setState(() => _selectedLevel = CEFRLevel.a1),
        ),
        const SizedBox(height: 12),
        _LevelCard(
          level: CEFRLevel.a2,
          title: 'Intermediate (A2)',
          subtitle: 'I can have basic conversations',
          isSelected: _selectedLevel == CEFRLevel.a2,
          onTap: () => setState(() => _selectedLevel = CEFRLevel.a2),
        ),
      ],
    );
  }

  Widget _buildGoalStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.flag, size: 60, color: Colors.orange),
        const SizedBox(height: 24),
        Text(
          'Set your daily goal',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'How much do you want to practice each day?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _GoalCard(
          xp: 20,
          label: 'Casual',
          subtitle: '5 minutes/day',
          isSelected: _selectedGoal == 20,
          onTap: () => setState(() => _selectedGoal = 20),
        ),
        const SizedBox(height: 12),
        _GoalCard(
          xp: 50,
          label: 'Regular',
          subtitle: '15 minutes/day',
          isSelected: _selectedGoal == 50,
          onTap: () => setState(() => _selectedGoal = 50),
        ),
        const SizedBox(height: 12),
        _GoalCard(
          xp: 100,
          label: 'Serious',
          subtitle: '30 minutes/day',
          isSelected: _selectedGoal == 100,
          onTap: () => setState(() => _selectedGoal = 100),
        ),
        const SizedBox(height: 12),
        _GoalCard(
          xp: 150,
          label: 'Intense',
          subtitle: '45+ minutes/day',
          isSelected: _selectedGoal == 150,
          onTap: () => setState(() => _selectedGoal = 150),
        ),
      ],
    );
  }

  Widget _buildApiKeyStep() {
    final settings = ref.watch(settingsProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.smart_toy, size: 60, color: Colors.purple),
        const SizedBox(height: 24),
        Text(
          'Enable AI Tutor',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter a DeepSeek API key to enable the AI conversation tutor '
          'and writing evaluation. You can skip this and add it later in Settings.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _apiKeyController,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'DeepSeek API Key (optional)',
            hintText: 'sk-...',
            prefixIcon: Icon(Icons.key),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Get a free key at platform.deepseek.com',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        if (!settings.hasApiKey)
          const Text(
            'Without an API key, the app uses mock responses for the AI tutor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final CEFRLevel level;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final int xp;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.xp,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Text('$label — $xp XP', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}