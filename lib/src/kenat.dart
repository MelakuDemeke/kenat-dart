/// Main Ethiopian calendar class
/// The core wrapper class that provides the main API for Ethiopian calendar operations
library;

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
import 'geez_converter.dart';
import 'render/print_month_calendar_grid.dart';

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

  /// Parses input and sets Ethiopian and Gregorian dates.
  ///
  /// Also ensures [_time] is always set when not explicitly overridden by
  /// the constructor's `time` parameter, matching TS's invariant that a
  /// `Kenat` instance always carries a time (default noon-day for
  /// object/string input, or the actual clock time for a `DateTime` input).
  void _parseInput(dynamic input) {
    if (input is DateTime) {
      _gregorian = {'year': input.year, 'month': input.month, 'day': input.day};
      _ethiopian = Conversions.toEC(input.year, input.month, input.day);
      _time ??= Time.fromGregorian(input.hour, input.minute);
    } else if (input is Map<String, dynamic>) {
      if (input.containsKey('year') &&
          input.containsKey('month') &&
          input.containsKey('day')) {
        final y = input['year'] as int;
        final m = input['month'] as int;
        final d = input['day'] as int;
        if (!EthiopianCalendarUtils.isValidEthiopianDate(y, m, d)) {
          throw InvalidEthiopianDateError(y, m, d);
        }
        _ethiopian = Map<String, dynamic>.from(input);
        _gregorian = Conversions.toGC(y, m, d);
        _time ??= Time(12, 0, 'day');
      } else {
        throw UnrecognizedInputError(input);
      }
    } else if (input is String) {
      _parseDateString(input);
      _time ??= Time(12, 0, 'day');
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

    int year, month, day;
    try {
      year = int.parse(parts[0]);
      month = int.parse(parts[1]);
      day = int.parse(parts[2]);
    } catch (e) {
      throw InvalidDateFormatError(dateString);
    }

    if (!EthiopianCalendarUtils.isValidEthiopianDate(year, month, day)) {
      throw InvalidEthiopianDateError(year, month, day);
    }

    _ethiopian = {'year': year, 'month': month, 'day': day};
    _gregorian = Conversions.toGC(year, month, day);
  }

  /// Gets the Ethiopian date
  Map<String, dynamic> getEthiopian() {
    return Map<String, dynamic>.from(_ethiopian);
  }

  /// Gets the Gregorian date
  Map<String, dynamic> getGregorian() {
    return Map<String, dynamic>.from(_gregorian);
  }

  /// Returns the date in whichever calendar is requested, so callers with a
  /// user-configurable calendar preference don't need an if/else between
  /// [getEthiopian] and [getGregorian] at every call site.
  ///
  /// [calendar] - 'ethiopian' (default) or 'gregorian'.
  Map<String, dynamic> getDate({String calendar = 'ethiopian'}) {
    return calendar == 'gregorian' ? getGregorian() : getEthiopian();
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

  /// Sets the time and returns a new [Kenat] instance. Supports method
  /// chaining. This is always immutable (matches TS's `setTime()`, which
  /// never mutates in place) - it accepts either primitives
  /// `setTime(hour, minute, period)` or a [Time] instance directly as a
  /// Dart-only convenience.
  Kenat setTime(dynamic a, [int? minute, String? period]) {
    Time newTime;
    if (a is Time) {
      newTime = a;
    } else if (a is int) {
      newTime = Time(a, minute ?? 0, period ?? 'day');
    } else {
      throw UnrecognizedInputError(a);
    }

    return Kenat({
      'year': _ethiopian['year'],
      'month': _ethiopian['month'],
      'day': _ethiopian['day'],
    }, newTime);
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

  /// Returns true if this date is in the same Ethiopian month and year as
  /// [other].
  bool isSameMonth(Kenat other) {
    return _ethiopian['year'] == other._ethiopian['year'] &&
        _ethiopian['month'] == other._ethiopian['month'];
  }

  /// Returns true if this date is in the same Ethiopian year as [other].
  bool isSameYear(Kenat other) {
    return _ethiopian['year'] == other._ethiopian['year'];
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

  /// Formats the date according to the specified options. Matches TS's
  /// unified `format()` API.
  ///
  /// [calendar] - 'ethiopian' (default) or 'gregorian'. When 'gregorian',
  ///   the date is rendered using English Gregorian month names; [useGeez]
  ///   is ignored.
  /// [lang] - Language to use for formatting ('amharic', 'english', etc.).
  /// [showWeekday] - Whether to include the weekday in the formatted string.
  /// [useGeez] - Whether to use Geez numerals (only applies if lang is
  ///   'amharic').
  /// [includeTime] - Whether to include the time in the formatted string
  ///   (only has an effect if a time was set on this instance).
  String format({
    String calendar = 'ethiopian',
    String lang = 'amharic',
    bool showWeekday = false,
    bool useGeez = false,
    bool includeTime = false,
  }) {
    if (calendar == 'gregorian') {
      final gregorian = getGregorian();

      if (showWeekday && includeTime) {
        final weekdayPart = DateFormatter.formatGregorianWithWeekday(
          gregorian,
          lang,
        );
        if (_time == null) return weekdayPart;
        final timePart = _time!.format({'lang': lang, 'useGeez': false});
        return '$weekdayPart $timePart';
      }

      if (showWeekday) {
        return DateFormatter.formatGregorianWithWeekday(gregorian, lang);
      }

      if (includeTime) {
        return _time != null
            ? DateFormatter.formatGregorianWithTime(gregorian, _time!, lang)
            : DateFormatter.formatGregorianStandard(gregorian);
      }

      return DateFormatter.formatGregorianStandard(gregorian);
    }

    if (showWeekday && includeTime) {
      final weekdayPart = DateFormatter.formatWithWeekday(
        _ethiopian,
        lang,
        useGeez,
      );
      if (_time == null) return weekdayPart;
      final timePart = _time!.format({'lang': lang, 'useGeez': useGeez});
      return '$weekdayPart $timePart';
    }

    if (showWeekday) {
      return DateFormatter.formatWithWeekday(_ethiopian, lang, useGeez);
    }

    if (includeTime) {
      return _time != null
          ? DateFormatter.formatWithTime(_ethiopian, _time!, lang)
          : DateFormatter.formatStandard(_ethiopian, lang);
    }

    return useGeez && lang == 'amharic'
        ? DateFormatter.formatInGeezAmharic(_ethiopian)
        : DateFormatter.formatStandard(_ethiopian, lang);
  }

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

  /// Returns an ISO-style date string: "YYYY-MM-DD" or "YYYY-MM-DDTHH:mm".
  ///
  /// [calendar] - 'ethiopian' (default) or 'gregorian'. 'gregorian' produces
  ///   a genuine ISO 8601 string: the date is Gregorian and the time is
  ///   converted from Kenat's Ethiopian 12-hour clock to Gregorian 24-hour
  ///   time, with no non-standard suffix - useful for interop. The default
  ///   'ethiopian' calendar keeps the existing [toISODateString] behavior
  ///   (including the non-standard `+12h` suffix for night times).
  String toISOString({String calendar = 'ethiopian'}) {
    if (calendar == 'gregorian') {
      return DateFormatter.toGregorianISODateString(_gregorian, _time);
    }
    return toISODateString();
  }

  /// Checks if the current date is a holiday.
  ///
  /// [options] - `{'lang': 'amharic'}` (default) - language for holiday
  ///   names/descriptions.
  ///
  /// Returns a list of holiday entries for the current date, or an empty
  /// list if it's not a holiday.
  List<Map<String, dynamic>> isHoliday([Map<String, dynamic>? options]) {
    options ??= {};
    final lang = options['lang'] ?? 'amharic';
    final year = _ethiopian['year']!;
    final month = _ethiopian['month']!;
    final day = _ethiopian['day']!;

    final holidaysInMonth = HolidayCalculator.getHolidaysInMonth(year, month, {
      'lang': lang,
    });

    return holidaysInMonth
        .where((holiday) => holiday['ethiopian']['day'] == day)
        .toList();
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
    final intAmt = (amount).toInt();
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
    final intAmt = (amount).toInt();
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
      case 'year':
        final newDate = {'year': _ethiopian['year'], 'month': 1, 'day': 1};
        return Kenat(newDate, _time);
      case 'day':
        // Start of day is the same date with time reset to noon-day (matches
        // TS's `Time(12, 0, 'day')`, i.e. 6:00 AM Gregorian).
        final startTime = Time(12, 0, 'day');
        return Kenat({
          'year': _ethiopian['year'],
          'month': _ethiopian['month'],
          'day': _ethiopian['day'],
        }, startTime);
      default:
        throw ArgumentError('Invalid unit: $unit');
    }
  }

  /// endOf(unit) supports 'day', 'month', and 'year' and returns a new Kenat
  /// with time set to end of day (12:00 night) for `'day'`, matching the
  /// library's convention.
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
      case 'year':
        final lastDayOfPagume = EthiopianCalendarUtils.getEthiopianDaysInMonth(
          _ethiopian['year']!,
          13,
        );
        return Kenat({
          'year': _ethiopian['year'],
          'month': 13,
          'day': lastDayOfPagume,
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

  /// Generates a calendar for a given Ethiopian month and year, mapping each
  /// Ethiopian date to its corresponding Gregorian date and providing
  /// formatted display strings. This matches TS's `Kenat#getMonthCalendar`
  /// (a flat array of day objects); Dart's [getMonthCalendar] predates this
  /// port and returns a different (grid) shape existing consumers depend on,
  /// so this is exposed under a different name to avoid a breaking change.
  ///
  /// [year] - The Ethiopian year for the calendar (defaults to this
  ///   instance's year).
  /// [month] - The Ethiopian month, 1-13 (defaults to this instance's
  ///   month).
  /// [useGeez] - Whether to display dates in Geez numerals.
  ///
  /// Returns a list of maps, each `{ethiopian: {..., display}, gregorian:
  /// {..., display}}`.
  List<Map<String, dynamic>> getCalendarDays([
    int? year,
    int? month,
    bool useGeez = false,
  ]) {
    final targetYear = year ?? _ethiopian['year']!;
    final targetMonth = month ?? _ethiopian['month']!;
    final daysInMonth = EthiopianCalendarUtils.getEthiopianDaysInMonth(
      targetYear,
      targetMonth,
    );
    final calendar = <Map<String, dynamic>>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final ethDate = {'year': targetYear, 'month': targetMonth, 'day': day};
      final gregDate = Conversions.toGC(targetYear, targetMonth, day);
      calendar.add({
        'ethiopian': {
          ...ethDate,
          'display': useGeez
              ? '${MonthNames.amharic[targetMonth - 1]} ${toGeez(day)} ${toGeez(targetYear)}'
              : '${MonthNames.amharic[targetMonth - 1]} $day $targetYear',
        },
        'gregorian': {
          ...gregDate,
          'display':
              '${gregDate['year']}-${gregDate['month'].toString().padLeft(2, '0')}-${gregDate['day'].toString().padLeft(2, '0')}',
        },
      });
    }

    return calendar;
  }

  /// Prints the calendar grid for the current Ethiopian month to stdout.
  ///
  /// [useGeez] - If true, displays the calendar using Geez numerals.
  void printThisMonth([bool useGeez = false]) {
    final year = _ethiopian['year']!;
    final month = _ethiopian['month']!;
    final calendar = getCalendarDays(year, month, useGeez);
    printMonthCalendarGrid(year, month, calendar, useGeez);
  }

  /// Static equivalent of TS's `Kenat.getMonthCalendar(year, month, options)`.
  /// Named `getStaticMonthCalendar` (rather than `getMonthCalendar`) because
  /// Dart, unlike TS/JS, does not allow a static member and an instance
  /// member to share a name within the same class; the existing instance
  /// method [getMonthCalendar] predates this port and returns a different
  /// (grid) shape existing consumers depend on.
  ///
  /// [options] supports: `useGeez` (bool, default false), `weekdayLang`
  /// (String, default 'amharic'), `weekStart` (int, default 0 - matches TS's
  /// static method default, which differs from [MonthGrid]'s own default of
  /// 1), `holidayFilter` (String|List<String>?), `mode` (String?, default
  /// 'public').
  static Map<String, dynamic> getStaticMonthCalendar(
    int year,
    int month, [
    Map<String, dynamic>? options,
  ]) {
    options ??= {};
    final useGeez = options['useGeez'] ?? false;
    final weekdayLang = options['weekdayLang'] ?? 'amharic';
    final weekStart = options['weekStart'] ?? 0;
    final holidayFilter = options['holidayFilter'];
    final mode = options['mode'] ?? 'public';

    final monthGrid = MonthGrid.create({
      'year': year,
      'month': month,
      'useGeez': useGeez,
      'weekdayLang': weekdayLang,
      'weekStart': weekStart,
      'holidayFilter': holidayFilter,
      'mode': mode,
    });

    return {
      'month': month,
      'monthName': monthGrid['monthName'],
      'year': monthGrid['year'],
      'headers': monthGrid['headers'],
      'days': monthGrid['days'],
    };
  }

  /// Generates a full-year calendar as a list of month objects for the
  /// specified year. Matches TS's `Kenat.getYearCalendar(year, options)`.
  ///
  /// [options] supports: `useGeez` (bool, default false), `weekdayLang`
  /// (String, default 'amharic'), `weekStart` (int, default 0), and
  /// `holidayFilter` (String|List<String>?).
  ///
  /// Returns a list of 13 month objects, each with `month`, `monthName`,
  /// `year`, `headers`, `days`.
  static List<Map<String, dynamic>> getYearCalendar(
    int year, [
    Map<String, dynamic>? options,
  ]) {
    options ??= {};
    final useGeez = options['useGeez'] ?? false;
    final weekdayLang = options['weekdayLang'] ?? 'amharic';
    final weekStart = options['weekStart'] ?? 0;
    final holidayFilter = options['holidayFilter'];

    final fullYear = <Map<String, dynamic>>[];

    for (int month = 1; month <= 13; month++) {
      final monthGrid = MonthGrid.create({
        'year': year,
        'month': month,
        'useGeez': useGeez,
        'weekdayLang': weekdayLang,
        'weekStart': weekStart,
        'holidayFilter': holidayFilter,
      });

      fullYear.add({
        'month': month,
        'monthName': monthGrid['monthName'],
        'year': monthGrid['year'],
        'headers': monthGrid['headers'],
        'days': monthGrid['days'],
      });
    }

    return fullYear;
  }

  /// Generates a list of [Kenat] instances for a given date range, inclusive
  /// of both endpoints.
  ///
  /// [startDate] - The start of the range.
  /// [endDate] - The end of the range.
  ///
  /// Returns an empty list if [startDate] is after [endDate].
  static List<Kenat> generateDateRange(Kenat startDate, Kenat endDate) {
    final range = <Kenat>[];
    var currentDate = startDate;

    if (startDate.isAfter(endDate)) {
      return [];
    }

    while (currentDate.isBefore(endDate) || currentDate.isSameDay(endDate)) {
      range.add(currentDate);
      currentDate = currentDate.addDays(1);
    }

    return range;
  }

  // --- Distance helpers ---

  /// Returns a breakdown of distance from this date to [other].
  ///
  /// [other] - A [Kenat], a `{year, month, day}` map, a date string, or a
  ///   [DateTime].
  /// [options] supports: `units` (List<String>, default
  ///   `['years','months','days']`), `output` ('object' (default) or
  ///   'string'), `lang` ('english' (default) or 'amharic').
  ///
  /// Returns a breakdown map (see [DayArithmetic.diffBreakdown]) or, if
  /// `output: 'string'`, a formatted string (see [formatDistance]).
  dynamic distanceTo(dynamic other, [Map<String, dynamic>? options]) {
    options ??= {};
    final target = _coerceToKenat(other);
    final units =
        (options['units'] as List?)?.cast<String>() ??
        ['years', 'months', 'days'];
    final breakdown = DayArithmetic.diffBreakdown(
      target.getEthiopian(),
      getEthiopian(),
      {'units': units},
    );
    if ((options['output'] ?? 'object') == 'string') {
      return formatDistance(breakdown, options);
    }
    return breakdown;
  }

  /// Returns a breakdown of distance from today to this date.
  dynamic distanceFromToday([Map<String, dynamic>? options]) {
    final today = Kenat.now();
    return today.distanceTo(this, options);
  }

  /// Returns distance from today to the specified holiday occurrence.
  ///
  /// [holidayKey] - A holiday key (e.g. 'fasika', 'meskel').
  /// [options] supports everything [distanceTo] does, plus `direction`
  ///   ('auto' (default), 'future', or 'past').
  static dynamic distanceToHoliday(
    String holidayKey, [
    Map<String, dynamic>? options,
  ]) {
    options ??= {};
    final today = Kenat.now();
    final next = _getHolidayOccurrence(holidayKey, today.getEthiopian(), 'next');
    final prev = _getHolidayOccurrence(holidayKey, today.getEthiopian(), 'prev');
    final direction = options['direction'] ?? 'auto';

    Kenat target = next;
    if (direction == 'past') target = prev;
    if (direction == 'auto') {
      final dNext = DayArithmetic.diffInDays(
        next.getEthiopian(),
        today.getEthiopian(),
      ).abs();
      final dPrev = DayArithmetic.diffInDays(
        prev.getEthiopian(),
        today.getEthiopian(),
      ).abs();
      target = dNext <= dPrev ? next : prev;
    }

    return today.distanceTo(target, options);
  }

  /// Formats a [DayArithmetic.diffBreakdown] result to a human-friendly
  /// string like "1 year 2 months 5 days".
  static String formatDistance(
    Map<String, dynamic> breakdown, [
    Map<String, dynamic>? options,
  ]) {
    options ??= {};
    final lang = options['lang'] ?? 'english';
    final units =
        (options['units'] as List?)?.cast<String>() ??
        ['years', 'months', 'days'];
    final labelsEn = {'years': 'year', 'months': 'month', 'days': 'day'};
    final labelsAm = {'years': 'ዓመት', 'months': 'ወር', 'days': 'ቀን'};
    final labels = lang == 'amharic' ? labelsAm : labelsEn;

    String plural(int n, String k) {
      if (lang == 'amharic') return labels[k]!;
      return n == 1 ? labels[k]! : '${labels[k]}s';
    }

    final parts = <String>[];
    if (units.contains('years') && breakdown['years'] is int) {
      parts.add('${breakdown['years']} ${plural(breakdown['years'] as int, 'years')}');
    }
    if (units.contains('months') && breakdown['months'] is int) {
      parts.add('${breakdown['months']} ${plural(breakdown['months'] as int, 'months')}');
    }
    if (units.contains('days') && breakdown['days'] is int) {
      parts.add('${breakdown['days']} ${plural(breakdown['days'] as int, 'days')}');
    }

    return parts.isNotEmpty ? parts.join(' ') : '0 ${plural(0, units.last)}';
  }

  // --- internal helpers ---

  static Kenat _coerceToKenat(dynamic input) {
    if (input is Kenat) return input;
    if (input is DateTime) return Kenat(input);
    if (input is String) return Kenat(input);
    if (input is Map<String, dynamic> &&
        input.containsKey('year') &&
        input.containsKey('month') &&
        input.containsKey('day')) {
      return Kenat(input);
    }
    throw UnrecognizedInputError(input);
  }

  static Kenat _getHolidayOccurrence(
    String holidayKey,
    Map<String, dynamic> refEth,
    String which,
  ) {
    final thisYear = HolidayCalculator.getHoliday(holidayKey, refEth['year']);
    final prevYear = HolidayCalculator.getHoliday(
      holidayKey,
      refEth['year'] - 1,
    );
    final nextYear = HolidayCalculator.getHoliday(
      holidayKey,
      refEth['year'] + 1,
    );
    final candidates = [thisYear, prevYear, nextYear]
        .where((h) => h != null)
        .map((h) => Kenat(h!['ethiopian']))
        .toList();
    final ref = Kenat(refEth);

    int dist(Kenat k) =>
        DayArithmetic.diffInDays(k.getEthiopian(), ref.getEthiopian());

    final sorted = [...candidates]..sort((a, b) => dist(a) - dist(b));

    if (which == 'prev') {
      final past = candidates.where((c) => dist(c) <= 0).toList()
        ..sort((a, b) => dist(b).abs() - dist(a).abs());
      return past.isNotEmpty ? past.first : sorted.first;
    }

    final future = candidates.where((c) => dist(c) >= 0).toList()
      ..sort((a, b) => dist(a).abs() - dist(b).abs());
    return future.isNotEmpty ? future.first : sorted.first;
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

  /// Returns a plain object representation of the Kenat instance for JSON
  /// serialization.
  Map<String, dynamic> toJson() {
    return {
      'ethiopian': Map<String, dynamic>.from(_ethiopian),
      'gregorian': getGregorian(),
      'time': _time != null
          ? {'hour': _time!.hour, 'minute': _time!.minute, 'period': _time!.period}
          : null,
    };
  }

  /// Returns the bare formatted date (and time, if set) string, e.g.
  /// "መስከረም 1 2016 12:00 ጠዋት". Matches TS's `toString()`, which returns the
  /// bare formatted string (no wrapper).
  ///
  /// [calendar] - 'ethiopian' (default) or 'gregorian'.
  String toStringWithOptions({String calendar = 'ethiopian'}) {
    if (calendar == 'gregorian') {
      final gregorian = getGregorian();
      return _time != null
          ? DateFormatter.formatGregorianWithTime(gregorian, _time!)
          : DateFormatter.formatGregorianStandard(gregorian);
    }
    return _time != null
        ? DateFormatter.formatWithTime(_ethiopian, _time!)
        : DateFormatter.formatStandard(_ethiopian);
  }

  /// Returns a string representation. Matches TS's `toString()`: the bare
  /// formatted date/time string (no `Kenat(...)` wrapper). Use
  /// [toStringWithOptions] for calendar selection - Dart's `Object.toString`
  /// override cannot take parameters.
  @override
  String toString() => toStringWithOptions();

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
