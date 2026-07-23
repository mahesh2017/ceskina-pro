import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Loading screen shown while the database is being seeded. Standalone
/// MaterialApp (renders before the themed router), so it carries the brand
/// theme itself for visual continuity with the redesign.
class LoadingScreen extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const LoadingScreen({super.key, this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: Scaffold(
        body: Center(
          child:
              error != null
                  ? SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height - 64,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 64,
                              color: AppColors.heartsRed,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Course couldn’t load',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Bricolage Grotesque',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(height: 1.45),
                            ),
                            if (onRetry != null) ...[
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: onRetry,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try again'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/czechify_logo.png',
                        width: 92,
                        height: 92,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Czechify',
                        style: TextStyle(
                          fontFamily: 'Bricolage Grotesque',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
