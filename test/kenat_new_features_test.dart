import 'package:test/test.dart';
import 'package:kenat/kenat.dart';

void main() {
  group('Kenat.toJson()', () {
    test('returns a serializable plain map', () {
      final kenat = Kenat.fromString('2017/1/15');
      final json = kenat.toJson();

      expect(json['ethiopian'], equals({'year': 2017, 'month': 1, 'day': 15}));
      expect(json['gregorian'], contains('year'));
      expect(json['gregorian'], contains('month'));
      expect(json['gregorian'], contains('day'));
      // A Kenat instance always carries a time (default noon-day), matching
      // TS's invariant - so json['time'] should not be null.
      expect(json['time'], isNotNull);
      expect(json['time'], contains('hour'));
      expect(json['time'], contains('minute'));
      expect(json['time'], contains('period'));
    });
  });

  group('Kenat isSameMonth/isSameYear', () {
    test('isSameMonth() true for dates in the same month and year', () {
      final a = Kenat.fromString('2017/5/1');
      final b = Kenat.fromString('2017/5/30');
      expect(a.isSameMonth(b), isTrue);
    });

    test('isSameMonth() false for different months', () {
      final a = Kenat.fromString('2017/5/15');
      final b = Kenat.fromString('2017/6/15');
      expect(a.isSameMonth(b), isFalse);
    });

    test('isSameMonth() false for same month, different year', () {
      final a = Kenat.fromString('2016/5/15');
      final b = Kenat.fromString('2017/5/15');
      expect(a.isSameMonth(b), isFalse);
    });

    test('isSameYear() true for dates in the same year', () {
      final a = Kenat.fromString('2017/1/1');
      final b = Kenat.fromString('2017/12/30');
      expect(a.isSameYear(b), isTrue);
    });

    test('isSameYear() false for dates in different years', () {
      final a = Kenat.fromString('2016/5/15');
      final b = Kenat.fromString('2017/5/15');
      expect(a.isSameYear(b), isFalse);
    });
  });

  group('Kenat endOf("year") / startOf("year")', () {
    test('endOf("year") returns Pagume 6 for leap years', () {
      // Ethiopian year 2015 has year % 4 === 3, so it IS a leap year.
      final leapYear = Kenat.fromString('2015/5/10');
      final end = leapYear.endOf('year');
      expect(end.getEthiopian(), equals({'year': 2015, 'month': 13, 'day': 6}));
    });

    test('endOf("year") returns Pagume 5 for non-leap years', () {
      final nonLeapYear = Kenat.fromString('2016/5/10');
      final end = nonLeapYear.endOf('year');
      expect(end.getEthiopian(), equals({'year': 2016, 'month': 13, 'day': 5}));
    });

    test('startOf("year") returns Meskerem 1', () {
      final k = Kenat.fromString('2016/5/10');
      final start = k.startOf('year');
      expect(start.getEthiopian(), equals({'year': 2016, 'month': 1, 'day': 1}));
    });
  });

  group('Calendar preference option (getDate/format/toString/toISOString)', () {
    // Meskerem 1, 2016 -> September 12, 2023
    final kenat = Kenat.fromString('2016/1/1');

    group('getDate()', () {
      test('defaults to the Ethiopian date', () {
        expect(kenat.getDate(), equals({'year': 2016, 'month': 1, 'day': 1}));
      });

      test('returns the Gregorian date when calendar is "gregorian"', () {
        expect(
          kenat.getDate(calendar: 'gregorian'),
          equals({'year': 2023, 'month': 9, 'day': 12}),
        );
      });
    });

    group('format()', () {
      test('defaults to Ethiopian formatting', () {
        expect(kenat.format(), equals('መስከረም 1 2016'));
      });

      test('formats the Gregorian date when calendar is "gregorian"', () {
        expect(
          kenat.format(calendar: 'gregorian'),
          equals('September 12, 2023'),
        );
      });

      test('supports showWeekday for the Gregorian calendar', () {
        // Weekday name still honors `lang` (default 'amharic'); the
        // Gregorian month name itself is always English.
        expect(
          kenat.format(calendar: 'gregorian', showWeekday: true),
          equals('ማክሰኞ, September 12, 2023'),
        );
        expect(
          kenat.format(calendar: 'gregorian', showWeekday: true, lang: 'english'),
          equals('Tuesday, September 12, 2023'),
        );
      });

      test('supports includeTime for the Gregorian calendar', () {
        final timedKenat = Kenat.fromString(
          '2016/1/1',
          hour: 8,
          minute: 30,
          period: 'day',
        );
        expect(
          timedKenat.format(calendar: 'gregorian', includeTime: true),
          equals('September 12, 2023 08:30 ጠዋት'),
        );
      });
    });

    group('toString / toStringWithOptions', () {
      test('toString() defaults to the Ethiopian representation', () {
        expect(kenat.toString(), contains('መስከረም 1 2016'));
      });

      test('toStringWithOptions renders Gregorian when requested', () {
        expect(
          kenat.toStringWithOptions(calendar: 'gregorian'),
          contains('September 12, 2023'),
        );
      });
    });

    group('toISOString()', () {
      test('defaults to the Ethiopian ISO-style date', () {
        expect(kenat.toISOString(), equals('2016-01-01T12:00'));
      });

      test('appends +12h suffix for a night time on the Ethiopian calendar', () {
        final nightKenat = Kenat.fromString(
          '2016/1/1',
          hour: 8,
          minute: 15,
          period: 'night',
        );
        expect(nightKenat.toISOString(), equals('2016-01-01T08:15+12h'));
      });

      test('returns Gregorian ISO date with time converted to 24-hour format', () {
        // 12:00 day Ethiopian time is 06:00 Gregorian, not 12:00.
        expect(
          kenat.toISOString(calendar: 'gregorian'),
          equals('2023-09-12T06:00'),
        );
      });

      test('converts night time to Gregorian 24-hour format with no suffix', () {
        final nightKenat = Kenat.fromString(
          '2016/1/1',
          hour: 8,
          minute: 15,
          period: 'night',
        );
        final iso = nightKenat.toISOString(calendar: 'gregorian');
        expect(iso, equals('2023-09-12T02:15'));
        expect(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$').hasMatch(iso), isTrue);
      });
    });
  });

  group('Kenat.isHoliday', () {
    test('returns holiday entries for a holiday date', () {
      final k = Kenat.fromString('2016/1/1'); // Enkutatash
      final holidays = k.isHoliday();
      expect(holidays, isNotEmpty);
      expect(holidays.any((h) => h['key'] == 'enkutatash'), isTrue);
    });

    test('returns empty list for a non-holiday date', () {
      final k = Kenat.fromString('2016/2/2');
      final holidays = k.isHoliday();
      expect(holidays, isEmpty);
    });
  });

  group('Kenat.setTime immutability', () {
    test('setTime always returns a new Kenat instance, never mutates', () {
      final original = Kenat.fromString('2017/1/1');
      final updated = original.setTime(6, 30, 'night');

      expect(identical(original, updated), isFalse);
      expect(updated.time!.hour, equals(6));
      expect(updated.time!.minute, equals(30));
      expect(updated.time!.period, equals('night'));
      // Original instance's own time is unaffected by the call.
      expect(original.time!.hour, isNot(equals(6)));
    });

    test('setTime accepts a Time instance directly (Dart convenience)', () {
      final original = Kenat.fromString('2017/1/1');
      final updated = original.setTime(Time(3, 15, 'day'));
      expect(updated.time!.hour, equals(3));
      expect(updated.time!.minute, equals(15));
    });
  });

  group('Kenat.getCalendarDays (TS-matching flat calendar array)', () {
    test('returns 30 days for a standard Ethiopian month', () {
      final k = Kenat.fromString('2015/1/1');
      final calendar = k.getCalendarDays(2015, 1);
      expect(calendar.length, equals(30));
    });

    test('returns 6 days for Pagume in a leap year', () {
      final k = Kenat.fromString('2011/13/1');
      final calendar = k.getCalendarDays(2011, 13);
      expect(calendar.length, equals(6));
    });

    test('returns 5 days for Pagume in a non-leap year', () {
      final k = Kenat.fromString('2012/13/1');
      final calendar = k.getCalendarDays(2012, 13);
      expect(calendar.length, equals(5));
    });

    test('each day includes formatted Ethiopian and Gregorian display fields', () {
      final k = Kenat.fromString('2015/2/1');
      final calendar = k.getCalendarDays(2015, 2, false);
      final day = calendar[0];

      expect(day['ethiopian'], contains('display'));
      expect(day['gregorian'], contains('display'));
      expect(day['ethiopian']['display'], isA<String>());
      expect(day['gregorian']['display'], isA<String>());
    });

    test('formats Geez numerals when useGeez = true', () {
      final k = Kenat.fromString('2015/1/1');
      final calendar = k.getCalendarDays(2015, 1, true);
      final day = calendar[0];
      final geezRegex = RegExp(r'[፩-፼]');
      expect(geezRegex.hasMatch(day['ethiopian']['display']), isTrue);
    });
  });

  group('Kenat static getStaticMonthCalendar / getYearCalendar', () {
    test('getStaticMonthCalendar returns headers/days/monthName/year', () {
      final result = Kenat.getStaticMonthCalendar(2016, 1);
      expect(result['month'], equals(1));
      expect(result['headers'], isA<List>());
      expect(result['days'], isA<List>());
      expect(result['monthName'], isA<String>());
    });

    test('getYearCalendar returns 13 month entries', () {
      final result = Kenat.getYearCalendar(2016);
      expect(result.length, equals(13));
      expect(result.first['month'], equals(1));
      expect(result.last['month'], equals(13));
    });
  });

  group('Kenat.generateDateRange', () {
    test('generates an inclusive range of Kenat instances', () {
      final start = Kenat.fromString('2016/1/1');
      final end = Kenat.fromString('2016/1/5');
      final range = Kenat.generateDateRange(start, end);

      expect(range.length, equals(5));
      expect(range.first.getEthiopian(), equals({'year': 2016, 'month': 1, 'day': 1}));
      expect(range.last.getEthiopian(), equals({'year': 2016, 'month': 1, 'day': 5}));
    });

    test('returns an empty list when start is after end', () {
      final start = Kenat.fromString('2016/1/5');
      final end = Kenat.fromString('2016/1/1');
      final range = Kenat.generateDateRange(start, end);
      expect(range, isEmpty);
    });
  });

  group('Kenat distance helpers', () {
    test('distanceTo returns a breakdown with sign/totalDays/years/months/days', () {
      final a = Kenat.fromString('2016/1/1');
      final b = Kenat.fromString('2018/3/15');
      final result = a.distanceTo(b) as Map<String, dynamic>;

      expect(result['totalDays'], greaterThan(0));
      expect(result['years'], equals(2));
      expect(result['months'], equals(2));
      expect(result['days'], equals(14));
    });

    test('distanceTo with output:string returns a formatted string', () {
      final a = Kenat.fromString('2016/1/1');
      final b = Kenat.fromString('2018/3/15');
      final result = a.distanceTo(b, {'output': 'string'});
      expect(result, isA<String>());
      expect(result, contains('year'));
    });

    test('distanceFromToday returns a breakdown relative to now', () {
      final future = Kenat.now().addYears(1);
      final result = future.distanceFromToday() as Map<String, dynamic>;
      expect(result['totalDays'], greaterThanOrEqualTo(0));
    });

    test('distanceToHoliday returns a breakdown for a known holiday key', () {
      final result = Kenat.distanceToHoliday('meskel');
      expect(result, isA<Map<String, dynamic>>());
      final map = result as Map<String, dynamic>;
      expect(map, contains('totalDays'));
    });

    test('formatDistance formats a breakdown into a human string', () {
      final breakdown = {'sign': 1, 'totalDays': 400, 'years': 1, 'months': 1, 'days': 5};
      final formatted = Kenat.formatDistance(breakdown);
      expect(formatted, equals('1 year 1 month 5 days'));
    });
  });

  group('Kenat error subclass type reporting', () {
    test("toJson()['type'] reflects the concrete error subclass", () {
      try {
        toGC(2016, 14, 1);
        fail('expected toGC to throw');
      } catch (e) {
        expect(e, isA<InvalidEthiopianDateError>());
        expect((e as KenatError).toJson()['type'], equals('InvalidEthiopianDateError'));
      }

      try {
        getMovableHoliday('NOT_A_REAL_KEY', 2016);
        fail('expected getMovableHoliday to throw');
      } catch (e) {
        expect(e, isA<UnknownHolidayError>());
        final json = (e as KenatError).toJson();
        expect(json['type'], equals('UnknownHolidayError'));
        expect(json['holidayKey'], equals('NOT_A_REAL_KEY'));
      }
    });
  });
}
