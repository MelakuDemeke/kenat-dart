/// Main Ethiopian calendar class
/// The core wrapper class that provides the main API for Ethiopian calendar operations

import 'conversions.dart';
import 'constants.dart';
import 'time.dart';
import 'bahire_hasab.dart';
import 'month_grid.dart';
import 'holidays.dart';
import 'utils.dart';
import 'formatting.dart';
import 'day_arithmetic.dart';
import 'errors/error_handler.dart';

/// Main Ethiopian calendar class
class Kenat {
  late Map<String, dynamic> _ethiopian;
  late Map<String, dynamic> _gregorian;
  late Time? _time;

  /// Constructor for Kenat class
  ///
  /// [input] - Can be a DateTime, Ethiopian date object, or date string.
  /// [time] - Optional Time object.
  Kenat(dynamic input, [Time? time]) {
    _time = time;
    _parseInput(input);
  }

  /// Creates a Kenat instance from current date and time
  static Kenat now() {
    final now = DateTime.now();
    return Kenat(now);
  }

  /// Creates a Kenat instance from Ethiopian date
  static Kenat fromEthiopian(int year, int month, int day, [Time? time]) {
    return Kenat({'year': year, 'month': month, 'day': day}, time);
  }

  /// Creates a Kenat instance from Gregorian date
  static Kenat fromGregorian(int year, int month, int day, [Time? time]) {
    final date = DateTime(year, month, day);
    return Kenat(date, time);
  }

  /// Parses input and sets Ethiopian and Gregorian dates
  void _parseInput(dynamic input) {
    if (input is DateTime) {
      _gregorian = {'year': input.year, 'month': input.month, 'day': input.day};
      _ethiopian = Conversions.toEC(input.year, input.month, input.day);
    } else if (input is Map<String, dynamic>) {
      if (input.containsKey('year') &&
          input.containsKey('month') &&
          input.containsKey('day')) {
        _ethiopian = Map<String, dynamic>.from(input);
        _gregorian = Conversions.toGC(
          input['year']!,
          input['month']!,
          input['day']!,
        );
      } else {
        throw UnrecognizedInputError(input);
      }
    } else if (input is String) {
      _parseDateString(input);
    } else {
      throw UnrecognizedInputError(input);
    }
  }

  /// Parses date string in format "yyyy/mm/dd" or "yyyy-mm-dd"
  void _parseDateString(String dateString) {
    final cleanString = dateString.trim();
    final separator = cleanString.contains('/') ? '/' : '-';

    if (!cleanString.contains(separator)) {
      throw InvalidDateFormatError(dateString);
    }

    final parts = cleanString.split(separator);
    if (parts.length != 3) {
      throw InvalidDateFormatError(dateString);
    }

    try {
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      _ethiopian = {'year': year, 'month': month, 'day': day};
      _gregorian = Conversions.toGC(year, month, day);
    } catch (e) {
      throw InvalidDateFormatError(dateString);
    }
  }

  /// Gets the Ethiopian date
  Map<String, dynamic> getEthiopian() {
    return Map<String, dynamic>.from(_ethiopian);
  }

  /// Gets the Gregorian date
  Map<String, dynamic> getGregorian() {
    return Map<String, dynamic>.from(_gregorian);
  }

  /// Gets the time if set
  Time? getTime() {
    return _time;
  }

  /// Returns current Ethiopian Time for the instance (based on system clock)
  Time getCurrentTime() {
    final now = DateTime.now();
    return Time.fromGregorian(now.hour, now.minute);
  }

  /// Public accessor for time to support chaining-style API (`.time`).
  Time? get time => _time;

  /// Sets the time
  /// Sets the time on this instance (mutable). Also supports a chaining
  /// friendly form when called with primitives: `setTime(hour, minute, period)`
  ///
  /// Behavior:
  /// - If called with a `Time` instance, mutates this instance and returns void.
  /// - If called with primitives, returns a new `Kenat` with the updated time
  ///   (immutable/chaining-friendly).
  dynamic setTime(dynamic a, [int? minute, String? period]) {
    if (a is Time) {
      _time = a;
      return null;
    }

    if (a is int) {
      final h = a;
      final m = minute ?? 0;
      final p = period ?? 'day';
      final newTime = Time(h, m, p);
      return Kenat({
        'year': _ethiopian['year'],
        'month': _ethiopian['month'],
        'day': _ethiopian['day'],
      }, newTime);
    }

    throw UnrecognizedInputError(a);
  }

  /// Gets the weekday (0-6, Sunday = 0)
  int getWeekday() {
    return EthiopianCalendarUtils.getWeekday(
      _ethiopian['year']!,
      _ethiopian['month']!,
      _ethiopian['day']!,
    );
  }

  /// Gets the weekday name
  String getWeekdayName([String lang = 'amharic']) {
    final weekday = getWeekday();
    return lang == 'english'
        ? DaysOfWeek.english[weekday]
        : DaysOfWeek.amharic[weekday];
  }

  // --- Compatibility helpers to match the JS Kenat API used by tests ---

  /// Returns true if this date is before [other]
  bool isBefore(Kenat other) {
    return DayArithmetic.diffInDays(_ethiopian, other._ethiopian) < 0;
  }

  /// Returns true if this date is after [other]
  bool isAfter(Kenat other) {
    return DayArithmetic.diffInDays(_ethiopian, other._ethiopian) > 0;
  }

  /// Returns true if this date falls on the same Ethiopian day as [other]
  bool isSameDay(Kenat other) {
    return _ethiopian['year'] == other._ethiopian['year'] &&
        _ethiopian['month'] == other._ethiopian['month'] &&
        _ethiopian['day'] == other._ethiopian['day'];
  }

  /// Convenience alias matching JS API: startOfMonth()
  Kenat startOfMonth() {
    return startOf('month');
  }

  /// Convenience alias matching JS API: endOfMonth()
  Kenat endOfMonth() {
    final lastDay = EthiopianCalendarUtils.getEthiopianDaysInMonth(
      _ethiopian['year']!,
      _ethiopian['month']!,
    );
    return Kenat({
      'year': _ethiopian['year'],
      'month': _ethiopian['month'],
      'day': lastDay,
    }, _time);
  }

  /// Compatibility: weekday() -> returns numeric weekday (0-6)
  int weekday() => getWeekday();

  /// Compatibility: format({ lang: 'english' })
  String format({String lang = 'amharic'}) => formatStandard(lang);

  /// Compatibility: formatInGeezAmharic()
  String formatInGeezAmharic() => formatInGeez();

  /// Checks if this is a leap year
  bool isLeapYear() {
    return LeapYearUtils.isEthiopianLeapYear(_ethiopian['year']!);
  }

  /// Gets the number of days in the current month
  int getDaysInMonth() {
    return EthiopianCalendarUtils.getEthiopianDaysInMonth(
      _ethiopian['year']!,
      _ethiopian['month']!,
    );
  }

  /// Gets the day of the year
  int getDayOfYear() {
    return DateUtils.dayOfYear(
      _ethiopian['year']!,
      _ethiopian['month']!,
      _ethiopian['day']!,
    );
  }

  /// Formats the date using standard format
  String formatStandard([String lang = 'amharic']) {
    return DateFormatter.formatStandard(_ethiopian, lang);
  }

  /// Formats the date in Geez numerals
  String formatInGeez() {
    return DateFormatter.formatInGeezAmharic(_ethiopian);
  }

  /// Formats the date with weekday
  String formatWithWeekday([String lang = 'amharic', bool useGeez = false]) {
    return DateFormatter.formatWithWeekday(_ethiopian, lang, useGeez);
  }

  /// Formats the date with time
  String formatWithTime([String lang = 'amharic']) {
    if (_time == null) {
      return formatStandard(lang);
    }
    return DateFormatter.formatWithTime(_ethiopian, _time!, lang);
  }

  /// Returns short format "yyyy/mm/dd"
  String formatShort() {
    return DateFormatter.formatShort(_ethiopian);
  }

  /// Returns ISO-like format
  String toISODateString() {
    final timeMap = _time != null
        ? {
            'hour': _time!.hour,
            'minute': _time!.minute,
            'period': _time!.period,
          }
        : null;
    return DateFormatter.toISODateString(_ethiopian, timeMap);
  }

  /// Adds days to the current date
  Kenat addDays(int days) {
    final newDate = DayArithmetic.addDays(_ethiopian, days);
    return Kenat(newDate, _time);
  }

  /// Generic add that supports chaining: `add(amount, unit)` where unit is
  /// 'days'|'day'|'months'|'month'|'years'|'year'. Throws [ArgumentError]
  /// for invalid unit or non-numeric amount.
  Kenat add(dynamic amount, String unit) {
    if (amount is! num) throw ArgumentError('Amount must be a number');
    final intAmt = (amount as num).toInt();
    switch (unit) {
      case 'days':
      case 'day':
        return addDays(intAmt);
      case 'months':
      case 'month':
        return addMonths(intAmt);
      case 'years':
      case 'year':
        return addYears(intAmt);
      default:
        throw ArgumentError('Invalid unit: $unit');
    }
  }

  /// Generic subtract for chaining
  Kenat subtract(dynamic amount, String unit) {
    if (amount is! num) throw ArgumentError('Amount must be a number');
    final intAmt = (amount as num).toInt();
    return add(-intAmt, unit);
  }

  /// Adds months to the current date
  Kenat addMonths(int months) {
    final newDate = DayArithmetic.addMonths(_ethiopian, months);
    return Kenat(newDate, _time);
  }

  /// Adds years to the current date
  Kenat addYears(int years) {
    final newDate = DayArithmetic.addYears(_ethiopian, years);
    return Kenat(newDate, _time);
  }

  /// startOf(unit) supports 'month' and 'day' and returns a new Kenat.
  Kenat startOf(String unit) {
    switch (unit) {
      case 'month':
        final newDate = {
          'year': _ethiopian['year'],
          'month': _ethiopian['month'],
          'day': 1,
        };
        return Kenat(newDate, _time);
      case 'day':
        // Start of day -> set time to start (1:00 day)
        final startTime = Time(1, 0, 'day');
        return Kenat({
          'year': _ethiopian['year'],
          'month': _ethiopian['month'],
          'day': _ethiopian['day'],
        }, startTime);
      default:
        throw ArgumentError('Invalid unit: $unit');
    }
  }

  /// endOf(unit) supports 'day' and returns a new Kenat with time set to end
  /// of day (12:00 night) which matches the library's convention.
  Kenat endOf(String unit) {
    switch (unit) {
      case 'day':
        final endTime = Time(12, 0, 'night');
        return Kenat({
          'year': _ethiopian['year'],
          'month': _ethiopian['month'],
          'day': _ethiopian['day'],
        }, endTime);
      case 'month':
        final lastDay = EthiopianCalendarUtils.getEthiopianDaysInMonth(
          _ethiopian['year']!,
          _ethiopian['month']!,
        );
        return Kenat({
          'year': _ethiopian['year'],
          'month': _ethiopian['month'],
          'day': lastDay,
        }, _time);
      default:
        throw ArgumentError('Invalid unit: $unit');
    }
  }

  /// Factory to create from a string (e.g. '2017/1/1') with optional time
  static Kenat fromString(
    String input, {
    int? hour,
    int? minute,
    String? period,
  }) {
    final time = (hour != null)
        ? Time(hour, minute ?? 0, period ?? 'day')
        : null;
    return Kenat(input, time);
  }

  /// Calculates the difference in days from another date
  int diffInDays(Kenat other) {
    return DayArithmetic.diffInDays(_ethiopian, other._ethiopian);
  }

  /// Calculates the difference in months from another date
  int diffInMonths(Kenat other) {
    return DayArithmetic.diffInMonths(_ethiopian, other._ethiopian);
  }

  /// Calculates the difference in years from another date
  int diffInYears(Kenat other) {
    return DayArithmetic.diffInYears(_ethiopian, other._ethiopian);
  }

  /// Gets a detailed breakdown of the difference
  Map<String, dynamic> diffBreakdown(
    Kenat other, [
    Map<String, dynamic>? options,
  ]) {
    return DayArithmetic.diffBreakdown(_ethiopian, other._ethiopian, options);
  }

  /// Gets holidays for the current month
  List<Map<String, dynamic>> getHolidaysInMonth([
    Map<String, dynamic>? options,
  ]) {
    return HolidayCalculator.getHolidaysInMonth(
      _ethiopian['year']!,
      _ethiopian['month']!,
      options,
    );
  }

  /// Gets holidays for the current year
  List<Map<String, dynamic>> getHolidaysForYear([
    Map<String, dynamic>? options,
  ]) {
    return HolidayCalculator.getHolidaysForYear(_ethiopian['year']!, options);
  }

  /// Gets Bahire Hasab information for the current year
  Map<String, dynamic> getBahireHasab([Map<String, dynamic>? options]) {
    return BahireHasab.getBahireHasab(_ethiopian['year']!, options);
  }

  /// Gets month calendar grid
  Map<String, dynamic> getMonthCalendar([
    int? year,
    int? month,
    bool? useGeez,
  ]) {
    final targetYear = year ?? _ethiopian['year']!;
    final targetMonth = month ?? _ethiopian['month']!;
    final useGeezFlag = useGeez ?? false;

    return MonthGrid.create({
      'year': targetYear,
      'month': targetMonth,
      'useGeez': useGeezFlag,
    });
  }

  /// Checks if the current date is today
  bool get isToday {
    final today = DateTime.now();
    final todayEthiopian = Conversions.toEC(today.year, today.month, today.day);
    return _ethiopian['year'] == todayEthiopian['year'] &&
        _ethiopian['month'] == todayEthiopian['month'] &&
        _ethiopian['day'] == todayEthiopian['day'];
  }

  /// Checks if the current date is a weekend
  bool get isWeekend {
    final weekday = getWeekday();
    return weekday == 0 || weekday == 6; // Sunday or Saturday
  }

  /// Gets the age in years from birth date
  int getAge(Kenat birthDate) {
    return diffInYears(birthDate);
  }

  /// Returns a string representation
  @override
  String toString() {
    return 'Kenat(${formatStandard()})';
  }

  /// Checks equality with another Kenat instance
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Kenat) return false;
    return _ethiopian['year'] == other._ethiopian['year'] &&
        _ethiopian['month'] == other._ethiopian['month'] &&
        _ethiopian['day'] == other._ethiopian['day'];
  }

  /// Gets hash code
  @override
  int get hashCode {
    return _ethiopian['year']!.hashCode ^
        _ethiopian['month']!.hashCode ^
        _ethiopian['day']!.hashCode;
  }
}

/// Convenience function to create a Kenat instance from current time
Kenat kenatNow() {
  return Kenat.now();
}

/// Convenience function to create a Kenat instance from Ethiopian date
Kenat kenatFromEthiopian(int year, int month, int day, [Time? time]) {
  return Kenat.fromEthiopian(year, month, day, time);
}

/// Convenience function to create a Kenat instance from Gregorian date
Kenat kenatFromGregorian(int year, int month, int day, [Time? time]) {
  return Kenat.fromGregorian(year, month, day, time);
}
