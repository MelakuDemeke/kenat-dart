import 'package:test/test.dart';

import 'package:kenat/src/month_grid.dart';
import 'package:kenat/src/conversions.dart';
import 'package:kenat/src/constants.dart';
import 'package:kenat/src/utils.dart';
import 'package:kenat/src/errors/error_handler.dart';

void main() {
  group('MonthGrid.create / createMonthGrid', () {
    test(
      'returns month grid with default current Ethiopian date when no input',
      () {
        final result = createMonthGrid();
        expect(result, contains('headers'));
        expect(result, contains('days'));
        expect(result['headers'], isA<List>());
        expect(result['days'], isA<List>());

        // Ensure there is an entry marked as today based on system date
        final today = DateTime.now();
        final todayEC = Conversions.toEC(today.year, today.month, today.day);
        final days = result['days'] as List;
        final hasToday = days.any((d) {
          if (d == null) return false;
          final eth = d['ethiopian'];
          return eth['year'] == todayEC['year'] &&
              eth['month'] == todayEC['month'] &&
              eth['day'] == todayEC['day'];
        });
        expect(hasToday, isTrue);
      },
    );

    test('parses string input correctly and returns valid grid', () {
      // helper to parse string and call MonthGrid
      Map<String, dynamic> getMonthGridFromString(String s) {
        final m = RegExp(r'^(\d{4})\/(\d{1,2})\/(\d{1,2})$');
        final match = m.firstMatch(s);
        if (match == null) {
          throw FormatException(
            "Invalid Ethiopian date format. Use 'yyyy/mm/dd'",
          );
        }
        final y = int.parse(match.group(1)!);
        final mo = int.parse(match.group(2)!);
        return createMonthGrid({'year': y, 'month': mo});
      }

      final result = getMonthGridFromString('2015/9/1');
      expect(result['headers'].length, 7);

      final days = result['days'] as List;
      final nonNullCount = days.where((d) => d != null).length;
      final expectedDaysInMonth =
          EthiopianCalendarUtils.getEthiopianDaysInMonth(2015, 9);
      expect(nonNullCount, expectedDaysInMonth);
      expect(days.firstWhere((d) => d != null), contains('weekday'));
    });

    test('throws error on invalid string format', () {
      Map<String, dynamic> getMonthGridFromString(String s) {
        final m = RegExp(r'^(\d{4})\/(\d{1,2})\/(\d{1,2})$');
        final match = m.firstMatch(s);
        if (match == null) {
          throw FormatException(
            "Invalid Ethiopian date format. Use 'yyyy/mm/dd'",
          );
        }
        final y = int.parse(match.group(1)!);
        final mo = int.parse(match.group(2)!);
        return createMonthGrid({'year': y, 'month': mo});
      }

      expect(
        () => getMonthGridFromString('invalid-date'),
        throwsFormatException,
      );
    });

    test('accepts object input with year, month and custom weekStart', () {
      final result = createMonthGrid({
        'year': 2015,
        'month': 9,
        'weekStart': 1,
        'weekdayLang': 'english',
      });
      // weekStart=1 should shift headers so first is Tuesday
      expect(result['headers'][0], DaysOfWeek.english[1]);

      final days = result['days'] as List;
      final nonNullCount = days.where((d) => d != null).length;
      expect(
        nonNullCount,
        EthiopianCalendarUtils.getEthiopianDaysInMonth(2015, 9),
      );

      // Check weekdayName matches the english labels for the first non-null day
      final firstNonNull = days.firstWhere((d) => d != null);
      expect(
        firstNonNull['weekdayName'],
        DaysOfWeek.english[firstNonNull['weekday']],
      );
    });

    test('throws InvalidGridConfigError for invalid weekdayLang', () {
      // Matches TS's contract (MonthGrid.ts throws InvalidGridConfigError
      // for an invalid weekdayLang instead of silently coercing).
      expect(
        () => createMonthGrid({
          'year': 2015,
          'month': 9,
          'weekdayLang': 'invalid',
        }),
        throwsA(isA<InvalidGridConfigError>()),
      );
    });

    test('pads days array correctly based on weekStart', () {
      final resultDefault = createMonthGrid({
        'year': 2015,
        'month': 9,
        'weekStart': 0,
      });
      final daysDefault = resultDefault['days'] as List;
      final offsetDefault = daysDefault.indexWhere((day) => day != null);
      expect(offsetDefault, greaterThanOrEqualTo(0));

      final resultShift = createMonthGrid({
        'year': 2015,
        'month': 9,
        'weekStart': 3,
      });
      final daysShift = resultShift['days'] as List;
      final offsetShift = daysShift.indexWhere((day) => day != null);
      expect(offsetShift, greaterThanOrEqualTo(0));
      expect(offsetShift, isNot(offsetDefault));
    });
  });
}
