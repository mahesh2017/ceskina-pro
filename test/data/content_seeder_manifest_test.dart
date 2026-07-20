import 'package:ceskina_pro/data/seeds/content_seeder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires both lesson packs for every A1 and A2 unit', () {
    final lessonPacks = ContentSeeder.requiredPackPaths.where(
      (path) => path.startsWith('assets/curriculum/lessons/'),
    );

    expect(lessonPacks, hasLength(44));
    for (var unit = 1; unit <= 22; unit++) {
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
  });
}
