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
import 'app_scaffold.dart';
import '../../domain/entities/enums.dart';

/// App router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AdaptiveScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/curriculum',
          builder: (context, state) => const CurriculumScreen(),
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (context, state) => LessonPlayerScreen(
            lessonId: int.parse(state.pathParameters['id']!),
          ),
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
          path: '/pronunciation/:id',
          builder: (context, state) => PronunciationScreen(
            exerciseId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/exam/:level',
          builder: (context, state) => MockExamScreen(
            level: state.pathParameters['level']! == 'a2'
                ? ExamLevel.a2
                : ExamLevel.a1,
          ),
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
  ],
);