import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/providers/database_providers.dart';
import 'presentation/providers/settings_providers.dart';
import 'presentation/providers/sync_providers.dart';
import 'presentation/screens/onboarding/loading_screen.dart';

/// App entry point.
void main() {
  // Surface package:logging output during development; keep release quiet.
  Logger.root.level = kDebugMode ? Level.INFO : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '[${record.level.name}] ${record.loggerName}: '
      '${record.message}'
      '${record.error != null ? ' — ${record.error}' : ''}',
    );
  });

  runApp(const ProviderScope(child: CeskinaProApp()));
}

/// Root app widget.
class CeskinaProApp extends ConsumerWidget {
  const CeskinaProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = ref.watch(appInitializationProvider);
    final onboardingDone = ref.watch(onboardingDoneProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Wait for both DB seeding and the onboarding flag before building the
    // router, so the initial location is decided from real data.
    if (initFuture.isLoading || onboardingDone.isLoading) {
      return const LoadingScreen();
    }
    if (initFuture.hasError) {
      return LoadingScreen(
        error: _startupErrorMessage(initFuture.error),
        onRetry: () {
          ref.invalidate(appInitializationProvider);
        },
      );
    }

    // Keep remote auth, sync, and curriculum refresh alive after the verified
    // local course is ready. Its failure must not replace the usable app UI.
    ref.watch(backgroundInitializationProvider);
    ref.watch(syncTriggerCoordinatorProvider);

    return MaterialApp.router(
      title: 'Čeština Pro',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

String _startupErrorMessage(Object? error) {
  final detail = error?.toString().toLowerCase() ?? '';
  if (detail.contains('incomplete') || detail.contains('missing')) {
    return 'The packaged course content is incomplete. Please reinstall or '
        'update the app.';
  }
  return 'The course could not be prepared on this device. Please try again.';
}
