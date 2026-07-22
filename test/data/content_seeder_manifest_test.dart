import 'package:ceskina_pro/data/seeds/content_seeder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires both lesson packs for every A1 and A2 unit', () {
    final lessonPacks = ContentSeeder.requiredPackPaths.where(
      (path) => path.startsWith('assets/curriculum/lessons/'),
    );

    expect(lessonPacks, hasLength(60));
    for (var unit = 1; unit <= 29; unit++) {
      final unitNumber = unit.toString().padLeft(2, '0');
      for (var lesson = 1; lesson <= 2; lesson++) {
        final lessonNumber = lesson.toString().padLeft(2, '0');
        expect(
          lessonPacks,
          contains(
            'assets/curriculum/lessons/'
            'unit${unitNumber}_lesson$lessonNumber.json',
          ),
          reason: 'Unit $unit lesson $lesson must be part of every release.',
        );
      }
    }
    // Units 30-31 have one lesson each
    for (var unit = 30; unit <= 31; unit++) {
      final unitNumber = unit.toString().padLeft(2, '0');
      expect(
        lessonPacks,
        contains(
          'assets/curriculum/lessons/'
          'unit${unitNumber}_lesson01.json',
        ),
        reason: 'Unit $unit lesson 1 must be part of every release.',
      );
    }
  });
}
