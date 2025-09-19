/// Fasting period calculations
/// Handles canonical fasting periods and weekly fasting days

import 'bahire_hasab.dart';
import 'holidays.dart';
import 'day_arithmetic.dart';
import 'constants.dart';
import 'utils.dart';

/// Fasting calculation class
class FastingCalculator {
  /// Calculates the start and end dates of a specific fasting period for a given year.
  ///
  /// [fastKey] - The key for the fast (one of FastingKeys values).
  /// [ethiopianYear] - The Ethiopian year.
  ///
  /// Returns an object with start and end PLAIN date objects, or null if not found.
  static Map<String, Map<String, int>>? getFastingPeriod(
    String fastKey,
    int ethiopianYear,
  ) {
    final bh = BahireHasab.getBahireHasab(ethiopianYear);

    switch (fastKey) {
      case FastingKeys.abiyTsome:
        final start = bh['movableFeasts']['abiyTsome']?['ethiopian'];
        final end = bh['movableFeasts']['siklet']?['ethiopian'];
        if (start != null && end != null) {
          return {
            'start': Map<String, int>.from(start),
            'end': Map<String, int>.from(end),
          };
        }
        return null;

      case FastingKeys.tsomeHawaryat:
        final start = bh['movableFeasts']['tsomeHawaryat']?['ethiopian'];
        final end = {'year': ethiopianYear, 'month': 11, 'day': 4};
        if (start != null) {
          return {'start': Map<String, int>.from(start), 'end': end};
        }
        return null;

      case FastingKeys.nineveh:
        final start = bh['movableFeasts']['nineveh']?['ethiopian'];
        if (start != null) {
          final end = DayArithmetic.addDays(start, 2);
          return {'start': Map<String, int>.from(start), 'end': end};
        }
        return null;

      case FastingKeys.tsomeNebiyat:
        final start = {'year': ethiopianYear, 'month': 3, 'day': 15};
        final end = {'year': ethiopianYear, 'month': 4, 'day': 28};
        return {'start': start, 'end': end};

      case FastingKeys.filseta:
        // Nehase 1 to Nehase 14
        final start = {'year': ethiopianYear, 'month': 12, 'day': 1};
        final end = {'year': ethiopianYear, 'month': 12, 'day': 14};
        return {'start': start, 'end': end};

      case FastingKeys.ramadan:
        final ranges = HolidayCalculator.findHijriMonthRanges(ethiopianYear, 9);
        if (ranges.isNotEmpty) {
          final range = ranges.first;
          return {
            'start': Map<String, int>.from(range['start']),
            'end': Map<String, int>.from(range['end']),
          };
        }
        return null;

      default:
        return null;
    }
  }

  /// Returns fasting information (names, descriptions, period) for a given fast and year.
  ///
  /// [fastKey] - One of FastingKeys values.
  /// [ethiopianYear] - The Ethiopian year.
  /// [options] - Options with optional language parameter.
  ///
  /// Returns fasting info with key, name, description, tags, and period, or null if not found.
  static Map<String, dynamic>? getFastingInfo(
    String fastKey,
    int ethiopianYear, [
    Map<String, dynamic>? options,
  ]) {
    validateNumericInputs('getFastingInfo', {'ethiopianYear': ethiopianYear});
    options ??= {};
    final lang = options['lang'] ?? 'amharic';

    final info = Fasting.getFastingInfo(fastKey);
    if (info == null) return null;

    final name = info['name']?[lang] ?? info['name']?['english'];
    final description =
        info['description']?[lang] ?? info['description']?['english'];

    // TSOME_DIHENET is a weekly fast (Wed/Fri) with an exception; it doesn't have a single contiguous period.
    if (fastKey == FastingKeys.tsomeDihenet) {
      return {
        'key': fastKey,
        'name': name,
        'description': description,
        'tags': info['tags'],
        'period': null,
      };
    }

    final period = getFastingPeriod(fastKey, ethiopianYear);
    if (period == null) return null;

    return {
      'key': fastKey,
      'name': name,
      'description': description,
      'tags': info['tags'],
      'period': period,
    };
  }

  /// Checks if a given Ethiopian date is an Orthodox weekly fasting day (Tsome Dihnet).
  /// Rules:
  /// - Fasting occurs every Wednesday and Friday.
  /// - Exception: for the 50 days after Easter (Fasika) up to and including Pentecost (Paraclete),
  ///   Wednesdays and Fridays are NOT considered fasting days.
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  ///
  /// Returns true if it's a fasting day, false otherwise.
  static bool isTsomeDihnetFastDay(Map<String, dynamic> etDate) {
    validateEthiopianDateObject(etDate, 'isTsomeDihnetFastDay', 'etDate');

    final weekday = getWeekday(
      etDate['year']!,
      etDate['month']!,
      etDate['day']!,
    );
    final isWedOrFri = (weekday == 3 || weekday == 5);
    if (!isWedOrFri) return false;

    // Get Easter (Fasika) for the year and apply 50-day exception window
    final bh = BahireHasab.getBahireHasab(etDate['year']);
    final fasika = bh['movableFeasts']?['fasika']?['ethiopian'];
    final paraclete = bh['movableFeasts']?['paraclete']?['ethiopian'];
    if (fasika == null || paraclete == null) {
      // If for some reason we cannot compute the window, default to standard Wed/Fri fasting.
      return true;
    }

    final daysFromEaster = DayArithmetic.diffInDays(etDate, fasika);
    final inPentecostSeason =
        daysFromEaster >= 1 && DayArithmetic.diffInDays(etDate, paraclete) <= 0;
    return !inPentecostSeason;
  }

  /// Returns an array of day numbers in the given Ethiopian month that belong to a fasting period.
  /// For TSOME_DIHENET, it returns all Wednesdays and Fridays excluding the 50-day period after Easter (through Pentecost).
  /// For fixed/range fasts, it returns the days intersecting the fast period.
  ///
  /// [fastKey] - One of FastingKeys values.
  /// [year] - Ethiopian year.
  /// [month] - Ethiopian month (1-13).
  ///
  /// Returns list of day numbers that are fasting days.
  static List<int> getFastingDays(String fastKey, int year, int month) {
    validateNumericInputs('getFastingDays', {'year': year, 'month': month});
    final daysInMonth = EthiopianCalendarUtils.getEthiopianDaysInMonth(
      year,
      month,
    );

    if (fastKey == FastingKeys.tsomeDihenet) {
      final out = <int>[];
      for (int d = 1; d <= daysInMonth; d++) {
        if (isTsomeDihnetFastDay({'year': year, 'month': month, 'day': d})) {
          out.add(d);
        }
      }
      return out;
    }

    // For other fasts: compute period and intersect with the month
    final period = getFastingPeriod(fastKey, year);
    if (period == null) return [];

    final startYearMonth = {
      'y': period['start']!['year']!,
      'm': period['start']!['month']!,
    };
    final endYearMonth = {
      'y': period['end']!['year']!,
      'm': period['end']!['month']!,
    };

    // If the month is completely outside, return []
    final before =
        (year < startYearMonth['y']!) ||
        (year == startYearMonth['y'] && month < startYearMonth['m']!);
    final after =
        (year > endYearMonth['y']!) ||
        (year == endYearMonth['y'] && month > endYearMonth['m']!);
    if (before || after) return [];

    final startDay =
        (year == period['start']!['year'] && month == period['start']!['month'])
        ? period['start']!['day']!
        : 1;
    final endDay =
        (year == period['end']!['year'] && month == period['end']!['month'])
        ? period['end']!['day']!
        : daysInMonth;

    final result = <int>[];
    for (int d = startDay; d <= endDay; d++) {
      result.add(d);
    }
    return result;
  }
}

/// Convenience functions that match the original JavaScript API

/// Calculates the start and end dates of a specific fasting period for a given year.
Map<String, Map<String, int>>? getFastingPeriod(
  String fastKey,
  int ethiopianYear,
) {
  return FastingCalculator.getFastingPeriod(fastKey, ethiopianYear);
}

/// Returns fasting information for a given fast and year.
Map<String, dynamic>? getFastingInfo(
  String fastKey,
  int ethiopianYear, [
  Map<String, dynamic>? options,
]) {
  return FastingCalculator.getFastingInfo(fastKey, ethiopianYear, options);
}

/// Checks if a given Ethiopian date is a weekly fasting day.
bool isTsomeDihnetFastDay(Map<String, dynamic> etDate) {
  return FastingCalculator.isTsomeDihnetFastDay(etDate);
}

/// Returns fasting days in a specific month.
List<int> getFastingDays(String fastKey, int year, int month) {
  return FastingCalculator.getFastingDays(fastKey, year, month);
}
