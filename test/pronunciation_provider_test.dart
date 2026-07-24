import 'dart:async';

import 'package:ceskina_pro/domain/entities/pronunciation_result.dart';
import 'package:ceskina_pro/presentation/providers/pronunciation_providers.dart';
import 'package:ceskina_pro/presentation/providers/stt_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'assessment is scoped to the expected text captured by its attempt',
    () async {
      final assessor = _ControlledAssessor();
      final container = ProviderContainer(
        overrides: [
          pronunciationAssessmentProvider.overrideWithValue(assessor),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(pronunciationProvider.notifier);

      final pending = notifier.startRecording(expectedText: 'První věta');
      expect(assessor.expectedTexts, ['První věta']);

      notifier.setExpectedText('Druhá věta');
      assessor.completeNext(score: 1);
      await pending;

      final state = container.read(pronunciationProvider);
      expect(state.expectedText, 'Druhá věta');
      expect(state.result, isNull);
      expect(state.isRecording, isFalse);
    },
  );

  test('manual stop transcribes the captured audio (not discarded)', () async {
    // A manual stop must NOT abandon the attempt: it signals the assessor to
    // finish capturing, and the transcription result still arrives.
    final assessor = _ControlledAssessor();
    final container = ProviderContainer(
      overrides: [pronunciationAssessmentProvider.overrideWithValue(assessor)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(pronunciationProvider.notifier);

    final pending = notifier.startRecording(expectedText: 'Dobrý den');
    await notifier.stopRecording();
    assessor.completeNext(score: 0.9);
    await pending;

    final state = container.read(pronunciationProvider);
    expect(assessor.stopCount, 1); // stop was signalled
    expect(state.expectedText, 'Dobrý den');
    expect(state.result?.overallScore, 0.9); // result delivered, not dropped
    expect(state.isRecording, isFalse);
    expect(state.isProcessing, isFalse);
  });

  test('rapid retry reset rejects the previous completion', () async {
    final assessor = _ControlledAssessor();
    final container = ProviderContainer(
      overrides: [pronunciationAssessmentProvider.overrideWithValue(assessor)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(pronunciationProvider.notifier);

    final first = notifier.startRecording(expectedText: 'Řeka');
    notifier.reset();
    final second = notifier.startRecording(expectedText: 'Řeka');
    assessor.completeNext(score: 0.1);
    assessor.completeNext(score: 0.95);
    await Future.wait([first, second]);

    expect(container.read(pronunciationProvider).result?.overallScore, 0.95);
  });

  test('provider disposal safely discards an in-flight completion', () async {
    final assessor = _ControlledAssessor();
    final container = ProviderContainer(
      overrides: [pronunciationAssessmentProvider.overrideWithValue(assessor)],
    );
    final pending = container
        .read(pronunciationProvider.notifier)
        .startRecording(expectedText: 'Dobrý den');

    container.dispose();
    assessor.completeNext(score: 1);

    await expectLater(pending, completes);
  });
}

class _ControlledAssessor implements PronunciationAssessor {
  final expectedTexts = <String>[];
  final _pending = <Completer<PronunciationAssessment>>[];
  var stopCount = 0;

  @override
  bool get hasWhisper => false;

  @override
  Future<PronunciationAssessment> assess({
    required String expectedText,
    Duration maxDuration = const Duration(seconds: 15),
    void Function()? onCaptureComplete,
  }) {
    expectedTexts.add(expectedText);
    final completer = Completer<PronunciationAssessment>();
    _pending.add(completer);
    return completer.future;
  }

  void completeNext({required double score}) {
    _pending
        .removeAt(0)
        .complete(
          PronunciationAssessment(
            transcribedText: 'transcription',
            result: PronunciationResult(
              overallScore: score,
              wordScores: const [],
              problemSounds: const [],
              feedback: 'feedback',
            ),
          ),
        );
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}
