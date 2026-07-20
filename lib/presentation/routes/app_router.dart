import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/curriculum/curriculum_screen.dart';
import '../screens/lesson/lesson_player_screen.dart';
import '../screens/review/srs_review_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/pronunciation/pronunciation_screen.dart';
import '../screens/exam/mock_exam_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/account_screen.dart';
import '../screens/grammar/grammar_reference_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../providers/settings_providers.dart';
import 'app_scaffold.dart';
import '../../domain/entities/enums.dart';

/// App router. First launch starts at onboarding; after that, home.
///
/// The onboarding flag is only read for the INITIAL location — finishing
/// onboarding navigates with `context.go('/')`, so the provider is not
/// invalidated mid-session (that would recreate the router and reset
/// navigation state).
final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref
      .watch(onboardingDoneProvider)
      .maybeWhen(data: (done) => done, orElse: () => true);

  return GoRouter(
    initialLocation: onboardingDone ? '/' : '/onboarding',
    routes: [
      // Tab destinations live inside the adaptive shell.
      ShellRoute(
        builder: (context, state, child) => AdaptiveScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/curriculum',
            builder: (context, state) => const CurriculumScreen(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) => const SrsReviewScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Full-screen flows — no bottom nav / side rail. These are pushed
      // (context.push) so closing them pops back to where the user was.
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder:
            (context, state) => LessonPlayerScreen(
              lessonId: int.parse(state.pathParameters['id']!),
            ),
      ),
      GoRoute(
        path: '/pronunciation/:id',
        builder:
            (context, state) =>
                PronunciationScreen(exerciseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/exam/:level',
        builder:
            (context, state) => MockExamScreen(
              level:
                  state.pathParameters['level']! == 'a2'
                      ? ExamLevel.a2
                      : ExamLevel.a1,
            ),
      ),
      GoRoute(
        path: '/grammar',
        builder:
            (context, state) => GrammarReferenceScreen(
              highlightRuleId: state.uri.queryParameters['rule'],
            ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});
