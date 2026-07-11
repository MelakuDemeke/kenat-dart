import 'package:test/test.dart';
import 'package:kenat/kenat.dart';

/// Port of kenat/src/render/printMonthCalendarGrid.ts. No visual assertions
/// (it writes to stdout) - just confirms it runs without throwing for valid
/// input and validates its inputs the same way the TS version does.
void main() {
  group('printMonthCalendarGrid / Kenat.printThisMonth', () {
    test('prints without throwing for a valid month', () {
      final k = Kenat.fromString('2016/1/1');
      expect(() => k.printThisMonth(), returnsNormally);
      expect(() => k.printThisMonth(true), returnsNormally);
    });

    test('printMonthCalendarGrid validates ethiopianMonth range', () {
      final calendar = Kenat.fromString('2016/1/1').getCalendarDays(2016, 1);
      expect(
        () => printMonthCalendarGrid(2016, 14, calendar),
        throwsA(isA<InvalidInputTypeError>()),
      );
    });

    test('printMonthCalendarGrid handles empty calendar data gracefully', () {
      expect(() => printMonthCalendarGrid(2016, 1, []), returnsNormally);
    });
  });
}
