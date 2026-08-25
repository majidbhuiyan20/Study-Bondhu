import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/attendance/widgets/scenario_sheet.dart';

void main() {
  group('Attendance what-if scenario maxAbsentsFor', () {
    test('returns 0 when total classes is 0 or target is 0', () {
      expect(maxAbsentsFor(totalClasses: 0, target: 75, present: 0), 0);
      expect(maxAbsentsFor(totalClasses: 10, target: 0, present: 10), 0);
    });

    test('returns correct number of skippable classes when above target', () {
      // 9 present out of 10 classes, target 75%:
      // (9 * 100 / 75) - 10 = 12 - 10 = 2 classes can be missed.
      // If misses 2: 9/12 = 75% (meets target)
      // If misses 3: 9/13 = 69.2% (below target)
      expect(maxAbsentsFor(totalClasses: 10, target: 75, present: 9), 2);

      // 28 present out of 32 classes, target 75%:
      // (28 * 100 / 75) - 32 = 37.33 - 32 = 5 classes can be missed.
      // If misses 5: 28/37 = 75.68% (meets target)
      // If misses 6: 28/38 = 73.68% (below target)
      expect(maxAbsentsFor(totalClasses: 32, target: 75, present: 28), 5);
    });

    test('returns 0 when attendance is exactly at target', () {
      // 15 present out of 20 classes = 75%, target 75%:
      // (15 * 100 / 75) - 20 = 20 - 20 = 0 classes
      expect(maxAbsentsFor(totalClasses: 20, target: 75, present: 15), 0);
    });

    test('returns 0 when attendance is below target', () {
      // 5 present out of 10 classes = 50%, target 75%:
      // (5 * 100 / 75) - 10 = 6 - 10 = -4 -> clamped to 0
      expect(maxAbsentsFor(totalClasses: 10, target: 75, present: 5), 0);
    });

    test('handles 100% attendance with 80% target', () {
      // 20 present out of 20 classes = 100%, target 80%:
      // (20 * 100 / 80) - 20 = 25 - 20 = 5
      expect(maxAbsentsFor(totalClasses: 20, target: 80, present: 20), 5);
    });
  });
}
