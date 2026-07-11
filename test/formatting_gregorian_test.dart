import 'package:test/test.dart';
import 'package:kenat/kenat.dart';

void main() {
  group('Gregorian formatting functions', () {
    final gDate = {'year': 2023, 'month': 9, 'day': 11};

    test('formatGregorianStandard formats with English month name', () {
      expect(formatGregorianStandard(gDate), equals('September 11, 2023'));
    });

    test('formatGregorianWithWeekday includes weekday name', () {
      // September 11, 2023 is a Monday.
      expect(
        formatGregorianWithWeekday(gDate),
        equals('Monday, September 11, 2023'),
      );
      expect(
        formatGregorianWithWeekday(gDate, 'amharic'),
        equals('ሰኞ, September 11, 2023'),
      );
    });

    test('formatGregorianWithTime appends the time string', () {
      final time = Time(8, 30, 'day');
      final formatted = formatGregorianWithTime(gDate, time);
      expect(formatted, startsWith('September 11, 2023'));
      expect(formatted, contains('8:30'));
    });

    test('toGregorianISODateString converts Ethiopian time to 24-hour Gregorian time', () {
      final dayTime = Time(12, 0, 'day'); // noon-day -> 06:00 Gregorian
      expect(
        toGregorianISODateString(gDate, dayTime),
        equals('2023-09-11T06:00'),
      );

      final nightTime = Time(8, 15, 'night'); // -> 02:15 Gregorian
      expect(
        toGregorianISODateString(gDate, nightTime),
        equals('2023-09-11T02:15'),
      );
    });

    test('toGregorianISODateString without a time returns date-only', () {
      expect(toGregorianISODateString(gDate), equals('2023-09-11'));
    });
  });

  group('formatStandard out-of-range month fallback', () {
    test('falls back to "Month<n>" instead of throwing for an invalid month', () {
      final etDate = {'year': 2016, 'month': 99, 'day': 1};
      expect(formatStandard(etDate), equals('Month99 1 2016'));
      expect(formatStandard(etDate, 'english'), equals('Month99 1 2016'));
    });
  });
}
