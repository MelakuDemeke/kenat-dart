import 'package:test/test.dart';
import 'package:kenat/src/bahire_hasab.dart';
import 'package:kenat/src/errors/error_handler.dart';
import 'package:kenat/src/utils.dart';

void main() {
  group('Bahire Hasab Calculation', () {
    group('getBahireHasab for 2016 E.C.', () {
      late Map<String, dynamic> bahireHasab2016;

      setUp(() {
        bahireHasab2016 = getBahireHasab(2016);
      });

      test('should calculate Amete Alem and Metene Rabiet correctly', () {
        expect(bahireHasab2016['ameteAlem'], equals(7516));
        expect(bahireHasab2016['meteneRabiet'], equals(1879));
      });

      test('should identify the correct Evangelist', () {
        final evangelist =
            bahireHasab2016['evangelist'] as Map<String, dynamic>;
        expect(evangelist['name'], equals('ዮሐንስ')); // John in Amharic (default)
        expect(evangelist['remainder'], equals(0));
      });

      test('should determine the correct New Year day', () {
        final newYear = bahireHasab2016['newYear'] as Map<String, dynamic>;
        expect(
          newYear['dayName'],
          equals('ማክሰኞ'),
        ); // Tuesday in Amharic (default)
      });

      test('should calculate Medeb, Wenber, Abektie, and Metqi correctly', () {
        expect(bahireHasab2016['medeb'], equals(11));
        expect(bahireHasab2016['wenber'], equals(10));
        expect(bahireHasab2016['abektie'], equals(20));
        expect(bahireHasab2016['metqi'], equals(10));
      });

      test('should calculate the correct date for Nineveh', () {
        final nineveh = bahireHasab2016['nineveh'] as Map<String, int>;
        expect(nineveh, equals({'year': 2016, 'month': 6, 'day': 18}));
      });
    });

    group('Internationalization (i18n)', () {
      test('should return names in English when specified', () {
        final bahireHasabEnglish = getBahireHasab(2016, {'lang': 'english'});
        final evangelist =
            bahireHasabEnglish['evangelist'] as Map<String, dynamic>;
        final newYear = bahireHasabEnglish['newYear'] as Map<String, dynamic>;

        expect(evangelist['name'], equals('John'));
        expect(newYear['dayName'], equals('Tuesday'));
      });
    });

    group('Movable Feasts Calculation', () {
      late Map<String, dynamic> movableFeasts;

      setUp(() {
        final bahireHasab = getBahireHasab(2016, {'lang': 'english'});
        movableFeasts = bahireHasab['movableFeasts'] as Map<String, dynamic>;
      });

      test('should return a complete movableFeasts object', () {
        expect(movableFeasts, isNotNull);
        expect(movableFeasts.keys.length, greaterThan(5));
      });

      test('should correctly calculate the date for Fasika (Tinsaye)', () {
        final fasika = movableFeasts['fasika'] as Map<String, dynamic>;
        expect(fasika, isNotNull);

        final ethiopian = fasika['ethiopian'] as Map<String, int>;
        expect(ethiopian, equals({'year': 2016, 'month': 8, 'day': 27}));
        expect(fasika['name'], equals('Ethiopian Easter'));

        final tags = fasika['tags'] as List<String>;
        expect(tags, contains('public'));
      });

      test('should correctly calculate the date for Abiy Tsome', () {
        final abiyTsome = movableFeasts['abiyTsome'] as Map<String, dynamic>;
        expect(abiyTsome, isNotNull);

        final ethiopian = abiyTsome['ethiopian'] as Map<String, int>;
        expect(ethiopian, equals({'year': 2016, 'month': 7, 'day': 2}));
        expect(abiyTsome['name'], equals('Great Lent'));
      });
    });

    group('Error Handling', () {
      test('should throw InvalidInputTypeError for non-numeric input', () {
        // Since Dart's type system prevents passing strings to int parameters,
        // we'll test the validation logic by calling the validation function directly
        expect(
          () => validateNumericInputs('test', {'year': double.nan}),
          throwsA(isA<InvalidInputTypeError>()),
        );

        expect(
          () => validateNumericInputs('test', {'year': 'invalid'}),
          throwsA(isA<InvalidInputTypeError>()),
        );
      });

      test('should throw UnknownHolidayError for invalid holiday key', () {
        expect(
          () => getMovableHoliday('INVALID_HOLIDAY', 2016),
          throwsA(isA<UnknownHolidayError>()),
        );
      });
    });

    group('getMovableHoliday function', () {
      test('should return correct date for valid holiday key', () {
        final nineveh = getMovableHoliday('nineveh', 2016);
        expect(nineveh, equals({'year': 2016, 'month': 6, 'day': 18}));

        final fasika = getMovableHoliday('fasika', 2016);
        expect(fasika, equals({'year': 2016, 'month': 8, 'day': 27}));

        final abiyTsome = getMovableHoliday('abiyTsome', 2016);
        expect(abiyTsome, equals({'year': 2016, 'month': 7, 'day': 2}));
      });

      test('should handle different years correctly', () {
        final nineveh2020 = getMovableHoliday('nineveh', 2020);
        expect(nineveh2020['year'], equals(2020));

        final nineveh2021 = getMovableHoliday('nineveh', 2021);
        expect(nineveh2021['year'], equals(2021));
      });
    });

    group('BahireHasab class methods', () {
      test('should calculate base values correctly', () {
        final bahireHasab = BahireHasab.getBahireHasab(2016);

        // Test bealeMetqi calculation
        final bealeMetqi = bahireHasab['bealeMetqi'] as Map<String, dynamic>;
        expect(
          bealeMetqi['date'],
          equals({'year': 2016, 'month': 2, 'day': 10}),
        );
        expect(bealeMetqi['weekday'], equals('Saturday'));

        // Test mebajaHamer
        expect(bahireHasab['mebajaHamer'], equals(18));
      });

      test('should handle leap year calculations', () {
        // Test with a leap year
        final bahireHasabLeap = BahireHasab.getBahireHasab(2017);
        expect(bahireHasabLeap['ameteAlem'], equals(7517));

        // Test with non-leap year
        final bahireHasabNonLeap = BahireHasab.getBahireHasab(2018);
        expect(bahireHasabNonLeap['ameteAlem'], equals(7518));
      });
    });

    group('Edge cases and boundary conditions', () {
      test('should handle minimum year values', () {
        final bahireHasab = BahireHasab.getBahireHasab(1);
        expect(bahireHasab['ameteAlem'], equals(5501));
        expect(bahireHasab['meteneRabiet'], equals(1375));
      });

      test('should handle large year values', () {
        final bahireHasab = BahireHasab.getBahireHasab(10000);
        expect(bahireHasab['ameteAlem'], equals(15500));
        expect(bahireHasab['meteneRabiet'], equals(3875));
      });

      test('should maintain consistency across multiple calls', () {
        final result1 = BahireHasab.getBahireHasab(2016);
        final result2 = BahireHasab.getBahireHasab(2016);

        expect(result1['ameteAlem'], equals(result2['ameteAlem']));
        expect(result1['meteneRabiet'], equals(result2['meteneRabiet']));
        expect(result1['medeb'], equals(result2['medeb']));
        expect(result1['wenber'], equals(result2['wenber']));
      });
    });
  });
}
