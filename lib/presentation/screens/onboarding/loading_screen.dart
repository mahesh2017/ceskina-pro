import 'package:flutter/material.dart';

/// Loading screen shown while database is being seeded.
class LoadingScreen extends StatelessWidget {
  final String? error;

  const LoadingScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: error != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(error!, textAlign: TextAlign.center),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text('Loading Čeština Pro...'),
                  ],
                ),
        ),
      ),
    );
  }
}