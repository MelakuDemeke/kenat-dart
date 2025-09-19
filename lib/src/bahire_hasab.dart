/// Bahire Hasab calculations for Ethiopian calendar
/// Handles movable feasts and calendar calculations

import 'utils.dart';
import 'day_arithmetic.dart';
import 'conversions.dart';
import 'errors/error_handler.dart';
import 'constants.dart';

/// Unknown holiday error for Bahire Hasab
class UnknownHolidayError extends KenatError {
  final String holidayKey;

  UnknownHolidayError(this.holidayKey)
    : super('Unknown holiday key: $holidayKey');
}

/// Bahire Hasab calculation class
class BahireHasab {
  /// Calculates all Bahire Hasab values for a given Ethiopian year, including all movable feasts.
  ///
  /// [ethiopianYear] - The Ethiopian year to calculate for.
  /// [options] - Options for language. Defaults to {'lang': 'amharic'}.
  ///
  /// Returns a map containing all the calculated Bahire Hasab values.
  static Map<String, dynamic> getBahireHasab(
    int ethiopianYear, [
    Map<String, dynamic>? options,
  ]) {
    validateNumericInputs('getBahireHasab', {'ethiopianYear': ethiopianYear});
    options ??= {};
    final lang = options['lang'] ?? 'amharic';

    final base = _calculateBahireHasabBase(ethiopianYear);

    final evangelistRemainder = base['ameteAlem']! % 4;
    final evangelistName = lang == 'english'
        ? (EvangelistNames.english[evangelistRemainder] ?? 'Unknown')
        : (EvangelistNames.amharic[evangelistRemainder] ?? 'Unknown');

    final tinteQemer = (base['ameteAlem']! + base['meteneRabiet']!) % 7;
    final weekdayIndex = (tinteQemer + 1) % 7;
    final newYearWeekday = lang == 'english'
        ? DaysOfWeek.english[weekdayIndex]
        : DaysOfWeek.amharic[weekdayIndex];

    final movableFeasts = <String, Map<String, dynamic>>{};

    // Create tewsak to key mapping
    final tewsakToKeyMap = <String, String>{};
    for (final entry in _keyToTewsakMap.entries) {
      tewsakToKeyMap[entry.value] = entry.key;
    }

    for (final tewsakKey in _movableHolidayTewsak.keys) {
      final holidayKey = tewsakToKeyMap[tewsakKey];
      if (holidayKey != null) {
        final ninevehDate = base['ninevehDate'] as Map<String, int>;
        final date = addDays(ninevehDate, _movableHolidayTewsak[tewsakKey]!);

        // Get holiday info from constants
        final holidayInfo = _getHolidayInfo(holidayKey);
        final rules = MovableHolidays.tags[holidayKey];

        movableFeasts[holidayKey] = {
          'key': holidayKey,
          'tags': rules ?? [],
          'movable': true,
          'name':
              holidayInfo['name']?[lang] ??
              holidayInfo['name']?['english'] ??
              holidayKey,
          'description':
              holidayInfo['description']?[lang] ??
              holidayInfo['description']?['english'] ??
              '',
          'ethiopian': date,
          'gregorian': toGC(date['year']!, date['month']!, date['day']!),
        };
      }
    }

    return {
      'ameteAlem': base['ameteAlem'],
      'meteneRabiet': base['meteneRabiet'],
      'evangelist': {'name': evangelistName, 'remainder': evangelistRemainder},
      'newYear': {'dayName': newYearWeekday, 'tinteQemer': tinteQemer},
      'medeb': base['medeb'],
      'wenber': base['wenber'],
      'abektie': base['abektie'],
      'metqi': base['metqi'],
      'bealeMetqi': {
        'date': base['bealeMetqiDate'],
        'weekday': base['bealeMetqiWeekday'],
      },
      'mebajaHamer': base['mebajaHamer'],
      'nineveh': base['ninevehDate'],
      'movableFeasts': movableFeasts,
    };
  }

  /// Calculates the date of a movable holiday for a given year.
  /// This is now a pure date calculator that returns a simple date object,
  /// ensuring backward compatibility with existing tests.
  ///
  /// [holidayKey] - The key of the holiday from movableHolidayTewsak.
  /// [ethiopianYear] - The Ethiopian year.
  ///
  /// Returns an Ethiopian date object with year, month, day keys.
  static Map<String, int> getMovableHoliday(
    dynamic holidayKey,
    dynamic ethiopianYear,
  ) {
    // Validate inside the function to mirror JS behavior
    validateNumericInputs('getMovableHoliday', {
      'ethiopianYear': ethiopianYear,
    });

    final intYear = ethiopianYear as int;

    // Resolve tewsakKey: accept either the small-case holiday key (e.g. 'fasika')
    // or the tewsak key used in _movableHolidayTewsak (e.g. 'TINSAYE').
    final keyStr = holidayKey is String ? holidayKey : holidayKey.toString();
    String? tewsakKey;
    if (_keyToTewsakMap.containsKey(keyStr)) {
      tewsakKey = _keyToTewsakMap[keyStr];
    } else if (_movableHolidayTewsak.containsKey(keyStr)) {
      tewsakKey = keyStr;
    } else {
      // Try to find a mapping where the value equals the provided key (case-sensitive)
      try {
        final entry = _keyToTewsakMap.entries.firstWhere(
          (e) => e.value == keyStr,
        );
        tewsakKey = entry.value;
      } catch (e) {
        throw UnknownHolidayError(keyStr);
      }
    }

    final tewsak = _movableHolidayTewsak[tewsakKey];
    if (tewsak == null) {
      throw UnknownHolidayError(keyStr);
    }

    final base = _calculateBahireHasabBase(intYear);
    final ninevehDate = base['ninevehDate'] as Map<String, int>;

    return addDays(ninevehDate, tewsak);
  }

  /// Calculates and returns all base values for the Bahire Hasab system for a given Ethiopian year.
  /// This helper is the single source of truth for the core computational logic.
  ///
  /// [ethiopianYear] - The Ethiopian year for which to perform the calculations.
  ///
  /// Returns a map containing all core calculated values.
  static Map<String, dynamic> _calculateBahireHasabBase(int ethiopianYear) {
    final ameteAlem = 5500 + ethiopianYear;
    final meteneRabiet = (ameteAlem / 4).floor();
    final medeb = ameteAlem % 19;
    final wenber = medeb == 0 ? 18 : medeb - 1;
    final abektie = (wenber * 11) % 30;
    final metqi = (wenber * 19) % 30;

    final bealeMetqiMonth = metqi > 14 ? 1 : 2;
    final bealeMetqiDay = metqi;
    final bealeMetqiDate = {
      'year': ethiopianYear,
      'month': bealeMetqiMonth,
      'day': bealeMetqiDay,
    };

    final weekday = getWeekday(ethiopianYear, bealeMetqiMonth, bealeMetqiDay);
    final bealeMetqiWeekday = DaysOfWeek.english[weekday];
    final tewsak = TewsakMap.english[bealeMetqiWeekday]!;
    final mebajaHamerSum = bealeMetqiDay + tewsak;
    final mebajaHamer = mebajaHamerSum > 30
        ? mebajaHamerSum % 30
        : mebajaHamerSum;

    int ninevehMonth = metqi > 14 ? 5 : 6;
    if (mebajaHamerSum > 30) ninevehMonth++;
    final ninevehDate = {
      'year': ethiopianYear,
      'month': ninevehMonth,
      'day': mebajaHamer,
    };

    return {
      'ameteAlem': ameteAlem,
      'meteneRabiet': meteneRabiet,
      'medeb': medeb,
      'wenber': wenber,
      'abektie': abektie,
      'metqi': metqi,
      'bealeMetqiDate': bealeMetqiDate,
      'bealeMetqiWeekday': bealeMetqiWeekday,
      'mebajaHamer': mebajaHamer,
      'ninevehDate': ninevehDate,
    };
  }

  /// Helper function to get holiday info from constants
  static Map<String, dynamic> _getHolidayInfo(String holidayKey) {
    final holidayInfo = Holidays.getHolidayInfo(holidayKey);
    if (holidayInfo != null) {
      return holidayInfo;
    }

    // Fallback for unknown holidays
    return {
      'name': {'amharic': holidayKey, 'english': holidayKey},
      'description': {'amharic': '', 'english': ''},
    };
  }
}

/// Key to tewsak mapping
const Map<String, String> _keyToTewsakMap = {
  'nineveh': 'NINEVEH',
  'abiyTsome': 'ABIY_TSOME',
  'debreZeit': 'DEBRE_ZEIT',
  'hosanna': 'HOSANNA',
  'siklet': 'SIKLET',
  'fasika': 'TINSAYE',
  'rikbeKahnat': 'RIKBE_KAHNAT',
  'erget': 'ERGET',
  'paraclete': 'PARACLETE',
  'tsomeHawaryat': 'TSOME_HAWARYAT',
  'tsomeDihnet': 'TSOME_DIHENET',
};

/// Movable holiday tewsak values
const Map<String, int> _movableHolidayTewsak = {
  'NINEVEH': MovableHolidayTewsak.nineveh,
  'ABIY_TSOME': MovableHolidayTewsak.abiyTsome,
  'DEBRE_ZEIT': MovableHolidayTewsak.debreZeit,
  'HOSANNA': MovableHolidayTewsak.hosanna,
  'SIKLET': MovableHolidayTewsak.siklet,
  'TINSAYE': MovableHolidayTewsak.tinsaye,
  'RIKBE_KAHNAT': MovableHolidayTewsak.rikbeKahnat,
  'ERGET': MovableHolidayTewsak.erget,
  'PARACLETE': MovableHolidayTewsak.paraclete,
  'TSOME_HAWARYAT': MovableHolidayTewsak.tsomeHawaryat,
  'TSOME_DIHENET': MovableHolidayTewsak.tsomeDihenet,
};

/// Convenience functions that match the original JavaScript API
/// These provide static access to the Bahire Hasab functions

/// Calculates all Bahire Hasab values for a given Ethiopian year.
Map<String, dynamic> getBahireHasab(
  int ethiopianYear, [
  Map<String, dynamic>? options,
]) {
  return BahireHasab.getBahireHasab(ethiopianYear, options);
}

/// Calculates the date of a movable holiday for a given year.
Map<String, int> getMovableHoliday(dynamic holidayKey, dynamic ethiopianYear) {
  return BahireHasab.getMovableHoliday(holidayKey, ethiopianYear);
}
