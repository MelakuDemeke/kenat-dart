import 'package:test/test.dart';

import '../lib/src/kenat.dart';
import '../lib/src/formatting.dart';

void main() {
  group('Kenat - getMonthCalendar', () {
    test('should return 30 days for a standard Ethiopian month', () {
      final k = Kenat.fromString('2015/1/1');
      final calendar = k.getMonthCalendar(2015, 1);
      // The MonthGrid returns a map with 'days' padded; filter out nulls
      final days = (calendar['days'] as List).where((d) => d != null).toList();
      expect(days.length, 30);
    });

    test('should return 6 days for Pagumē in a leap year (year % 4 === 3)', () {
      final k = Kenat.fromString(
        '2011/13/1',
      ); // 2011 is a leap year in Ethiopian calendar
      final calendar = k.getMonthCalendar(2011, 13);
      final days = (calendar['days'] as List).where((d) => d != null).toList();
      expect(days.length, 6);
    });

    test('should return 5 days for Pagumē in a non-leap year', () {
      final k = Kenat.fromString('2012/13/1');
      final calendar = k.getMonthCalendar(2012, 13);
      final days = (calendar['days'] as List).where((d) => d != null).toList();
      expect(days.length, 5);
    });

    test(
      'each day should include properly formatted Ethiopian and Gregorian fields',
      () {
        final k = Kenat.fromString('2015/2/1');
        final calendar = k.getMonthCalendar(2015, 2, false);
        final days = (calendar['days'] as List)
            .where((d) => d != null)
            .toList();
        final day = days[0];

        expect(day, contains('ethiopian'));
        expect(day, contains('gregorian'));

        final eth = day['ethiopian'];
        final greg = day['gregorian'];

        // Check that display fields can be generated via DateFormatter
        final ethDisplay = formatShort({
          'year': eth['year'],
          'month': eth['month'],
          'day': eth['day'],
        });
        final gregDisplay = greg != null ? greg['year'].toString() : null;

        expect(ethDisplay, isA<String>());
        expect(gregDisplay, isA<String>());
      },
    );

    test('should correctly format Geez numerals when useGeez = true', () {
      final k = Kenat.fromString('2015/1/1');
      final calendar = k.getMonthCalendar(2015, 1, true);
      final days = (calendar['days'] as List).where((d) => d != null).toList();
      final day = days[0];
      final eth = day['ethiopian'];
      // When useGeez=true MonthGrid returns display-friendly strings for Ethiopian
      // fields (month name, Geez day/year). Ensure the `day` field includes
      // at least one Geez numeral character.
      final ethDay = eth['day'];
      expect(ethDay, isA<String>());
      final geezRegex = RegExp(r'[\u1369-\u137C]');
      expect(geezRegex.hasMatch(ethDay), isTrue);
    });
  });
}
