import 'package:ceskina_pro/domain/engines/silence_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Duration ms(int m) => Duration(milliseconds: m);

  test('never stops before any speech is detected', () {
    final d = SilenceDetector(silenceTimeout: ms(3000));
    // Long stretch of silence at the start must not trigger a stop.
    for (var t = 0; t <= 10000; t += 150) {
      expect(d.accept(-80, ms(t)), isFalse);
    }
    expect(d.speechStarted, isFalse);
  });

  test('stops after silenceTimeout of quiet following speech', () {
    final d = SilenceDetector(
      speechThresholdDb: -40,
      silenceTimeout: ms(3000),
    );
    // Speech at t=0..1000
    expect(d.accept(-20, ms(0)), isFalse);
    expect(d.accept(-15, ms(500)), isFalse);
    expect(d.speechStarted, isTrue);
    // Silence begins at 1000; should stop 3000ms later (t=4000), not before.
    expect(d.accept(-70, ms(1000)), isFalse);
    expect(d.accept(-70, ms(3900)), isFalse); // 2900ms of silence — not yet
    expect(d.accept(-70, ms(4000)), isTrue); // 3000ms of silence — stop
  });

  test('a brief pause under the timeout does not stop; speech resets it', () {
    final d = SilenceDetector(
      speechThresholdDb: -40,
      silenceTimeout: ms(3000),
    );
    expect(d.accept(-10, ms(0)), isFalse); // speech
    expect(d.accept(-70, ms(500)), isFalse); // pause starts
    expect(d.accept(-70, ms(2000)), isFalse); // 1.5s pause — under timeout
    expect(d.accept(-10, ms(2100)), isFalse); // speaks again — resets
    // New silence starts at 2600; stop only 3000ms later.
    expect(d.accept(-70, ms(2600)), isFalse);
    expect(d.accept(-70, ms(5500)), isFalse); // 2900ms — not yet
    expect(d.accept(-70, ms(5600)), isTrue); // 3000ms — stop
  });
}
