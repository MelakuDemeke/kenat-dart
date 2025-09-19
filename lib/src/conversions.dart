/// Date conversion functions between Ethiopian and Gregorian calendars
/// Also includes Islamic/Hijri calendar conversions

import 'errors/error_handler.dart';
import 'utils.dart';

/// Ethiopian to Gregorian and Gregorian to Ethiopian date conversion functions
class Conversions {
  /// Validates that all provided date parts are numbers.
  ///
  /// [funcName] - The name of the function being validated.
  /// [dateParts] - A map where keys are param names and values are the inputs.
  ///
  /// Throws [InvalidInputTypeError] if any value is not a number.
  static void _validateNumericInputs(
    String funcName,
    Map<String, dynamic> dateParts,
  ) {
    for (final entry in dateParts.entries) {
      final name = entry.key;
      final value = entry.value;
      if (value is! num) {
        throw InvalidInputTypeError(funcName, name, 'number', value);
      }
    }
  }

  /// Converts an Ethiopian date to its corresponding Gregorian date.
  ///
  /// [ethYear] - The Ethiopian year.
  /// [ethMonth] - The Ethiopian month (1-13).
  /// [ethDay] - The Ethiopian day of the month.
  ///
  /// Returns a map with year, month, and day keys.
  /// Throws [InvalidInputTypeError] If any input is not a number.
  /// Throws [InvalidEthiopianDateError] If the provided Ethiopian date is invalid.
  static Map<String, int> toGC(int ethYear, int ethMonth, int ethDay) {
    // 1. Validate input types first
    _validateNumericInputs('toGC', {
      'ethYear': ethYear,
      'ethMonth': ethMonth,
      'ethDay': ethDay,
    });

    // 2. Validate date range
    if (ethMonth < 1 || ethMonth > 13) {
      throw InvalidEthiopianDateError(ethYear, ethMonth, ethDay);
    }
    final maxDay = ethMonth == 13 ? (isEthiopianLeapYear(ethYear) ? 6 : 5) : 30;
    if (ethDay < 1 || ethDay > maxDay) {
      throw InvalidEthiopianDateError(ethYear, ethMonth, ethDay);
    }

    // 3. Perform conversion
    final newYear = getGregorianDateOfEthiopianNewYear(ethYear);
    final daysSinceNewYear = (ethMonth - 1) * 30 + ethDay - 1;
    final newYearDOY = dayOfYear(
      newYear['gregorianYear']!,
      newYear['month']!,
      newYear['day']!,
    );
    int gregorianDOY = newYearDOY + daysSinceNewYear;
    int gregorianYear = newYear['gregorianYear']!;
    final yearLength = isGregorianLeapYear(gregorianYear) ? 366 : 365;

    if (gregorianDOY > yearLength) {
      gregorianDOY -= yearLength;
      gregorianYear += 1;
    }

    final monthDay = monthDayFromDayOfYear(gregorianYear, gregorianDOY);
    return {
      'year': gregorianYear,
      'month': monthDay['month']!,
      'day': monthDay['day']!,
    };
  }

  /// Converts a Gregorian date to the Ethiopian calendar (EC) date.
  ///
  /// [gYear] - The Gregorian year (e.g., 2024).
  /// [gMonth] - The Gregorian month (1-12).
  /// [gDay] - The Gregorian day of the month (1-31).
  ///
  /// Returns a map with year, month, and day keys.
  /// Throws [InvalidInputTypeError] If any input is not a number.
  /// Throws [InvalidGregorianDateError] If the input date is invalid or out of supported range.
  static Map<String, int> toEC(int gYear, int gMonth, int gDay) {
    // 1. Validate input types first
    _validateNumericInputs('toEC', {
      'gYear': gYear,
      'gMonth': gMonth,
      'gDay': gDay,
    });

    // 2. Validate date range and validity
    bool isValidDate(int y, int m, int d) {
      try {
        final date = DateTime.utc(y, m, d);
        return date.year == y && date.month == m && date.day == d;
      } catch (e) {
        return false;
      }
    }

    try {
      final inputDate = DateTime.utc(gYear, gMonth, gDay);
      final minDate = DateTime.utc(1900, 1, 1);
      final maxDate = DateTime.utc(2100, 12, 31);

      if (!isValidDate(gYear, gMonth, gDay) ||
          inputDate.isBefore(minDate) ||
          inputDate.isAfter(maxDate)) {
        throw InvalidGregorianDateError(gYear, gMonth, gDay);
      }
    } catch (e) {
      throw InvalidGregorianDateError(gYear, gMonth, gDay);
    }

    // 3. Perform conversion
    const oneDay = 86400000;
    const oneYear = 365 * oneDay;
    const fourYears = 1461 * oneDay;
    final baseDate = DateTime.utc(1971, 9, 12);
    final inputDate = DateTime.utc(gYear, gMonth, gDay);
    final diff =
        inputDate.millisecondsSinceEpoch - baseDate.millisecondsSinceEpoch;
    final fourYearCycles = (diff / fourYears).floor();
    int remainingYears = ((diff - fourYearCycles * fourYears) / oneYear)
        .floor();

    if (remainingYears == 4) remainingYears = 3;

    final remainingMonths =
        ((diff - fourYearCycles * fourYears - remainingYears * oneYear) /
                (30 * oneDay))
            .floor();

    final remainingDays =
        ((diff -
                    fourYearCycles * fourYears -
                    remainingYears * oneYear -
                    remainingMonths * 30 * oneDay) /
                oneDay)
            .floor();

    final ethYear = 1964 + fourYearCycles * 4 + remainingYears;
    final month = remainingMonths + 1;
    final day = remainingDays + 1;

    return {'year': ethYear, 'month': month, 'day': day};
  }

  /// Converts an Ethiopian date to a Gregorian Calendar DateTime object (UTC).
  ///
  /// [ethYear] - The Ethiopian year.
  /// [ethMonth] - The Ethiopian month (1-based).
  /// [ethDay] - The Ethiopian day.
  ///
  /// Returns a DateTime object representing the equivalent Gregorian date in UTC.
  static DateTime toGCDate(int ethYear, int ethMonth, int ethDay) {
    final gregorian = toGC(ethYear, ethMonth, ethDay);
    return DateTime.utc(
      gregorian['year']!,
      gregorian['month']!,
      gregorian['day']!,
    );
  }

  /// Converts a DateTime object to the Ethiopian Calendar (EC) date representation.
  ///
  /// [dateObj] - The DateTime object to convert.
  ///
  /// Returns the Ethiopian Calendar date, as returned by the `toEC` function.
  static Map<String, int> fromDateToEC(DateTime dateObj) {
    return toEC(dateObj.year, dateObj.month, dateObj.day);
  }
}

/// Islamic/Hijri calendar conversion functions
class IslamicConversions {
  /// Get Hijri year from a Gregorian date
  /// Note: This is a simplified implementation. For production use, consider using a dedicated Islamic calendar library.
  ///
  /// [date] - The Gregorian date
  /// Returns the approximate Hijri year
  static int getHijriYear(DateTime date) {
    // Simplified calculation: Hijri year ≈ Gregorian year - 622 + (Gregorian year - 622) / 33
    // This is an approximation and may not be accurate for all dates
    final gregorianYear = date.year;
    final hijriYear =
        (gregorianYear - 622) + ((gregorianYear - 622) / 33).round();
    return hijriYear;
  }

  /// Converts a Hijri date to the corresponding Gregorian date within a given Gregorian year.
  /// Note: This is a simplified implementation and may not be accurate for all dates.
  ///
  /// [hYear] - Hijri year (e.g., 1445)
  /// [hMonth] - Hijri month (1–12)
  /// [hDay] - Hijri day (1–30)
  /// [gregorianYear] - Target Gregorian year to restrict the search range
  ///
  /// Returns Gregorian DateTime object or null if not found
  static DateTime? hijriToGregorian(
    int hYear,
    int hMonth,
    int hDay,
    int gregorianYear,
  ) {
    // This is a simplified implementation
    // For production use, consider using a dedicated Islamic calendar library like 'package:islamic_calendar'

    // Approximate conversion: Hijri to Gregorian
    // This is not accurate for all dates and should be replaced with proper Islamic calendar calculations
    final baseGregorianYear = hYear + 622 - (hYear / 33).round();

    if (baseGregorianYear != gregorianYear) {
      return null; // Date not found in the specified Gregorian year
    }

    // Simplified month and day calculation
    // In reality, Islamic months have varying lengths and require complex calculations
    final month = hMonth;
    final day = hDay;

    try {
      return DateTime.utc(gregorianYear, month, day);
    } catch (e) {
      return null;
    }
  }

  /// Converts a Gregorian date to Hijri date
  /// Note: This is a simplified implementation and may not be accurate for all dates.
  ///
  /// [gregorianDate] - The Gregorian date to convert
  ///
  /// Returns a map with hijriYear, hijriMonth, and hijriDay
  static Map<String, int> gregorianToHijri(DateTime gregorianDate) {
    // This is a simplified implementation
    // For production use, consider using a dedicated Islamic calendar library

    final hijriYear = getHijriYear(gregorianDate);

    // Simplified calculation - in reality this requires complex astronomical calculations
    final hijriMonth = gregorianDate.month;
    final hijriDay = gregorianDate.day;

    return {
      'hijriYear': hijriYear,
      'hijriMonth': hijriMonth,
      'hijriDay': hijriDay,
    };
  }
}

/// Convenience functions that match the original JavaScript API
/// These provide static access to the conversion functions

/// Converts an Ethiopian date to its corresponding Gregorian date.
Map<String, int> toGC(int ethYear, int ethMonth, int ethDay) {
  return Conversions.toGC(ethYear, ethMonth, ethDay);
}

/// Converts a Gregorian date to the Ethiopian calendar (EC) date.
Map<String, int> toEC(int gYear, int gMonth, int gDay) {
  return Conversions.toEC(gYear, gMonth, gDay);
}

/// Converts an Ethiopian date to a Gregorian Calendar DateTime object (UTC).
DateTime toGCDate(int ethYear, int ethMonth, int ethDay) {
  return Conversions.toGCDate(ethYear, ethMonth, ethDay);
}

/// Converts a DateTime object to the Ethiopian Calendar (EC) date representation.
Map<String, int> fromDateToEC(DateTime dateObj) {
  return Conversions.fromDateToEC(dateObj);
}

/// Get Hijri year from a Gregorian date
int getHijriYear(DateTime date) {
  return IslamicConversions.getHijriYear(date);
}

/// Converts a Hijri date to the corresponding Gregorian date within a given Gregorian year.
DateTime? hijriToGregorian(int hYear, int hMonth, int hDay, int gregorianYear) {
  return IslamicConversions.hijriToGregorian(
    hYear,
    hMonth,
    hDay,
    gregorianYear,
  );
}

/// Converts a Gregorian date to Hijri date
Map<String, int> gregorianToHijri(DateTime gregorianDate) {
  return IslamicConversions.gregorianToHijri(gregorianDate);
}
