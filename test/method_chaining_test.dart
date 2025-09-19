import 'package:test/test.dart';

import 'package:kenat/kenat.dart';

void main() {
  group('Method Chaining Tests', () {
    test('should support chaining add operations', () {
      final date = Kenat.fromString('2017/1/1');
      final future = date.add(7, 'days').add(1, 'months').add(1, 'years');

      expect(future.getEthiopian(), {'year': 2018, 'month': 2, 'day': 8});
    });

    test('should support chaining subtract operations', () {
      final date = Kenat.fromString('2017/1/1');
      final past = date
          .subtract(7, 'days')
          .subtract(1, 'months')
          .subtract(1, 'years');

      expect(past.getEthiopian(), {'year': 2015, 'month': 11, 'day': 29});
    });

    test('should support mixed add and subtract operations', () {
      final date = Kenat.fromString('2017/1/1');
      final result = date.add(7, 'days').subtract(1, 'months').add(1, 'years');

      expect(result.getEthiopian(), {'year': 2017, 'month': 13, 'day': 5});
    });

    test('should preserve time during arithmetic operations', () {
      final date = Kenat.fromString(
        '2017/1/1',
        hour: 3,
        minute: 30,
        period: 'day',
      );
      final future = date.add(7, 'days').add(1, 'months');

      expect(future.getEthiopian(), {'year': 2017, 'month': 2, 'day': 8});
      expect(future.time!.hour, 3);
      expect(future.time!.minute, 30);
      expect(future.time!.period, 'day');
    });

    test('should support chaining with startOf and endOf', () {
      final date = Kenat.fromString('2017/6/15');
      final result = date.startOf('month').add(7, 'days').endOf('day');

      expect(result.getEthiopian(), {'year': 2017, 'month': 6, 'day': 8});
      expect(result.time!.hour, 12);
      expect(result.time!.period, 'night');
    });

    test('should support chaining with setTime', () {
      final date = Kenat.fromString('2017/1/1');
      final result = date
          .add(7, 'days')
          .setTime(6, 30, 'night')
          .add(1, 'months');

      expect(result.getEthiopian(), {'year': 2017, 'month': 2, 'day': 8});
      expect(result.time!.hour, 6);
      expect(result.time!.minute, 30);
      expect(result.time!.period, 'night');
    });

    test('should maintain immutability - original date unchanged', () {
      final original = Kenat.fromString('2017/1/1');
      final modified = original.add(7, 'days').add(1, 'months');

      expect(original.getEthiopian(), {'year': 2017, 'month': 1, 'day': 1});
      expect(modified.getEthiopian(), {'year': 2017, 'month': 2, 'day': 8});
    });

    test('should handle leap year correctly in chaining', () {
      final date = Kenat.fromString('2015/13/6'); // Leap year Pagume
      final result = date.add(1, 'days').add(1, 'months');

      expect(result.getEthiopian(), {'year': 2016, 'month': 2, 'day': 1});
    });

    test('should handle month boundaries correctly in chaining', () {
      final date = Kenat.fromString('2017/1/30'); // Last day of Meskerem
      final result = date.add(1, 'days').add(1, 'months');

      expect(result.getEthiopian(), {'year': 2017, 'month': 3, 'day': 1});
    });

    test('should support complex chaining operations', () {
      final date = Kenat.fromString('2017/1/1');
      final result = date
          .startOf('month')
          .add(14, 'days')
          .setTime(12, 0, 'day')
          .add(1, 'months')
          .endOf('day')
          .add(1, 'years');

      expect(result.getEthiopian(), {'year': 2018, 'month': 2, 'day': 15});
      expect(result.time!.hour, 12);
      expect(result.time!.period, 'night');
    });

    test('should throw error for invalid unit in add()', () {
      final date = Kenat.fromString('2017/1/1');
      expect(() => date.add(1, 'weeks'), throwsA(isA<ArgumentError>()));
    });

    test('should throw error for invalid unit in startOf()', () {
      final date = Kenat.fromString('2017/1/1');
      expect(() => date.startOf('week'), throwsA(isA<ArgumentError>()));
    });

    test('should throw error for invalid unit in endOf()', () {
      final date = Kenat.fromString('2017/1/1');
      expect(() => date.endOf('week'), throwsA(isA<ArgumentError>()));
    });

    test('should throw error for non-numeric amount in add()', () {
      final date = Kenat.fromString('2017/1/1');
      expect(
        () => (date as dynamic).add('seven', 'days'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
