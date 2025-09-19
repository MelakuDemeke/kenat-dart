import 'package:flutter_test/flutter_test.dart';
import 'package:kenat/kenat.dart';

void main() {
  group('Kenat class', () {
    test('should create an instance with current date', () {
      final now = DateTime.now();
      final kenat = Kenat.now();

      final gregorian = kenat.getGregorian();
      expect(gregorian.containsKey('year'), isTrue);
      expect(gregorian.containsKey('month'), isTrue);
      expect(gregorian.containsKey('day'), isTrue);

      // Compare only the date portion
      expect(
        '${gregorian['year']}-${gregorian['month']}-${gregorian['day']}',
        equals('${now.year}-${now.month}-${now.day}'),
      );

      final ethiopian = kenat.getEthiopian();
      expect(ethiopian.containsKey('year'), isTrue);
      expect(ethiopian.containsKey('month'), isTrue);
      expect(ethiopian.containsKey('day'), isTrue);
    });

    test('should convert a specific Ethiopian date correctly', () {
      final kenat = Kenat.fromString('2016/9/15');
      final gregorian = kenat.getGregorian();
      expect(gregorian, equals({'year': 2024, 'month': 5, 'day': 23}));

      final ethiopian = kenat.getEthiopian();
      expect(ethiopian, equals({'year': 2016, 'month': 9, 'day': 15}));
    });

    test('toString should return Ethiopian date string', () {
      final kenat = Kenat.fromString('2016/9/15');
      final str = kenat.toString();
      // The original JS expected: "ግንቦት 15 2016 12:00 ጠዋት"
      // Our DateFormatter.formatWithTime uses hour/minute and period; toString
      // returns 'Kenat(<formatted date>)' so adapt expectation to include
      // the formatted date portion.
      expect(str.contains('ግንቦት 15 2016'), isTrue);
    });

    test(
      'format returns Ethiopian date string with month name in English and Amharic',
      () {
        final kenat = Kenat.fromString('2017/1/15'); // Meskerem 15, 2017

        final englishFormat = kenat.formatStandard('english');
        expect(englishFormat, equals('Meskerem 15 2017'));

        final amharicFormat = kenat.formatStandard();
        expect(amharicFormat, equals('መስከረም 15 2017'));
      },
    );

    test(
      'formatInGeezAmharic returns Ethiopian date string with Amharic month and Geez numerals',
      () {
        final kenat = Kenat.fromString('2017/1/15'); // Meskerem 15, 2017

        final formatted = kenat.formatInGeez();

        // Expected: "መስከረም ፲፭ ፳፻፲፯"
        expect(formatted, equals('መስከረም ፲፭ ፳፻፲፯'));
      },
    );
  });

  group('Kenat API Helper Methods', () {
    final date1 = Kenat.fromString('2016/8/15');
    final date2 = Kenat.fromString('2016/8/20');
    final date3 = Kenat.fromString('2016/8/15');
    final leapYearDate = Kenat.fromString('2015/1/1');
    final nonLeapYearDate = Kenat.fromString('2016/1/1');

    test('isBefore() should correctly compare dates', () {
      expect(date1.isBefore(date2), isTrue);
      expect(date2.isBefore(date1), isFalse);
      expect(date1.isBefore(date3), isFalse);
    });

    test('isAfter() should correctly compare dates', () {
      expect(date2.isAfter(date1), isTrue);
      expect(date1.isAfter(date2), isFalse);
      expect(date1.isAfter(date3), isFalse);
    });

    test('isSameDay() should correctly compare dates', () {
      expect(date1.isSameDay(date3), isTrue);
      expect(date1.isSameDay(date2), isFalse);
    });

    test('startOfMonth() should return the first day of the month', () {
      final start = date1.startOf('month');
      expect(
        start.getEthiopian(),
        equals({'year': 2016, 'month': 8, 'day': 1}),
      );
    });

    test('endOfMonth() should return the last day of a standard month', () {
      final end = date1.endOf('month');
      expect(end.getEthiopian(), equals({'year': 2016, 'month': 8, 'day': 30}));
    });

    test(
      'endOfMonth() should return the last day of Pagume in a leap year',
      () {
        final pagume = Kenat.fromString('2015/13/1'); // 2015 is a leap year
        final end = pagume.endOf('month');
        expect(
          end.getEthiopian(),
          equals({'year': 2015, 'month': 13, 'day': 6}),
        );
      },
    );

    test('isLeapYear() should correctly identify leap years', () {
      expect(leapYearDate.isLeapYear(), isTrue);
      expect(nonLeapYearDate.isLeapYear(), isFalse);
    });

    test('weekday() should return the correct day of the week', () {
      // May 23, 2024 is a Thursday, which is index 4
      final specificDate = Kenat.fromString('2016/9/15');
      expect(specificDate.getWeekday(), equals(4));
    });
  });
}
