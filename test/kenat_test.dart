import 'package:flutter_test/flutter_test.dart';
import 'package:kenat/kenat.dart';

void main() {
  group('Kenat Ethiopian Calendar Library Tests', () {
    test('Basic Kenat instance creation and date conversion', () {
      // Test creating Kenat from Ethiopian date
      final kenat = Kenat.fromEthiopian(2016, 1, 10);

      expect(kenat.getEthiopian()['year'], equals(2016));
      expect(kenat.getEthiopian()['month'], equals(1));
      expect(kenat.getEthiopian()['day'], equals(10));

      // Test Gregorian conversion
      final gregorian = kenat.getGregorian();
      expect(gregorian['year'], equals(2023));
      expect(gregorian['month'], equals(9));
      expect(gregorian['day'], equals(17));
    });

    test('Date formatting', () {
      final kenat = Kenat.fromEthiopian(2016, 1, 10);

      // Test standard formatting
      expect(kenat.formatStandard(), equals('መስከረም 10 2016'));
      expect(kenat.formatStandard('english'), equals('Meskerem 10 2016'));

      // Test short formatting
      expect(kenat.formatShort(), equals('2016/01/10'));

      // Test Geez formatting
      expect(kenat.formatInGeez(), equals('መስከረም ፲፩ ፳፻፲፮'));
    });

    test('Date arithmetic', () {
      final kenat = Kenat.fromEthiopian(2016, 1, 10);

      // Test adding days
      final nextDay = kenat.addDays(1);
      expect(nextDay.getEthiopian()['day'], equals(11));

      // Test adding months
      final nextMonth = kenat.addMonths(1);
      expect(nextMonth.getEthiopian()['month'], equals(2));
      expect(nextMonth.getEthiopian()['day'], equals(10));

      // Test adding years
      final nextYear = kenat.addYears(1);
      expect(nextYear.getEthiopian()['year'], equals(2017));
    });

    test('Geez numeral conversion', () {
      expect(toGeez(10), equals('፲፩'));
      expect(toGeez(2016), equals('፳፻፲፮'));
      expect(toArabic('፲፩'), equals(10));
      expect(toArabic('፳፻፲፮'), equals(2016));
    });

    test('Time class', () {
      final time = Time(8, 30, 'day');
      expect(time.hour, equals(8));
      expect(time.minute, equals(30));
      expect(time.period, equals('day'));

      // Test formatting
      final formatted = time.format();
      expect(formatted, contains('8'));
      expect(formatted, contains('30'));
    });

    test('Weekday calculation', () {
      final kenat = Kenat.fromEthiopian(2016, 1, 10);
      final weekday = kenat.getWeekday();
      expect(weekday, greaterThanOrEqualTo(0));
      expect(weekday, lessThan(7));

      final weekdayName = kenat.getWeekdayName();
      expect(weekdayName, isNotEmpty);
    });

    test('Holiday information', () {
      final kenat = Kenat.fromEthiopian(2016, 1, 1); // Enkutatash

      // Test getting holidays for the month
      final holidays = kenat.getHolidaysInMonth();
      expect(holidays, isNotEmpty);

      // Check if Enkutatash is in the holidays
      final enkutatash = holidays.where((h) => h['key'] == 'enkutatash');
      expect(enkutatash, isNotEmpty);
    });

    test('Bahire Hasab calculations', () {
      final kenat = Kenat.fromEthiopian(2016, 1, 1);

      // Test Bahire Hasab
      final bh = kenat.getBahireHasab();
      expect(bh, isNotNull);
      expect(bh['ameteAlem'], isNotNull);
      expect(bh['movableFeasts'], isNotNull);
    });

    test('Month grid generation', () {
      final grid = createMonthGrid({'year': 2016, 'month': 1});
      expect(grid['headers'], isNotEmpty);
      expect(grid['days'], isNotEmpty);
      expect(grid['year'], equals(2016));
      expect(grid['month'], equals(1));
    });

    test('Error handling', () {
      // Test invalid date
      expect(
        () => Kenat.fromEthiopian(2016, 13, 32),
        throwsA(isA<InvalidEthiopianDateError>()),
      );

      // Test invalid time
      expect(() => Time(25, 0, 'day'), throwsA(isA<InvalidTimeError>()));
    });
  });
}
