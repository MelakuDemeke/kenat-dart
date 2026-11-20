/// Utility functions for Ethiopian calendar operations
/// Contains validation, leap year calculations, and other helper functions
library;

import 'conversions.dart';
import 'errors/error_handler.dart';

/// Validation helper functions
class ValidationHelpers {
  /// Validates that all provided date parts are numbers.
  ///
  /// [funcName] - The name of the function being validated.
  /// [dateParts] - A map where keys are param names and values are the inputs.
  ///
  /// Throws [InvalidInputTypeError] if any value is not a number.
  static void validateNumericInputs(
    String funcName,
    Map<String, dynamic> dateParts,
  ) {
    for (final entry in dateParts.entries) {
      final name = entry.key;
      final value = entry.value;
      if (value is! num || value.isNaN) {
        throw InvalidInputTypeError(funcName, name, 'number', value);
      }
    }
  }

  /// Validates that the input is a valid Ethiopian date object.
  ///
  /// [dateObj] - The object to validate.
  /// [funcName] - The name of the function being validated.
  /// [paramName] - The name of the parameter being validated.
  ///
  /// Throws [InvalidInputTypeError] if the object is invalid.
  static void validateEthiopianDateObject(
    Map<String, dynamic> dateObj,
    String funcName,
    String paramName,
  ) {
    if (dateObj.isEmpty ||
        !dateObj.containsKey('year') ||
        !dateObj.containsKey('month') ||
        !dateObj.containsKey('day')) {
      throw InvalidInputTypeError(
        funcName,
        paramName,
        'object with year, month, day',
        dateObj,
      );
    }
    validateNumericInputs(funcName, {
      '$paramName.year': dateObj['year'],
      '$paramName.month': dateObj['month'],
      '$paramName.day': dateObj['day'],
    });
  }

  /// Validates that the input is a valid Ethiopian time object.
  ///
  /// [timeObj] - The object to validate.
  /// [funcName] - The name of the function being validated.
  /// [paramName] - The name of the parameter being validated.
  ///
  /// Throws [InvalidInputTypeError] if the object is invalid.
  static void validateEthiopianTimeObject(
    Map<String, dynamic> timeObj,
    String funcName,
    String paramName,
  ) {
    if (timeObj.isEmpty ||
        !timeObj.containsKey('hour') ||
        !timeObj.containsKey('minute') ||
        !timeObj.containsKey('period')) {
      throw InvalidInputTypeError(
        funcName,
        paramName,
        'object with hour, minute, period',
        timeObj,
      );
    }
    if (timeObj['period'] != 'day' && timeObj['period'] != 'night') {
      throw InvalidInputTypeError(
        funcName,
        '$paramName.period',
        "'day' or 'night'",
        timeObj['period'],
      );
    }
    validateNumericInputs(funcName, {
      '$paramName.hour': timeObj['hour'],
      '$paramName.minute': timeObj['minute'],
    });
  }
}

/// Date calculation utilities
class DateUtils {
  /// Calculates the day of the year for a given Gregorian date.
  ///
  /// [year] - The full year (e.g., 2024).
  /// [month] - The month (1-based, January is 1, December is 12).
  /// [day] - The day of the month.
  ///
  /// Returns the day of the year (1-based).
  static int dayOfYear(int year, int month, int day) {
    final monthLengths = [
      31,
      isGregorianLeapYear(year) ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    int doy = 0;
    for (int i = 0; i < month - 1; i++) {
      doy += monthLengths[i];
    }
    doy += day;
    return doy;
  }

  /// Convert a day of year to Gregorian month and day.
  ///
  /// [year] - The Gregorian year.
  /// [dayOfYear] - The day of the year (1-based).
  ///
  /// Returns a map with 'month' and 'day' keys.
  static Map<String, int> monthDayFromDayOfYear(int year, int dayOfYear) {
    final monthLengths = [
      31,
      isGregorianLeapYear(year) ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    int month = 1;
    int remainingDays = dayOfYear;

    while (remainingDays > monthLengths[month - 1]) {
      remainingDays -= monthLengths[month - 1];
      month++;
    }

    return {'month': month, 'day': remainingDays};
  }
}

/// Leap year calculations
class LeapYearUtils {
  /// Checks if the given Gregorian year is a leap year.
  ///
  /// Gregorian leap years occur every 4 years, except centuries not divisible by 400.
  /// For example: 2000 is a leap year, 1900 is not.
  ///
  /// [year] - Gregorian calendar year (e.g., 2025)
  /// Returns true if the year is a leap year, otherwise false.
  static bool isGregorianLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Checks if the given Ethiopian year is a leap year.
  ///
  /// Ethiopian leap years occur every 4 years, when the year modulo 4 equals 3.
  /// This means years like 2011, 2015, 2019 (in Ethiopian calendar) are leap years.
  ///
  /// [year] - Ethiopian calendar year (e.g., 2011)
  /// Returns true if the year is a leap year, otherwise false.
  static bool isEthiopianLeapYear(int year) {
    return year % 4 == 3;
  }
}

/// Ethiopian calendar specific utilities
class EthiopianCalendarUtils {
  /// Returns the number of days in the given Ethiopian month and year.
  ///
  /// [year] - Ethiopian year
  /// [month] - Ethiopian month (1-13)
  /// Returns number of days in the month
  static int getEthiopianDaysInMonth(int year, int month) {
    if (month == 13) {
      return LeapYearUtils.isEthiopianLeapYear(year) ? 6 : 5;
    }
    return 30;
  }

  /// Returns the weekday (0-6) for a given Ethiopian date.
  ///
  /// [year] - The Ethiopian year.
  /// [month] - The Ethiopian month (1-13).
  /// [day] - The Ethiopian day (1-30).
  /// Returns the day of the week (0 for Sunday, 6 for Saturday).
  static int getWeekday(int year, int month, int day) {
    final g = Conversions.toGC(year, month, day);
    final date = DateTime(g['year']!, g['month']!, g['day']!);
    return date.weekday % 7; // Convert Monday=1 to Sunday=0 format
  }

  /// Checks if a given Ethiopian date is valid.
  ///
  /// [year] - Ethiopian year
  /// [month] - Ethiopian month (1-13)
  /// [day] - Ethiopian day (1-30 or 1-5/6)
  /// Returns true if the date is valid, otherwise false.
  static bool isValidEthiopianDate(int year, int month, int day) {
    if (month < 1 || month > 13) {
      return false;
    }
    if (day < 1 || day > getEthiopianDaysInMonth(year, month)) {
      return false;
    }
    return true;
  }

  /// Helper: Get Ethiopian New Year for a Gregorian year.
  ///
  /// [gYear] - The Gregorian year.
  /// Returns a map with gregorianYear, month, and day.
  /// Throws [InvalidInputTypeError] If gYear is not a number.
  static Map<String, int> getEthiopianNewYearForGregorian(int gYear) {
    ValidationHelpers.validateNumericInputs('getEthiopianNewYearForGregorian', {
      'gYear': gYear,
    });
    // Meskerem 1 in September of gYear belongs to Ethiopian year gYear - 7.
    final newYear = _meskerem1(gYear - 7);
    return {'gregorianYear': gYear, 'month': 9, 'day': newYear.day};
  }

  /// Gregorian date (UTC) of Meskerem 1 of [ethiopianYear].
  ///
  /// The Ethiopian leap cycle has no century exception (year Y is leap when
  /// Y % 4 == 3), so count days from Meskerem 1, 1964 = 1971-09-12.
  static DateTime _meskerem1(int ethiopianYear) {
    final days = 365 * (ethiopianYear - 1964) +
        (ethiopianYear / 4).floor() -
        (1964 / 4).floor();
    return DateTime.utc(1971, 9, 12 + days);
  }

  /// Returns the Gregorian date of the Ethiopian New Year for the given Ethiopian year.
  ///
  /// [ethiopianYear] - Ethiopian calendar year.
  /// Returns a map with gregorianYear, month, and day.
  /// Throws [InvalidInputTypeError] If ethiopianYear is not a number.
  static Map<String, int> getGregorianDateOfEthiopianNewYear(
    int ethiopianYear,
  ) {
    ValidationHelpers.validateNumericInputs(
      'getGregorianDateOfEthiopianNewYear',
      {'ethiopianYear': ethiopianYear},
    );
    final newYear = _meskerem1(ethiopianYear);
    return {
      'gregorianYear': newYear.year,
      'month': newYear.month,
      'day': newYear.day,
    };
  }
}

/// Convenience functions that match the original JavaScript API
/// These provide static access to the utility functions

/// Validates that all provided date parts are numbers.
void validateNumericInputs(String funcName, Map<String, dynamic> dateParts) {
  ValidationHelpers.validateNumericInputs(funcName, dateParts);
}

/// Validates that the input is a valid Ethiopian date object.
void validateEthiopianDateObject(
  Map<String, dynamic> dateObj,
  String funcName,
  String paramName,
) {
  ValidationHelpers.validateEthiopianDateObject(dateObj, funcName, paramName);
}

/// Validates that the input is a valid Ethiopian time object.
void validateEthiopianTimeObject(
  Map<String, dynamic> timeObj,
  String funcName,
  String paramName,
) {
  ValidationHelpers.validateEthiopianTimeObject(timeObj, funcName, paramName);
}

/// Calculates the day of the year for a given date.
int dayOfYear(int year, int month, int day) {
  return DateUtils.dayOfYear(year, month, day);
}

/// Convert a day of year to Gregorian month and day.
Map<String, int> monthDayFromDayOfYear(int year, int dayOfYear) {
  return DateUtils.monthDayFromDayOfYear(year, dayOfYear);
}

/// Checks if the given Gregorian year is a leap year.
bool isGregorianLeapYear(int year) {
  return LeapYearUtils.isGregorianLeapYear(year);
}

/// Checks if the given Ethiopian year is a leap year.
bool isEthiopianLeapYear(int year) {
  return LeapYearUtils.isEthiopianLeapYear(year);
}

/// Returns the number of days in the given Ethiopian month and year.
int getEthiopianDaysInMonth(int year, int month) {
  return EthiopianCalendarUtils.getEthiopianDaysInMonth(year, month);
}

/// Returns the weekday (0-6) for a given Ethiopian date.
int getWeekday(int year, int month, int day) {
  return EthiopianCalendarUtils.getWeekday(year, month, day);
}

/// Checks if a given Ethiopian date is valid.
bool isValidEthiopianDate(int year, int month, int day) {
  return EthiopianCalendarUtils.isValidEthiopianDate(year, month, day);
}

/// Helper: Get Ethiopian New Year for a Gregorian year.
Map<String, int> getEthiopianNewYearForGregorian(int gYear) {
  return EthiopianCalendarUtils.getEthiopianNewYearForGregorian(gYear);
}

/// Returns the Gregorian date of the Ethiopian New Year for the given Ethiopian year.
Map<String, int> getGregorianDateOfEthiopianNewYear(int ethiopianYear) {
  return EthiopianCalendarUtils.getGregorianDateOfEthiopianNewYear(
    ethiopianYear,
  );
}
