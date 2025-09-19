import 'package:test/test.dart';

import 'package:kenat/src/time.dart';
import 'package:kenat/src/kenat.dart';
import 'package:kenat/src/errors/error_handler.dart';

void main() {
  group('Time Class and Related Logic', () {
    group('Constructor and Validation', () {
      test('should create a valid Time object', () {
        final time = Time(3, 30, 'day');
        expect(time.hour, 3);
        expect(time.minute, 30);
        expect(time.period, 'day');
      });

      test('should default minute and period correctly', () {
        final time = Time(5);
        expect(time.minute, 0);
        expect(time.period, 'day');
      });

      test('should throw InvalidTimeError for out-of-range values', () {
        expect(() => Time(0, 0, 'day'), throwsA(isA<InvalidTimeError>()));
        expect(() => Time(13, 0, 'day'), throwsA(isA<InvalidTimeError>()));
        expect(() => Time(5, -1, 'day'), throwsA(isA<InvalidTimeError>()));
        expect(() => Time(5, 60, 'day'), throwsA(isA<InvalidTimeError>()));
        expect(() => Time(5, 0, 'morning'), throwsA(isA<InvalidTimeError>()));
      });

      test('should throw InvalidInputTypeError for non-numeric inputs', () {
        expect(
          () => Time('three' as dynamic, 30),
          throwsA(isA<InvalidInputTypeError>()),
        );
        expect(
          () => Time(3, 'thirty' as dynamic),
          throwsA(isA<InvalidInputTypeError>()),
        );
      });
    });

    group('Time.fromString()', () {
      test('should parse valid strings with Arabic numerals', () {
        expect(Time.fromString('10:30 day'), Time(10, 30, 'day'));
        expect(Time.fromString('5:00 night'), Time(5, 0, 'night'));
      });

      test('should parse valid strings with Geez numerals', () {
        expect(Time.fromString('፫:፲፭ ማታ'), Time(3, 15, 'night'));
        expect(Time.fromString('፲፪:፴ day'), Time(12, 30, 'day'));
      });

      test('should default to "day" period when missing', () {
        expect(Time.fromString('11:45'), Time(11, 45, 'day'));
      });

      test('should handle inconsistent spacing', () {
        expect(Time.fromString(' 4 : 20  night '), Time(4, 20, 'night'));
      });

      test('should throw InvalidTimeError for malformed strings', () {
        expect(() => Time.fromString('10'), throwsA(isA<InvalidTimeError>()));
        expect(() => Time.fromString('10:'), throwsA(isA<InvalidTimeError>()));
        expect(() => Time.fromString(':30'), throwsA(isA<InvalidTimeError>()));
        expect(
          () => Time.fromString('10 30 day'),
          throwsA(isA<InvalidTimeError>()),
        );
        expect(
          () => Time.fromString('abc:def period'),
          throwsA(isA<InvalidTimeError>()),
        );
      });

      test('should throw InvalidTimeError for empty or whitespace strings', () {
        expect(() => Time.fromString(''), throwsA(isA<InvalidTimeError>()));
        expect(() => Time.fromString('   '), throwsA(isA<InvalidTimeError>()));
      });

      test(
        'should throw InvalidTimeError for valid format but out-of-range values',
        () {
          expect(
            () => Time.fromString('13:00 day'),
            throwsA(isA<InvalidTimeError>()),
          );
          expect(
            () => Time.fromString('5:60 night'),
            throwsA(isA<InvalidTimeError>()),
          );
        },
      );
    });

    group('Gregorian-Ethiopian Conversions', () {
      test('fromGregorian conversions', () {
        expect(Time.fromGregorian(7, 30), Time(1, 30, 'day'));
        expect(Time.fromGregorian(18, 0), Time(12, 0, 'night'));
        expect(Time.fromGregorian(0, 0), Time(6, 0, 'night'));
        expect(Time.fromGregorian(6, 0), Time(12, 0, 'day'));
      });

      test('toGregorian conversions', () {
        expect(Time(1, 30, 'day').toGregorian(), {'hour': 7, 'minute': 30});
        expect(Time(12, 0, 'night').toGregorian(), {'hour': 18, 'minute': 0});
        expect(Time(6, 0, 'night').toGregorian(), {'hour': 0, 'minute': 0});
        expect(Time(12, 0, 'day').toGregorian(), {'hour': 6, 'minute': 0});
      });

      test('fromGregorian should throw for invalid Gregorian time', () {
        expect(
          () => Time.fromGregorian(24, 0),
          throwsA(isA<InvalidTimeError>()),
        );
        expect(
          () => Time.fromGregorian(-1, 0),
          throwsA(isA<InvalidTimeError>()),
        );
      });
    });

    group('Time Arithmetic', () {
      final startTime = Time(3, 15, 'day');

      test(
        'add: should add hours and minutes correctly within the same period',
        () {
          final newTime = startTime.add({'hours': 2, 'minutes': 10});
          expect(newTime, Time(5, 25, 'day'));
        },
      );

      test(
        'add: should handle rolling over to the next period (day to night)',
        () {
          final newTime = startTime.add({'hours': 9});
          expect(newTime, Time(12, 15, 'night'));
        },
      );

      test('subtract: should subtract time correctly', () {
        final newTime = startTime.subtract({'hours': 1, 'minutes': 15});
        expect(newTime, Time(2, 0, 'day'));
      });

      test(
        'subtract: should handle rolling back to the previous period (day to night)',
        () {
          final newTime = Time(1, 0, 'day').subtract({'hours': 2});
          expect(newTime, Time(11, 0, 'night'));
        },
      );

      test('diff: should calculate the difference between two times', () {
        final endTime = Time(5, 45, 'day');
        final difference = startTime.diff(endTime);
        expect(difference, {'hours': 2, 'minutes': 30});
      });

      test(
        'diff: should calculate the shortest difference across the 24h wrap',
        () {
          final t1 = Time(2, 0, 'night');
          final t2 = Time(10, 0, 'night');
          final difference = t1.diff(t2);
          expect(difference, {'hours': 8, 'minutes': 0});
        },
      );

      test('add/subtract should throw on invalid duration', () {
        expect(
          () => startTime.add({'hours': 'two' as dynamic}),
          throwsA(isA<InvalidInputTypeError>()),
        );
        expect(
          () => startTime.subtract('one hour' as dynamic),
          throwsA(isA<InvalidTimeError>()),
        );
      });
    });

    group('Formatting', () {
      test('format: should format with default options (Geez)', () {
        final time = Time(5, 30, 'day');
        expect(time.format(), '፭:፴ ጠዋት');
      });

      test('format: should format with Arabic numerals', () {
        final time = Time(5, 30, 'day');
        expect(time.format({'useGeez': false}), '05:30 day');
      });

      test('format: should format without period label', () {
        final time = Time(8, 15, 'night');
        expect(
          time.format({'useGeez': false, 'showPeriodLabel': false}),
          '08:15',
        );
      });

      test('format: should use a dash for zero minutes', () {
        final time = Time(12, 0, 'day');
        expect(time.format({'useGeez': false, 'zeroAsDash': true}), '12:_ day');
      });
    });

    group('Kenat Time Methods', () {
      test('getCurrentTime returns a valid Time instance', () {
        final now = Kenat.now();
        final ethTime = now.getCurrentTime();
        expect(ethTime, isA<Time>());
        expect(ethTime.hour, isA<int>());
        expect(ethTime.minute, isA<int>());
        expect(['day', 'night'], contains(ethTime.period));
      });
    });
  });
}
