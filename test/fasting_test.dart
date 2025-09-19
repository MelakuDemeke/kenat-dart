import 'package:test/test.dart';
import 'package:kenat/kenat.dart';

void main() {
  group('getFastingPeriod', () {
    group('Christian Fasts for 2016 E.C.', () {
      const year = 2016;

      test('The Great Lent (Abiy Tsome) start and end', () {
        final period = getFastingPeriod(FastingKeys.abiyTsome, year);
        expect(period, isNotNull);
        expect(period!['start'], equals({'year': 2016, 'month': 7, 'day': 2}));
        expect(period['end'], equals({'year': 2016, 'month': 8, 'day': 25}));
      });

      test('Fast of the Apostles (Tsome Hawaryat) end', () {
        final period = getFastingPeriod(FastingKeys.tsomeHawaryat, year);
        expect(period, isNotNull);
        expect(period!['end'], equals({'year': 2016, 'month': 11, 'day': 4}));
      });

      test('Fast of Nineveh 3-day period', () {
        final period = getFastingPeriod(FastingKeys.nineveh, year);
        expect(period, isNotNull);
        expect(period!['start'], equals({'year': 2016, 'month': 6, 'day': 18}));
        expect(period['end'], equals({'year': 2016, 'month': 6, 'day': 20}));
      });

      test('Fast of the Prophets (Tsome Nebiyat) fixed period', () {
        final period = getFastingPeriod(FastingKeys.tsomeNebiyat, year);
        expect(period, isNotNull);
        expect(period!['start'], equals({'year': 2016, 'month': 3, 'day': 15}));
        expect(period['end'], equals({'year': 2016, 'month': 4, 'day': 28}));
      });
    });

    group('Muslim Fasts for 2016 E.C.', () {
      const year = 2016;

      test('Ramadan start', () {
        final period = getFastingPeriod(FastingKeys.ramadan, year);
        expect(period, isNotNull);
        expect(period!['start'], equals({'year': 2016, 'month': 7, 'day': 2}));
      });
    });

    group('Error and Edge Case Handling', () {
      test('unknown fast key returns null', () {
        final period = getFastingPeriod('UNKNOWN_FAST_KEY', 2016);
        expect(period, isNull);
      });

      test('valid period for future year', () {
        final period = getFastingPeriod(FastingKeys.abiyTsome, 2020);
        expect(period, isNotNull);
        expect(period!['start'], isNotNull);
        expect(period['end'], isNotNull);
      });
    });
  });

  group('getFastingInfo', () {
    const year = 2016;

    test('multilingual info and period for Abiy Tsome', () {
      final infoAm = getFastingInfo(FastingKeys.abiyTsome, year, {
        'lang': 'amharic',
      });
      expect(infoAm, isNotNull);
      expect(infoAm!['key'], equals(FastingKeys.abiyTsome));
      expect(infoAm['name'], equals('ዐቢይ ጾም (ሁዳዴ)'));
      expect(infoAm['description'], isNotNull);
      expect(
        infoAm['period']['start'],
        equals({'year': 2016, 'month': 7, 'day': 2}),
      );

      final infoEn = getFastingInfo(FastingKeys.abiyTsome, year, {
        'lang': 'english',
      });
      expect(infoEn, isNotNull);
      expect((infoEn!['name'] as String).toLowerCase(), contains('great lent'));
      expect(
        infoEn['period']['end'],
        equals({'year': 2016, 'month': 8, 'day': 25}),
      );
    });

    test('info for Nineveh with 3-day period', () {
      final info = getFastingInfo(FastingKeys.nineveh, year);
      expect(info, isNotNull);
      expect(info!['name'], equals('ጾመ ነነዌ'));
      expect(
        info['period']['start'],
        equals({'year': 2016, 'month': 6, 'day': 18}),
      );
      expect(
        info['period']['end'],
        equals({'year': 2016, 'month': 6, 'day': 20}),
      );
    });

    test('info for Ramadan includes tags', () {
      final info = getFastingInfo(FastingKeys.ramadan, year, {
        'lang': 'english',
      });
      expect(info, isNotNull);
      expect(info!['name'], equals('Ramadan'));
      expect(info['tags'], isA<List>());
      expect(
        info['period']['start'],
        equals({'year': 2016, 'month': 7, 'day': 2}),
      );
    });

    test('info for Filseta fixed Nehase 1-14', () {
      final info = getFastingInfo(FastingKeys.filseta, year, {
        'lang': 'amharic',
      });
      expect(info, isNotNull);
      expect(info!['key'], equals(FastingKeys.filseta));
      expect(info['name'], equals('ፍልሰታ'));
      expect(
        info['period']['start'],
        equals({'year': 2016, 'month': 12, 'day': 1}),
      );
      expect(
        info['period']['end'],
        equals({'year': 2016, 'month': 12, 'day': 14}),
      );
    });
  });

  group('Orthodox Weekly Fasting (Tsome Dihnet)', () {
    test(
      'Wednesdays and Fridays fasting days outside 50 days after Easter',
      () {
        final year = 2016;
        final month = 3; // Hidar
        final daysInMonth = getEthiopianDaysInMonth(year, month);
        var foundWed = false;
        var foundFri = false;
        final days = getFastingDays(FastingKeys.tsomeDihenet, year, month);
        for (var day = 1; day <= daysInMonth; day++) {
          final wd = getWeekday(year, month, day);
          if (wd == 3) {
            foundWed = true;
            expect(days.contains(day), isTrue);
          }
          if (wd == 5) {
            foundFri = true;
            expect(days.contains(day), isTrue);
          }
        }
        expect(foundWed || foundFri, isTrue);
      },
    );

    test(
      'No fasting on Wed/Fri during 50 days after Easter through Pentecost',
      () {
        final year = 2016;
        final bh = getBahireHasab(year);
        final easter = bh['movableFeasts']['fasika']['ethiopian'];
        final pentecost = bh['movableFeasts']['paraclete']['ethiopian'];

        var d = addDays(easter, 1);
        while (true) {
          final wd = getWeekday(d['year']!, d['month']!, d['day']!);
          if (wd == 3 || wd == 5) {
            final list = getFastingDays(
              FastingKeys.tsomeDihenet,
              d['year']!,
              d['month']!,
            );
            expect(list.contains(d['day']!), isFalse);
          }
          if (d['year'] == pentecost['year'] &&
              d['month'] == pentecost['month'] &&
              d['day'] == pentecost['day'])
            break;
          d = addDays(d, 1);
        }
      },
    );

    test('Fasting resumes on Wed/Fri after Pentecost in same year', () {
      final year = 2016;
      final bh = getBahireHasab(year);
      final pentecost = bh['movableFeasts']['paraclete']['ethiopian'];
      var found = false;
      for (var i = 1; i <= 21; i++) {
        final d = addDays(pentecost, i);
        final wd = getWeekday(d['year']!, d['month']!, d['day']!);
        if (wd == 3 || wd == 5) {
          final list = getFastingDays(
            FastingKeys.tsomeDihenet,
            d['year']!,
            d['month']!,
          );
          expect(list.contains(d['day']!), isTrue);
          found = true;
          break;
        }
      }
      expect(found, isTrue);
    });
  });
}
