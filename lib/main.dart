import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/providers/database_providers.dart';
import 'presentation/providers/settings_providers.dart';
import 'presentation/screens/onboarding/loading_screen.dart';

/// App entry point.
void main() {
  runApp(
    const ProviderScope(
      child: CeskinaProApp(),
    ),
  );
}

/// Root app widget.
class CeskinaProApp extends ConsumerWidget {
  const CeskinaProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = ref.watch(appInitializationProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Check onboarding on data load
    return initFuture.when(
      loading: () => const LoadingScreen(),
      error: (err, stack) => LoadingScreen(error: err.toString()),
      data: (_) => MaterialApp.router(
        title: 'Čeština Pro',
        debugShowCheckedModeBanner: false,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}