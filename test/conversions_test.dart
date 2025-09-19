import 'package:test/test.dart';
import 'package:kenat/src/conversions.dart';
import 'package:kenat/src/errors/error_handler.dart';

void main() {
  group('Ethiopian to Gregorian conversion', () {
    test('Ethiopian to Gregorian: 2017-9-14 -> May 22, 2025', () {
      final result = toGC(2017, 9, 14);
      expect(result, equals({'year': 2025, 'month': 5, 'day': 22}));
    });

    test(
      'Ethiopian to Gregorian: Pagumē 5, 2016 (2016-13-5) -> September 10, 2024',
      () {
        final result = toGC(2016, 13, 5);
        expect(result, equals({'year': 2024, 'month': 9, 'day': 10}));
      },
    );

    test(
      'Ethiopian to Gregorian Leap Year: 2011-13-6 (Pagumē 6, 2011) -> September 11, 2019',
      () {
        final result = toGC(2011, 13, 6);
        expect(result, equals({'year': 2019, 'month': 9, 'day': 11}));
      },
    );

    test(
      'Ethiopian to Gregorian Leap Year: Pagumē 6, 2019 (2019-13-6) -> September 11, 2027',
      () {
        final result = toGC(2019, 13, 6);
        expect(result, equals({'year': 2027, 'month': 9, 'day': 11}));
      },
    );

    test(
      'Ethiopian to Gregorian Leap Year: May 5, 2024 -> Miazia 27, 2016',
      () {
        final result = toGC(2016, 8, 27);
        expect(result, equals({'year': 2024, 'month': 5, 'day': 5}));
      },
    );

    test(
      'Ethiopian to Gregorian: Meskerem 1, 2016 (2016-1-1) -> September 11, 2023',
      () {
        final result = toGC(2016, 1, 1);
        expect(result, equals({'year': 2023, 'month': 9, 'day': 12}));
      },
    );

    test(
      'Ethiopian to Gregorian: Tahsas 30, 2015 (2015-4-30) -> January 8, 2023',
      () {
        final result = toGC(2015, 4, 30);
        expect(result, equals({'year': 2023, 'month': 1, 'day': 8}));
      },
    );

    test(
      'Ethiopian to Gregorian: Pagume 1, 2011 (2011-13-1) -> September 6, 2019',
      () {
        final result = toGC(2011, 13, 1);
        expect(result, equals({'year': 2019, 'month': 9, 'day': 6}));
      },
    );

    test(
      'Ethiopian to Gregorian: Meskerem 1, 1964 (1964-1-1) -> September 12, 1971',
      () {
        final result = toGC(1964, 1, 1);
        expect(result, equals({'year': 1971, 'month': 9, 'day': 12}));
      },
    );

    test(
      'Ethiopian to Gregorian: Pagume 6, 2007 (leap Pagume) -> September 11, 2015',
      () {
        final result = toGC(2007, 13, 6);
        expect(result, equals({'year': 2015, 'month': 9, 'day': 11}));
      },
    );

    test(
      'Ethiopian to Gregorian: Pagume 5, 2006 (non-leap Pagume) -> September 10, 2014',
      () {
        final result = toGC(2006, 13, 5);
        expect(result, equals({'year': 2014, 'month': 9, 'day': 10}));
      },
    );

    test(
      'Ethiopian to Gregorian: End of Ethiopian year (Pagume 5, 2015) -> September 10, 2023',
      () {
        final result = toGC(2015, 13, 5);
        expect(result, equals({'year': 2023, 'month': 9, 'day': 10}));
      },
    );

    test(
      'Ethiopian to Gregorian: Start of Ethiopian year (Meskerem 1, 2015) -> September 11, 2022',
      () {
        final result = toGC(2015, 1, 1);
        expect(result, equals({'year': 2022, 'month': 9, 'day': 11}));
      },
    );
  });

  group('Gregorian to Ethiopian conversion', () {
    test('Gregorian to Ethiopian: May 22, 2025 -> 2017-9-14', () {
      final result = toEC(2025, 5, 22);
      expect(result, equals({'year': 2017, 'month': 9, 'day': 14}));
    });

    test(
      'Gregorian to Ethiopian Leap Year: February 29, 2020 -> Yekatit 22, 2012',
      () {
        final result = toEC(2020, 2, 29);
        expect(result, equals({'year': 2012, 'month': 6, 'day': 21}));
      },
    );

    test(
      'Gregorian to Ethiopian Leap Year: May 5, 2024 -> Miazia 27, 2016',
      () {
        final result = toEC(2024, 5, 5);
        expect(result, equals({'year': 2016, 'month': 8, 'day': 27}));
      },
    );

    test(
      'Gregorian to Ethiopian: September 10, 2024 -> 2016-13-5 (Pagumē 5, 2016)',
      () {
        final result = toEC(2024, 9, 10);
        expect(result, equals({'year': 2016, 'month': 13, 'day': 5}));
      },
    );

    test(
      'Gregorian to Ethiopian Leap Year: September 11, 2019 -> 2011-13-6 (Pagumē 6, 2011)',
      () {
        final result = toEC(2019, 9, 11);
        expect(result, equals({'year': 2011, 'month': 13, 'day': 6}));
      },
    );

    test(
      'Gregorian to Ethiopian Leap Year: September 11, 2027 -> 2019-13-6 (Pagumē 6, 2019)',
      () {
        final result = toEC(2027, 9, 11);
        expect(result, equals({'year': 2019, 'month': 13, 'day': 6}));
      },
    );

    test('Gregorian to Ethiopian: January 1, 2000 -> 1992-4-23', () {
      final result = toEC(2000, 1, 1);
      expect(result, equals({'year': 1992, 'month': 4, 'day': 22}));
    });

    test('Gregorian to Ethiopian: Out of range year throws error', () {
      expect(() => toEC(1800, 1, 1), throwsA(isA<InvalidGregorianDateError>()));
      expect(() => toEC(2200, 1, 1), throwsA(isA<InvalidGregorianDateError>()));
    });

    test(
      'Gregorian to Ethiopian: September 12, 1971 (base date) -> 1964-1-1',
      () {
        final result = toEC(1971, 9, 12);
        expect(result, equals({'year': 1964, 'month': 1, 'day': 1}));
      },
    );

    test(
      'Gregorian to Ethiopian: December 31, 2100 (upper bound) -> valid Ethiopian date',
      () {
        final result = toEC(2100, 12, 31);
        expect(result['year'], greaterThanOrEqualTo(2092));
        expect(result['month'], greaterThanOrEqualTo(4));
        expect(result['day'], greaterThanOrEqualTo(20));
      },
    );

    test(
      'Gregorian to Ethiopian: January 1, 1900 (lower bound) -> valid Ethiopian date',
      () {
        final result = toEC(1900, 1, 1);
        expect(result['year'], lessThanOrEqualTo(1892));
        expect(result['month'], greaterThanOrEqualTo(4));
        expect(result['day'], greaterThanOrEqualTo(22));
      },
    );

    test(
      'Gregorian to Ethiopian: End of Gregorian leap year (December 31, 2020)',
      () {
        final result = toEC(2020, 12, 31);
        expect(result, equals({'year': 2013, 'month': 4, 'day': 22}));
      },
    );

    test(
      'Gregorian to Ethiopian: Start of Gregorian leap year (January 1, 2020)',
      () {
        final result = toEC(2020, 1, 1);
        expect(result, equals({'year': 2012, 'month': 4, 'day': 22}));
      },
    );

    test(
      'Gregorian to Ethiopian: Last day of Ethiopian year (September 10, 2023)',
      () {
        final result = toEC(2023, 9, 10);
        expect(result, equals({'year': 2015, 'month': 13, 'day': 5}));
      },
    );

    test('Gregorian to Ethiopian: Leap Pagume (September 11, 2015)', () {
      final result = toEC(2023, 9, 11);
      expect(result, equals({'year': 2015, 'month': 13, 'day': 6}));
    });
  });

  group('DateTime conversion functions', () {
    test('toGCDate: Ethiopian to DateTime object', () {
      final dateTime = toGCDate(2017, 9, 14);
      expect(dateTime.year, equals(2025));
      expect(dateTime.month, equals(5));
      expect(dateTime.day, equals(22));
    });

    test('fromDateToEC: DateTime to Ethiopian', () {
      final dateTime = DateTime.utc(2025, 5, 22);
      final result = fromDateToEC(dateTime);
      expect(result, equals({'year': 2017, 'month': 9, 'day': 14}));
    });

    test('Round-trip conversion: Ethiopian -> DateTime -> Ethiopian', () {
      const ethYear = 2017;
      const ethMonth = 9;
      const ethDay = 14;

      final dateTime = toGCDate(ethYear, ethMonth, ethDay);
      final backToEth = fromDateToEC(dateTime);

      expect(backToEth['year'], equals(ethYear));
      expect(backToEth['month'], equals(ethMonth));
      expect(backToEth['day'], equals(ethDay));
    });

    test('Round-trip conversion: Gregorian -> Ethiopian -> Gregorian', () {
      const gregYear = 2025;
      const gregMonth = 5;
      const gregDay = 22;

      final ethDate = toEC(gregYear, gregMonth, gregDay);
      final backToGreg = toGC(
        ethDate['year']!,
        ethDate['month']!,
        ethDate['day']!,
      );

      expect(backToGreg['year'], equals(gregYear));
      expect(backToGreg['month'], equals(gregMonth));
      expect(backToGreg['day'], equals(gregDay));
    });
  });

  group('Islamic/Hijri conversion functions', () {
    test('getHijriYear: Basic calculation', () {
      final date = DateTime.utc(2024, 1, 1);
      final hijriYear = getHijriYear(date);
      expect(hijriYear, greaterThan(1400));
      expect(hijriYear, lessThan(1500));
    });

    test('gregorianToHijri: Basic conversion', () {
      final date = DateTime.utc(2024, 1, 1);
      final hijri = gregorianToHijri(date);
      expect(hijri, containsPair('hijriYear', greaterThan(1400)));
      expect(hijri, containsPair('hijriMonth', greaterThan(0)));
      expect(hijri, containsPair('hijriDay', greaterThan(0)));
    });

    test('hijriToGregorian: Valid conversion', () {
      final result = hijriToGregorian(1445, 1, 1, 2023);
      expect(result, isNotNull);
      if (result != null) {
        expect(result.year, equals(2023));
      }
    });

    test('hijriToGregorian: Invalid conversion returns null', () {
      final result = hijriToGregorian(1445, 1, 1, 2024);
      expect(result, isNull);
    });
  });

  group('Error handling', () {
    test('toGC: Invalid Ethiopian date throws error', () {
      expect(
        () => toGC(2016, 14, 1), // Invalid month
        throwsA(isA<InvalidEthiopianDateError>()),
      );

      expect(
        () => toGC(2016, 13, 7), // Invalid day for non-leap year
        throwsA(isA<InvalidEthiopianDateError>()),
      );
    });

    test('toEC: Invalid Gregorian date throws error', () {
      expect(
        () => toEC(2024, 2, 30), // Invalid day
        throwsA(isA<InvalidGregorianDateError>()),
      );

      expect(
        () => toEC(2024, 13, 1), // Invalid month
        throwsA(isA<InvalidGregorianDateError>()),
      );
    });

    test('Conversions class methods work correctly', () {
      // Test static methods of Conversions class
      final result1 = Conversions.toGC(2017, 9, 14);
      expect(result1, equals({'year': 2025, 'month': 5, 'day': 22}));

      final result2 = Conversions.toEC(2025, 5, 22);
      expect(result2, equals({'year': 2017, 'month': 9, 'day': 14}));
    });
  });
}
