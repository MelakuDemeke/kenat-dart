import 'package:test/test.dart';

import 'package:kenat/src/holidays.dart';
import 'package:kenat/src/bahire_hasab.dart';
import 'package:kenat/src/errors/error_handler.dart';

void main() {
  group('Holiday Calculation', () {
    group('getHolidaysInMonth', () {
      test('should return fixed and movable holidays for a given month', () {
        final holidays = getHolidaysInMonth(2016, 1);
        final holidayKeys = holidays.map((h) => h['key']).toList();

        expect(holidayKeys, contains('enkutatash'));
        expect(holidayKeys, contains('meskel'));
      });

      test(
        'should correctly calculate and include movable Christian holidays',
        () {
          final holidays = getHolidaysInMonth(2016, 8);
          final fasikaList = holidays
              .where((h) => h['key'] == 'fasika')
              .toList();
          final sikletList = holidays
              .where((h) => h['key'] == 'siklet')
              .toList();

          expect(fasikaList, isNotEmpty);
          final fasika = fasikaList.first;
          expect(fasika['ethiopian']['day'], 27);

          expect(sikletList, isNotEmpty);
          final siklet = sikletList.first;
          expect(siklet['ethiopian']['day'], 25);
        },
      );
    });

    group('getMovableHoliday (Bahire Hasab)', () {
      test(
        'should return correct Fasika (Tinsaye) date for Ethiopian years 2012 to 2016',
        () {
          expect(getMovableHoliday('TINSAYE', 2012), {
            'year': 2012,
            'month': 8,
            'day': 11,
          });
          expect(getMovableHoliday('TINSAYE', 2013), {
            'year': 2013,
            'month': 8,
            'day': 24,
          });
          expect(getMovableHoliday('TINSAYE', 2014), {
            'year': 2014,
            'month': 8,
            'day': 16,
          });
          expect(getMovableHoliday('TINSAYE', 2015), {
            'year': 2015,
            'month': 8,
            'day': 8,
          });
          expect(getMovableHoliday('TINSAYE', 2016), {
            'year': 2016,
            'month': 8,
            'day': 27,
          });
        },
      );

      test(
        'should return correct Siklet (Good Friday) date for Ethiopian years 2012 to 2016',
        () {
          expect(getMovableHoliday('SIKLET', 2012), {
            'year': 2012,
            'month': 8,
            'day': 9,
          });
          expect(getMovableHoliday('SIKLET', 2013), {
            'year': 2013,
            'month': 8,
            'day': 22,
          });
          expect(getMovableHoliday('SIKLET', 2014), {
            'year': 2014,
            'month': 8,
            'day': 14,
          });
          expect(getMovableHoliday('SIKLET', 2015), {
            'year': 2015,
            'month': 8,
            'day': 6,
          });
          expect(getMovableHoliday('SIKLET', 2016), {
            'year': 2016,
            'month': 8,
            'day': 25,
          });
        },
      );
    });

    group('Error Handling', () {
      test('getHolidaysInMonth should throw for invalid input types', () {
        final dyn1 = getHolidaysInMonth as dynamic;
        expect(() => dyn1('2016', 1), throwsA(isA<InvalidInputTypeError>()));
        expect(() => dyn1(2016, 'one'), throwsA(isA<InvalidInputTypeError>()));
      });

      test('getHolidaysInMonth should throw for out-of-range month', () {
        expect(
          () => getHolidaysInMonth(2016, 0),
          throwsA(isA<InvalidInputTypeError>()),
        );
        expect(
          () => getHolidaysInMonth(2016, 14),
          throwsA(isA<InvalidInputTypeError>()),
        );
      });

      test('getMovableHoliday should throw for invalid input type', () {
        final dyn = getMovableHoliday as dynamic;
        expect(
          () => dyn('TINSAYE', null),
          throwsA(isA<InvalidInputTypeError>()),
        );
        expect(
          () => dyn('TINSAYE', '2016'),
          throwsA(isA<InvalidInputTypeError>()),
        );
      });

      test('getMovableHoliday should throw for unknown holiday key', () {
        expect(
          () => getMovableHoliday('UNKNOWN_HOLIDAY', 2016),
          throwsA(isA<UnknownHolidayError>()),
        );
      });
    });

    group('Movable Muslim Holidays', () {
      test('should return correct date for Moulid in 2016', () {
        final holiday = getHoliday('moulid', 2016);
        expect(holiday, isNotNull);
        expect(holiday!['ethiopian'], {'year': 2016, 'month': 1, 'day': 16});
      });

      test('should return correct date for Eid al-Fitr in 2016', () {
        final holiday = getHoliday('eidFitr', 2016);
        expect(holiday, isNotNull);
        expect(holiday!['ethiopian'], {'year': 2016, 'month': 8, 'day': 2});
      });

      test('should return correct date for Eid al-Adha in 2016', () {
        final holiday = getHoliday('eidAdha', 2016);
        expect(holiday, isNotNull);
        expect(holiday!['ethiopian'], {'year': 2016, 'month': 10, 'day': 10});
      });
    });
  });
}
