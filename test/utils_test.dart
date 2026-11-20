import 'package:test/test.dart';

import 'package:kenat/src/utils.dart';

void main() {
  group('dayOfYear', () {
    test('returns 1 for January 1st of a non-leap year', () {
      expect(dayOfYear(2023, 1, 1), 1);
    });

    test('returns 32 for February 1st of a non-leap year', () {
      expect(dayOfYear(2023, 2, 1), 32);
    });

    test('returns 59 for February 28th of a non-leap year', () {
      expect(dayOfYear(2023, 2, 28), 59);
    });

    test('returns 60 for March 1st of a non-leap year', () {
      expect(dayOfYear(2023, 3, 1), 60);
    });

    test('returns 60 for February 29th of a leap year', () {
      expect(dayOfYear(2024, 2, 29), 60);
    });

    test('returns 61 for March 1st of a leap year', () {
      expect(dayOfYear(2024, 3, 1), 61);
    });

    test('returns 365 for December 31st of a non-leap year', () {
      expect(dayOfYear(2023, 12, 31), 365);
    });

    test('returns 366 for December 31st of a leap year', () {
      expect(dayOfYear(2024, 12, 31), 366);
    });
  });

  group('monthDayFromDayOfYear', () {
    test('returns January 1 for day 1 of a non-leap year', () {
      expect(monthDayFromDayOfYear(2023, 1), {'month': 1, 'day': 1});
    });

    test('returns January 31 for day 31 of a non-leap year', () {
      expect(monthDayFromDayOfYear(2023, 31), {'month': 1, 'day': 31});
    });

    test('returns February 1 for day 32 of a non-leap year', () {
      expect(monthDayFromDayOfYear(2023, 32), {'month': 2, 'day': 1});
    });

    test('returns February 28 for day 59 of a non-leap year', () {
      expect(monthDayFromDayOfYear(2023, 59), {'month': 2, 'day': 28});
    });

    test('returns March 1 for day 60 of a non-leap year', () {
      expect(monthDayFromDayOfYear(2023, 60), {'month': 3, 'day': 1});
    });

    test('returns February 29 for day 60 of a leap year', () {
      expect(monthDayFromDayOfYear(2024, 60), {'month': 2, 'day': 29});
    });

    test('returns March 1 for day 61 of a leap year', () {
      expect(monthDayFromDayOfYear(2024, 61), {'month': 3, 'day': 1});
    });

    test('returns December 31 for day 365 of a non-leap year', () {
      expect(monthDayFromDayOfYear(2023, 365), {'month': 12, 'day': 31});
    });

    test('returns December 31 for day 366 of a leap year', () {
      expect(monthDayFromDayOfYear(2024, 366), {'month': 12, 'day': 31});
    });
  });

  group('isGregorianLeapYear', () {
    test('returns true for years divisible by 4 but not by 100', () {
      expect(isGregorianLeapYear(2024), isTrue);
      expect(isGregorianLeapYear(1996), isTrue);
      expect(isGregorianLeapYear(2008), isTrue);
    });

    test('returns false for years not divisible by 4', () {
      expect(isGregorianLeapYear(2023), isFalse);
      expect(isGregorianLeapYear(2019), isFalse);
      expect(isGregorianLeapYear(2101), isFalse);
    });

    test('returns false for years divisible by 100 but not by 400', () {
      expect(isGregorianLeapYear(1900), isFalse);
      expect(isGregorianLeapYear(2100), isFalse);
      expect(isGregorianLeapYear(1800), isFalse);
    });

    test('returns true for years divisible by 400', () {
      expect(isGregorianLeapYear(2000), isTrue);
      expect(isGregorianLeapYear(1600), isTrue);
      expect(isGregorianLeapYear(2400), isTrue);
    });
  });

  group('isEthiopianLeapYear', () {
    test('returns true for Ethiopian years where year % 4 === 3', () {
      expect(isEthiopianLeapYear(2011), isTrue);
      expect(isEthiopianLeapYear(2015), isTrue);
      expect(isEthiopianLeapYear(2019), isTrue);
      expect(isEthiopianLeapYear(2003), isTrue);
    });

    test('returns false for Ethiopian years where year % 4 !== 3', () {
      expect(isEthiopianLeapYear(2010), isFalse);
      expect(isEthiopianLeapYear(2012), isFalse);
      expect(isEthiopianLeapYear(2013), isFalse);
      expect(isEthiopianLeapYear(2014), isFalse);
      expect(isEthiopianLeapYear(2020), isFalse);
    });
  });

  group('getEthiopianDaysInMonth', () {
    test('returns 30 for any month from 1 to 12', () {
      for (var month = 1; month <= 12; month++) {
        expect(getEthiopianDaysInMonth(2010, month), 30);
        expect(getEthiopianDaysInMonth(2011, month), 30);
        expect(getEthiopianDaysInMonth(2012, month), 30);
        expect(getEthiopianDaysInMonth(2013, month), 30);
      }
    });

    test('returns 6 for month 13 in a leap year', () {
      expect(getEthiopianDaysInMonth(2011, 13), 6);
      expect(getEthiopianDaysInMonth(2015, 13), 6);
      expect(getEthiopianDaysInMonth(2019, 13), 6);
    });

    test('returns 5 for month 13 in a non-leap year', () {
      expect(getEthiopianDaysInMonth(2010, 13), 5);
      expect(getEthiopianDaysInMonth(2012, 13), 5);
      expect(getEthiopianDaysInMonth(2013, 13), 5);
      expect(getEthiopianDaysInMonth(2014, 13), 5);
      expect(getEthiopianDaysInMonth(2020, 13), 5);
    });
  });

  group('Ethiopian New Year helpers', () {
    test('getGregorianDateOfEthiopianNewYear follows the Ethiopian leap cycle',
        () {
      expect(getGregorianDateOfEthiopianNewYear(2016),
          {'gregorianYear': 2023, 'month': 9, 'day': 12});
      expect(getGregorianDateOfEthiopianNewYear(2017),
          {'gregorianYear': 2024, 'month': 9, 'day': 11});
      expect(getGregorianDateOfEthiopianNewYear(1888),
          {'gregorianYear': 1895, 'month': 9, 'day': 11});
      expect(getGregorianDateOfEthiopianNewYear(1892),
          {'gregorianYear': 1899, 'month': 9, 'day': 11});
      expect(getGregorianDateOfEthiopianNewYear(2092),
          {'gregorianYear': 2099, 'month': 9, 'day': 12});
      expect(getGregorianDateOfEthiopianNewYear(2093),
          {'gregorianYear': 2100, 'month': 9, 'day': 12});
    });

    test('getEthiopianNewYearForGregorian returns Meskerem 1 of year G - 7',
        () {
      expect(getEthiopianNewYearForGregorian(2023),
          {'gregorianYear': 2023, 'month': 9, 'day': 12});
      expect(getEthiopianNewYearForGregorian(2024),
          {'gregorianYear': 2024, 'month': 9, 'day': 11});
      expect(getEthiopianNewYearForGregorian(1895),
          {'gregorianYear': 1895, 'month': 9, 'day': 11});
      expect(getEthiopianNewYearForGregorian(2100),
          {'gregorianYear': 2100, 'month': 9, 'day': 12});
    });
  });
}
