/// Date arithmetic functions for Ethiopian calendar
/// Handles adding/subtracting days, months, years and calculating differences
library;

import 'utils.dart';

/// Date arithmetic operations for Ethiopian calendar
class DayArithmetic {
  /// Adds a specified number of days to an Ethiopian date.
  ///
  /// [ethiopian] - The Ethiopian date object with year, month, day keys.
  /// [days] - The number of days to add.
  ///
  /// Returns the resulting Ethiopian date.
  /// Throws [InvalidInputTypeError] If inputs are not of the correct type.
  static Map<String, int> addDays(Map<String, dynamic> ethiopian, int days) {
    validateEthiopianDateObject(ethiopian, 'addDays', 'ethiopian');
    validateNumericInputs('addDays', {'days': days});

    int year = ethiopian['year']!;
    int month = ethiopian['month']!;
    int day = ethiopian['day']!;

    day += days;

    // Handle positive days (moving forward)
    while (day > getEthiopianDaysInMonth(year, month)) {
      day -= getEthiopianDaysInMonth(year, month);
      month += 1;

      if (month > 13) {
        month = 1;
        year += 1;
      }
    }

    // Handle negative days (moving backward)
    while (day <= 0) {
      month -= 1;
      if (month < 1) {
        month = 13;
        year -= 1;
      }
      day += getEthiopianDaysInMonth(year, month);
    }

    return {'year': year, 'month': month, 'day': day};
  }

  /// Adds a specified number of months to an Ethiopian date.
  ///
  /// [ethiopian] - The Ethiopian date object with year, month, day keys.
  /// [months] - The number of months to add.
  ///
  /// Returns the resulting Ethiopian date.
  /// Throws [InvalidInputTypeError] If inputs are not of the correct type.
  static Map<String, int> addMonths(
    Map<String, dynamic> ethiopian,
    int months,
  ) {
    validateEthiopianDateObject(ethiopian, 'addMonths', 'ethiopian');
    validateNumericInputs('addMonths', {'months': months});

    int year = ethiopian['year']!;
    int month = ethiopian['month']!;
    int day = ethiopian['day']!;

    int totalMonths = month + months;

    year += ((totalMonths - 1) / 13).floor();
    month = (((totalMonths - 1) % 13) + 13) % 13 + 1;

    final daysInTargetMonth = getEthiopianDaysInMonth(year, month);
    if (day > daysInTargetMonth) {
      day = daysInTargetMonth;
    }

    return {'year': year, 'month': month, 'day': day};
  }

  /// Adds a specified number of years to an Ethiopian date.
  ///
  /// [ethiopian] - The Ethiopian date object with year, month, day keys.
  /// [years] - The number of years to add.
  ///
  /// Returns the resulting Ethiopian date.
  /// Throws [InvalidInputTypeError] If inputs are not of the correct type.
  static Map<String, int> addYears(Map<String, dynamic> ethiopian, int years) {
    validateEthiopianDateObject(ethiopian, 'addYears', 'ethiopian');
    validateNumericInputs('addYears', {'years': years});

    int year = ethiopian['year']!;
    int month = ethiopian['month']!;
    int day = ethiopian['day']!;

    year += years;

    if (month == 13 && day == 6 && !isEthiopianLeapYear(year)) {
      day = 5;
    }

    return {'year': year, 'month': month, 'day': day};
  }

  /// Calculates the difference in days between two Ethiopian dates.
  ///
  /// [a] - The first Ethiopian date object.
  /// [b] - The second Ethiopian date object.
  ///
  /// Returns the difference in days.
  /// Throws [InvalidInputTypeError] If inputs are not valid date objects.
  static int diffInDays(Map<String, dynamic> a, Map<String, dynamic> b) {
    validateEthiopianDateObject(a, 'diffInDays', 'a');
    validateEthiopianDateObject(b, 'diffInDays', 'b');

    int totalDays(Map<String, dynamic> eth) {
      int days = 0;
      for (int y = 1; y < eth['year']!; y++) {
        days += isEthiopianLeapYear(y) ? 366 : 365;
      }
      for (int m = 1; m < eth['month']!; m++) {
        days += getEthiopianDaysInMonth(eth['year']!, m);
      }
      days += eth['day']! as int;
      return days;
    }

    return totalDays(a) - totalDays(b);
  }

  /// Calculates the difference in months between two Ethiopian dates.
  ///
  /// [a] - The first Ethiopian date object.
  /// [b] - The second Ethiopian date object.
  ///
  /// Returns the difference in months.
  /// Throws [InvalidInputTypeError] If inputs are not valid date objects.
  static int diffInMonths(Map<String, dynamic> a, Map<String, dynamic> b) {
    validateEthiopianDateObject(a, 'diffInMonths', 'a');
    validateEthiopianDateObject(b, 'diffInMonths', 'b');

    final totalMonthsA = a['year']! * 13 + (a['month']! - 1);
    final totalMonthsB = b['year']! * 13 + (b['month']! - 1);
    int diff = (totalMonthsA - totalMonthsB).toInt();

    if (a['day']! < b['day']!) {
      diff -= 1;
    }

    return diff;
  }

  /// Calculates the difference in years between two Ethiopian dates.
  ///
  /// [a] - The first Ethiopian date object.
  /// [b] - The second Ethiopian date object.
  ///
  /// Returns the difference in years.
  /// Throws [InvalidInputTypeError] If inputs are not valid date objects.
  static int diffInYears(Map<String, dynamic> a, Map<String, dynamic> b) {
    validateEthiopianDateObject(a, 'diffInYears', 'a');
    validateEthiopianDateObject(b, 'diffInYears', 'b');

    final isAfter =
        (a['year']! > b['year']!) ||
        (a['year'] == b['year'] && a['month']! > b['month']!) ||
        (a['year'] == b['year'] &&
            a['month'] == b['month'] &&
            a['day']! >= b['day']!);

    final later = isAfter ? a : b;
    final earlier = isAfter ? b : a;
    int diff = later['year']! - earlier['year']!;

    if (later['month']! < earlier['month']! ||
        (later['month'] == earlier['month'] &&
            later['day']! < earlier['day']!)) {
      diff--;
    }

    final finalDiff = isAfter ? diff : -diff;

    // Coerce -0 to 0 to ensure strict equality passes in tests.
    if (finalDiff == 0) {
      return 0;
    }

    return finalDiff;
  }

  /// Calculates a human-friendly breakdown between two Ethiopian dates.
  /// Iteratively accumulates years, then months, then days to avoid off-by-one issues.
  ///
  /// [a] - First Ethiopian date with year, month, day keys.
  /// [b] - Second Ethiopian date with year, month, day keys.
  /// [options] - Optional configuration.
  /// - [units] - Units to include, in order. Defaults to ['years', 'months', 'days'].
  ///
  /// Returns a map with sign, years, months, days, and totalDays.
  static Map<String, dynamic> diffBreakdown(
    Map<String, dynamic> a,
    Map<String, dynamic> b, [
    Map<String, dynamic>? options,
  ]) {
    validateEthiopianDateObject(a, 'diffBreakdown', 'a');
    validateEthiopianDateObject(b, 'diffBreakdown', 'b');

    options ??= {};
    final units = options['units'] ?? ['years', 'months', 'days'];
    final totalDaysDiff = diffInDays(a, b); // positive if a after b

    final sign = totalDaysDiff == 0 ? 1 : (totalDaysDiff > 0 ? 1 : -1);
    final later = sign >= 0 ? a : b;
    final earlier = sign >= 0 ? b : a;

    Map<String, dynamic> cursor = Map<String, dynamic>.from(earlier);
    final result = <String, dynamic>{
      'sign': sign,
      'totalDays': totalDaysDiff.abs(),
    };

    if (units.contains('years')) {
      int years = 0;
      while (true) {
        final next = addYears(cursor, 1);
        if (diffInDays(later, next) >= 0) {
          years += 1;
          cursor = next;
        } else {
          break;
        }
      }
      result['years'] = years;
    }

    if (units.contains('months')) {
      int months = 0;
      while (true) {
        final next = addMonths(cursor, 1);
        if (diffInDays(later, next) >= 0) {
          months += 1;
          cursor = next;
        } else {
          break;
        }
      }
      result['months'] = months;
    }

    if (units.contains('days')) {
      result['days'] = diffInDays(later, cursor).abs();
    }

    return result;
  }
}

/// Convenience functions that match the original JavaScript API
/// These provide static access to the arithmetic functions

/// Adds a specified number of days to an Ethiopian date.
Map<String, int> addDays(Map<String, dynamic> ethiopian, int days) {
  return DayArithmetic.addDays(ethiopian, days);
}

/// Adds a specified number of months to an Ethiopian date.
Map<String, int> addMonths(Map<String, dynamic> ethiopian, int months) {
  return DayArithmetic.addMonths(ethiopian, months);
}

/// Adds a specified number of years to an Ethiopian date.
Map<String, int> addYears(Map<String, dynamic> ethiopian, int years) {
  return DayArithmetic.addYears(ethiopian, years);
}

/// Calculates the difference in days between two Ethiopian dates.
int diffInDays(Map<String, dynamic> a, Map<String, dynamic> b) {
  return DayArithmetic.diffInDays(a, b);
}

/// Calculates the difference in months between two Ethiopian dates.
int diffInMonths(Map<String, dynamic> a, Map<String, dynamic> b) {
  return DayArithmetic.diffInMonths(a, b);
}

/// Calculates the difference in years between two Ethiopian dates.
int diffInYears(Map<String, dynamic> a, Map<String, dynamic> b) {
  return DayArithmetic.diffInYears(a, b);
}

/// Calculates a human-friendly breakdown between two Ethiopian dates.
Map<String, dynamic> diffBreakdown(
  Map<String, dynamic> a,
  Map<String, dynamic> b, [
  Map<String, dynamic>? options,
]) {
  return DayArithmetic.diffBreakdown(a, b, options);
}
