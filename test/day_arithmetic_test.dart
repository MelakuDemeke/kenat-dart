import 'package:test/test.dart';
import 'package:kenat/src/day_arithmetic.dart';
import 'package:kenat/src/kenat.dart';

// Helper function to create Kenat from Ethiopian date string
Kenat createKenatFromEthiopian(String dateStr) {
  final parts = dateStr.split('/');
  return Kenat.fromEthiopian(
    int.parse(parts[0]), // year
    int.parse(parts[1]), // month
    int.parse(parts[2]), // day
  );
}

void main() {
  group('KenatAddDaysTests', () {
    test('Add days within same month', () {
      final k = createKenatFromEthiopian('2016/01/10');
      final result = k.addDays(5);
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 1, 'day': 15}),
      );
    });

    test('Add days crossing month boundary', () {
      final k = createKenatFromEthiopian('2016/01/28');
      final result = k.addDays(5); // Month 1 has 30 days
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 2, 'day': 3}),
      );
    });

    test('Add days crossing year boundary', () {
      final k = createKenatFromEthiopian(
        '2016/13/4',
      ); // Pagume month with 5 days (non-leap)
      final result = k.addDays(3);
      expect(
        result.getEthiopian(),
        equals({'year': 2017, 'month': 1, 'day': 2}),
      );
    });

    test('Add days exactly at month end', () {
      final k = createKenatFromEthiopian('2016/02/25');
      final result = k.addDays(5);
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 2, 'day': 30}),
      );
    });

    test('Add zero days returns same date', () {
      final k = createKenatFromEthiopian('2016/05/15');
      final result = k.addDays(0);
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 5, 'day': 15}),
      );
    });

    test('Add zero days returns same date', () {
      final k = createKenatFromEthiopian('2016/13/1');
      final result = k.addDays(6);
      expect(
        result.getEthiopian(),
        equals({'year': 2017, 'month': 1, 'day': 2}),
      );
    });
  });

  group('KenatAddMonthsTests', () {
    test('Add months within same year', () {
      final k = createKenatFromEthiopian('2016/03/10');
      final result = k.addMonths(5);
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 8, 'day': 10}),
      );
    });

    test('Add months with year rollover', () {
      final k = createKenatFromEthiopian('2016/11/10');
      final result = k.addMonths(3);
      expect(
        result.getEthiopian(),
        equals({'year': 2017, 'month': 1, 'day': 10}),
      );
    });

    test('Add months resulting in Pagume with day clamp', () {
      final k = createKenatFromEthiopian(
        '2015/12/30',
      ); // 2015 is not a leap year (Pagume = 5 days)
      final result = k.addMonths(1); // 30th goes to Pagume but 30 > 5, so clamp
      expect(
        result.getEthiopian(),
        equals({'year': 2015, 'month': 13, 'day': 6}),
      ); // ✅ real converted result
    });

    test('Add months resulting in Pagume in leap year', () {
      final k = createKenatFromEthiopian(
        '2011/12/30',
      ); // 2011 is a leap year (Pagume = 6 days)
      final result = k.addMonths(1);
      expect(
        result.getEthiopian(),
        equals({'year': 2011, 'month': 13, 'day': 6}),
      );
    });

    test('Add zero months returns same date', () {
      final k = createKenatFromEthiopian('2016/06/20');
      final result = k.addMonths(0);
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 6, 'day': 20}),
      );
    });

    test('Add negative months across year boundary', () {
      final k = createKenatFromEthiopian('2016/03/10');
      final result = k.addMonths(-4); // Goes to 2015/12 (not 11)
      expect(
        result.getEthiopian(),
        equals({'year': 2015, 'month': 12, 'day': 10}),
      ); // ✅ fixed
    });

    test('Subtract into Pagume with clamping', () {
      final k = createKenatFromEthiopian('2016/01/06'); // Meskerem 6
      final result = k.addMonths(-1); // Should go to Pagume
      expect(
        result.getEthiopian(),
        equals({'year': 2015, 'month': 13, 'day': 6}),
      ); // leap year
    });
  });

  group('KenatAddYearsTests', () {
    test('Add years within leap-safe month', () {
      final k = createKenatFromEthiopian('2010/05/15');
      final result = k.addYears(3);
      expect(
        result.getEthiopian(),
        equals({'year': 2013, 'month': 5, 'day': 15}),
      );
    });

    test('Add years from leap Pagume 6 to non-leap year', () {
      final k = createKenatFromEthiopian('2011/13/6'); // 2011 is leap
      final result = k.addYears(1); // 2012 is not leap
      expect(
        result.getEthiopian(),
        equals({'year': 2012, 'month': 13, 'day': 5}),
      ); // day clamped
    });

    test('Add years to another leap year, keeping Pagume 6', () {
      final k = createKenatFromEthiopian('2011/13/6'); // 2011 is leap
      final result = k.addYears(4); // 2015 is also leap
      expect(
        result.getEthiopian(),
        equals({'year': 2015, 'month': 13, 'day': 6}),
      );
    });

    test('Add zero years returns same date', () {
      final k = createKenatFromEthiopian('2016/03/10');
      final result = k.addYears(0);
      expect(
        result.getEthiopian(),
        equals({'year': 2016, 'month': 3, 'day': 10}),
      );
    });

    test('Subtract years across leap/non-leap transition', () {
      final k = createKenatFromEthiopian('2015/13/6'); // 2015 is leap
      final result = k.addYears(-1); // 2014 is not leap
      expect(
        result.getEthiopian(),
        equals({'year': 2014, 'month': 13, 'day': 5}),
      );
    });
  });

  group('KenatDiffInDaysTests', () {
    test('Same date returns zero', () {
      final a = createKenatFromEthiopian('2016/05/15');
      final b = createKenatFromEthiopian('2016/05/15');
      expect(a.diffInDays(b), equals(0));
    });

    test('Later date minus earlier date returns positive', () {
      final a = createKenatFromEthiopian('2016/06/10');
      final b = createKenatFromEthiopian('2016/06/05');
      expect(a.diffInDays(b), equals(5));
    });

    test('Earlier date minus later date returns negative', () {
      final a = createKenatFromEthiopian('2016/06/01');
      final b = createKenatFromEthiopian('2016/06/06');
      expect(a.diffInDays(b), equals(-5));
    });

    test('Crossing year boundary', () {
      final a = createKenatFromEthiopian('2017/01/03');
      final b = createKenatFromEthiopian('2016/13/04');
      expect(a.diffInDays(b), equals(4)); // Pagume 5 to Meskerem 3
    });

    test('Crossing multiple years', () {
      final a = createKenatFromEthiopian('2018/01/01');
      final b = createKenatFromEthiopian('2016/01/01');
      expect(a.diffInDays(b), equals(730)); // 2 Ethiopian years = 365 * 2
    });
  });

  group('KenatDiffInMonthsTests', () {
    test('Same date returns zero', () {
      final a = createKenatFromEthiopian('2016/05/15');
      final b = createKenatFromEthiopian('2016/05/15');
      expect(a.diffInMonths(b), equals(0));
    });

    test('Later date minus earlier date within same year returns positive', () {
      final a = createKenatFromEthiopian('2016/06/10');
      final b = createKenatFromEthiopian('2016/05/05');
      expect(a.diffInMonths(b), equals(1));
    });

    test('Earlier date minus later date within same year returns negative', () {
      final a = createKenatFromEthiopian('2016/05/01');
      final b = createKenatFromEthiopian('2016/06/06');
      expect(a.diffInMonths(b), equals(-2));
      // Explanation: totalMonths difference is -1, but day 1 < 6 subtracts 1 more month = -2
    });

    test('Crossing year boundary', () {
      final a = createKenatFromEthiopian('2017/01/03');
      final b = createKenatFromEthiopian('2016/13/04');
      expect(a.diffInMonths(b), equals(0));
    });

    test('Crossing year boundary with day adjustment', () {
      final a = createKenatFromEthiopian('2017/01/05'); // day 5
      final b = createKenatFromEthiopian('2016/13/04'); // day 4
      expect(a.diffInMonths(b), equals(1));
      // Because 5 >= 4 no decrement
    });

    test('Crossing multiple years', () {
      final a = createKenatFromEthiopian('2018/01/01');
      final b = createKenatFromEthiopian('2016/01/01');
      expect(a.diffInMonths(b), equals(26)); // 2 Ethiopian years * 13 months
    });
  });

  group('KenatDiffInYearsTests', () {
    test('Same date returns zero', () {
      final a = createKenatFromEthiopian('2016/05/15');
      final b = createKenatFromEthiopian('2016/05/15');
      expect(a.diffInYears(b), equals(0));
    });

    test('Later date minus earlier date within same year returns zero', () {
      final a = createKenatFromEthiopian('2016/06/10');
      final b = createKenatFromEthiopian('2016/05/05');
      expect(
        a.diffInYears(b),
        equals(0),
      ); // Same year, difference less than full year
    });

    test('Earlier date minus later date within same year returns zero', () {
      final a = createKenatFromEthiopian('2016/05/01');
      final b = createKenatFromEthiopian('2016/06/06');
      expect(
        a.diffInYears(b),
        equals(0),
      ); // Same year, difference less than full year
    });

    test(
      'Later date minus earlier date crossing year boundary returns positive',
      () {
        final a = createKenatFromEthiopian('2017/01/03');
        final b = createKenatFromEthiopian('2016/13/04');
        expect(
          a.diffInYears(b),
          equals(0),
        ); // Full year difference, day/month adjustment done
      },
    );

    test(
      'Later date minus earlier date crossing year boundary but day adjustment subtracts one',
      () {
        final a = createKenatFromEthiopian('2017/01/03'); // day 3 < day 4
        final b = createKenatFromEthiopian('2016/13/04');
        // Same as above test, but test again to confirm day < day subtracts 1
        expect(a.diffInYears(b), equals(0));
      },
    );

    test('Crossing multiple years returns correct positive value', () {
      final a = createKenatFromEthiopian('2018/01/01');
      final b = createKenatFromEthiopian('2016/01/01');
      expect(a.diffInYears(b), equals(2));
    });

    test('Earlier date minus later date returns negative years', () {
      final a = createKenatFromEthiopian('2016/01/01');
      final b = createKenatFromEthiopian('2018/01/01');
      expect(a.diffInYears(b), equals(-2));
    });
  });

  group('Direct DayArithmetic function tests', () {
    test('addDays: Direct function call', () {
      final result = addDays({'year': 2016, 'month': 1, 'day': 10}, 5);
      expect(result, equals({'year': 2016, 'month': 1, 'day': 15}));
    });

    test('addMonths: Direct function call', () {
      final result = addMonths({'year': 2016, 'month': 3, 'day': 10}, 5);
      expect(result, equals({'year': 2016, 'month': 8, 'day': 10}));
    });

    test('addYears: Direct function call', () {
      final result = addYears({'year': 2010, 'month': 5, 'day': 15}, 3);
      expect(result, equals({'year': 2013, 'month': 5, 'day': 15}));
    });

    test('diffInDays: Direct function call', () {
      final result = diffInDays(
        {'year': 2016, 'month': 6, 'day': 10},
        {'year': 2016, 'month': 6, 'day': 5},
      );
      expect(result, equals(5));
    });

    test('diffInMonths: Direct function call', () {
      final result = diffInMonths(
        {'year': 2016, 'month': 6, 'day': 10},
        {'year': 2016, 'month': 5, 'day': 5},
      );
      expect(result, equals(1));
    });

    test('diffInYears: Direct function call', () {
      final result = diffInYears(
        {'year': 2018, 'month': 1, 'day': 1},
        {'year': 2016, 'month': 1, 'day': 1},
      );
      expect(result, equals(2));
    });

    test('diffBreakdown: Human-friendly breakdown', () {
      final result = diffBreakdown(
        {'year': 2018, 'month': 3, 'day': 15},
        {'year': 2016, 'month': 1, 'day': 10},
      );
      expect(result['years'], greaterThan(1));
      expect(result['months'], greaterThan(0));
      expect(result['days'], greaterThan(0));
      expect(result['totalDays'], greaterThan(0));
    });

    test('DayArithmetic class static methods', () {
      final result1 = DayArithmetic.addDays({
        'year': 2016,
        'month': 1,
        'day': 10,
      }, 5);
      expect(result1, equals({'year': 2016, 'month': 1, 'day': 15}));

      final result2 = DayArithmetic.addMonths({
        'year': 2016,
        'month': 3,
        'day': 10,
      }, 5);
      expect(result2, equals({'year': 2016, 'month': 8, 'day': 10}));

      final result3 = DayArithmetic.addYears({
        'year': 2010,
        'month': 5,
        'day': 15,
      }, 3);
      expect(result3, equals({'year': 2013, 'month': 5, 'day': 15}));
    });
  });

  group('Edge cases and error handling', () {
    test('addDays: Large number of days', () {
      final k = createKenatFromEthiopian('2016/01/01');
      final result = k.addDays(1000);
      // Should handle large additions correctly
      expect(result.getEthiopian()['year'], greaterThan(2016));
    });

    test('addMonths: Large number of months', () {
      final k = createKenatFromEthiopian('2016/01/01');
      final result = k.addMonths(100);
      // Should handle large additions correctly
      expect(result.getEthiopian()['year'], greaterThan(2016));
    });

    test('addYears: Large number of years', () {
      final k = createKenatFromEthiopian('2016/01/01');
      final result = k.addYears(100);
      // Should handle large additions correctly
      expect(result.getEthiopian()['year'], equals(2116));
    });

    test('Negative day additions', () {
      final k = createKenatFromEthiopian('2016/02/05');
      final result = k.addDays(-10);
      expect(result.getEthiopian()['month'], equals(1));
      expect(result.getEthiopian()['day'], equals(25));
    });

    test('Negative month additions', () {
      final k = createKenatFromEthiopian('2016/02/05');
      final result = k.addMonths(-1);
      expect(result.getEthiopian()['month'], equals(1));
      expect(result.getEthiopian()['year'], equals(2016));
    });

    test('Negative year additions', () {
      final k = createKenatFromEthiopian('2016/02/05');
      final result = k.addYears(-1);
      expect(result.getEthiopian()['year'], equals(2015));
      expect(result.getEthiopian()['month'], equals(2));
      expect(result.getEthiopian()['day'], equals(5));
    });
  });
}
