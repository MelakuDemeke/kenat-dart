import 'package:test/test.dart';

import 'package:kenat/src/month_grid.dart';
import 'package:kenat/src/constants.dart';

/// Regression tests for the saints/negs filtering bug: previously every
/// Christian-mode MonthGrid showed every recurring saint regardless of
/// whether the requested month was one of the saint's "negs" (yearly major
/// feast) months, and `showAllSaints` was a dead field. These tests confirm
/// the fix: a saint only appears unless `showAllSaints: true` OR the
/// requested month is in the saint's `negs` list, and the emitted entry is
/// tagged `isNigs`/`tags` accordingly.
void main() {
  group('MonthGrid saints negs/showAllSaints filtering', () {
    List<Map<String, dynamic>> holidaysOnDay(Map<String, dynamic> grid, int day) {
      final days = grid['days'] as List;
      final match = days.firstWhere(
        (d) => d != null && d['ethiopian']['day'] == day,
        orElse: () => null,
      );
      if (match == null) return [];
      return (match['holidays'] as List).cast<Map<String, dynamic>>();
    }

    test('a saint whose negs includes the month is shown by default', () {
      // ledeta_mariam is day 1, negs: [9] (Meskerem).
      final grid = MonthGrid.create({
        'year': 2016,
        'month': 9,
        'mode': 'christian',
      });
      final holidays = holidaysOnDay(grid, 1);
      final entry = holidays.firstWhere(
        (h) => h['key'] == 'ledeta_mariam',
        orElse: () => {},
      );
      expect(entry, isNotEmpty);
      expect(entry['isNigs'], isTrue);
      expect(entry['tags'], contains('NIGS'));
      expect(entry['tags'], contains(HolidayTags.religious));
      expect(entry['tags'], contains(HolidayTags.christian));
    });

    test('a saint whose negs does NOT include the month is absent by default', () {
      // ledeta_mariam's negs is [9], so it should not appear in month 1.
      final grid = MonthGrid.create({
        'year': 2016,
        'month': 1,
        'mode': 'christian',
      });
      final holidays = holidaysOnDay(grid, 1);
      expect(holidays.any((h) => h['key'] == 'ledeta_mariam'), isFalse);
    });

    test('showAllSaints:true includes it anyway, tagged SAINT_DAY (not NIGS)', () {
      final grid = MonthGrid.create({
        'year': 2016,
        'month': 1,
        'mode': 'christian',
        'showAllSaints': true,
      });
      final holidays = holidaysOnDay(grid, 1);
      final entry = holidays.firstWhere(
        (h) => h['key'] == 'ledeta_mariam',
        orElse: () => {},
      );
      expect(entry, isNotEmpty);
      expect(entry['isNigs'], isFalse);
      expect(entry['tags'], contains('SAINT_DAY'));
      expect(entry['tags'], isNot(contains('NIGS')));
    });

    test('non-christian/orthodox modes never include saints', () {
      final grid = MonthGrid.create({
        'year': 2016,
        'month': 9,
        'mode': 'public',
      });
      final holidays = holidaysOnDay(grid, 1);
      expect(holidays.any((h) => h['key'] == 'ledeta_mariam'), isFalse);
    });

    test('archangel_michael (negs: [3, 12]) appears in both its negs months', () {
      final gridMonth3 = MonthGrid.create({
        'year': 2016,
        'month': 3,
        'mode': 'christian',
      });
      final gridMonth12 = MonthGrid.create({
        'year': 2016,
        'month': 12,
        'mode': 'christian',
      });
      final gridMonth5 = MonthGrid.create({
        'year': 2016,
        'month': 5,
        'mode': 'christian',
      });

      bool hasArchangelMichael(Map<String, dynamic> grid) {
        return holidaysOnDay(grid, 12).any((h) => h['key'] == 'archangel_michael');
      }

      expect(hasArchangelMichael(gridMonth3), isTrue);
      expect(hasArchangelMichael(gridMonth12), isTrue);
      expect(hasArchangelMichael(gridMonth5), isFalse);
    });
  });

  group('MonthGrid weekStart default', () {
    test('defaults to 1 (Monday), matching TS, not 0 (Sunday)', () {
      final result = MonthGrid.create({'year': 2016, 'month': 1});
      expect(result['headers'][0], equals(DaysOfWeek.amharic[1]));
    });

    test('explicit weekStart: 0 still starts the week on Sunday', () {
      final result = MonthGrid.create({
        'year': 2016,
        'month': 1,
        'weekStart': 0,
      });
      expect(result['headers'][0], equals(DaysOfWeek.amharic[0]));
    });
  });
}
