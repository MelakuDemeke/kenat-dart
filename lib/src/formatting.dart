/// Date formatting functions in various styles
/// Provides different formatting options for Ethiopian dates and times
library;

import 'geez_converter.dart';
import 'constants.dart';
import 'utils.dart';
import 'time.dart';

/// Date formatting class
class DateFormatter {
  /// Formats an Ethiopian date using language-specific month name and Arabic numerals.
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  /// [lang] - Language for month name ('amharic' or 'english'). Defaults to 'amharic'.
  ///
  /// Returns formatted string like "መስከረም 10 2016".
  static String formatStandard(
    Map<String, dynamic> etDate, [
    String lang = 'amharic',
  ]) {
    final names = lang == 'english' ? MonthNames.english : MonthNames.amharic;
    final monthIndex = etDate['month']! - 1;
    final monthName = (monthIndex >= 0 && monthIndex < names.length)
        ? names[monthIndex]
        : 'Month${etDate['month']}';
    return '$monthName ${etDate['day']} ${etDate['year']}';
  }

  /// Formats an Ethiopian date in Geez numerals with Amharic month name.
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  ///
  /// Returns formatted string like "መስከረም ፲፩ ፳፻፲፮".
  static String formatInGeezAmharic(Map<String, dynamic> etDate) {
    final monthIndex = etDate['month']! - 1;
    final monthName = (monthIndex >= 0 && monthIndex < MonthNames.amharic.length)
        ? MonthNames.amharic[monthIndex]
        : 'Month${etDate['month']}';
    return '$monthName ${toGeez(etDate['day']!)} ${toGeez(etDate['year']!)}';
  }

  /// Formats an Ethiopian date and time as a string.
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  /// [time] - An instance of the Time class.
  /// [lang] - Language for suffix ('amharic' or 'english'). Defaults to 'amharic'.
  ///
  /// Returns formatted string like "መስከረም 10 2016 08:30 ጠዋት".
  static String formatWithTime(
    Map<String, dynamic> etDate,
    Time time, [
    String lang = 'amharic',
  ]) {
    final base = formatStandard(etDate, lang);

    // Ensure zeroAsDash is false for this specific format.
    final timeString = time.format({
      'lang': lang,
      'useGeez': false,
      'zeroAsDash': false,
    });

    return '$base $timeString';
  }

  /// Formats an Ethiopian date object with the weekday name, month name, day, and year.
  ///
  /// [etDate] - The Ethiopian date object to format.
  /// [lang] - The language to use for weekday and month names ('amharic', 'english', etc.).
  /// [useGeez] - Whether to format the day and year in Geez numerals.
  ///
  /// Returns formatted string like "ማክሰኞ, መስከረም 1 2016".
  static String formatWithWeekday(
    Map<String, dynamic> etDate, [
    String lang = 'amharic',
    bool useGeez = false,
  ]) {
    final weekdayIndex = getWeekday(
      etDate['year']!,
      etDate['month']!,
      etDate['day']!,
    );
    final weekdayName = lang == 'english'
        ? DaysOfWeek.english[weekdayIndex]
        : DaysOfWeek.amharic[weekdayIndex];
    final monthNames = lang == 'english'
        ? MonthNames.english
        : MonthNames.amharic;
    final monthIndex = etDate['month']! - 1;
    final monthName = (monthIndex >= 0 && monthIndex < monthNames.length)
        ? monthNames[monthIndex]
        : 'Month${etDate['month']}';
    final day = useGeez ? toGeez(etDate['day']!) : etDate['day'].toString();
    final year = useGeez ? toGeez(etDate['year']!) : etDate['year'].toString();

    return '$weekdayName, $monthName $day $year';
  }

  /// Returns Ethiopian date in short "yyyy/mm/dd" format.
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  ///
  /// Returns formatted string like "2017/10/25".
  static String formatShort(Map<String, dynamic> etDate) {
    final y = etDate['year']!.toString();
    final m = etDate['month']!.toString().padLeft(2, '0');
    final d = etDate['day']!.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  /// Returns an ISO-like string: "YYYY-MM-DD" or "YYYY-MM-DDTHH:mm".
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  /// [time] - Optional time object with hour, minute, period.
  ///
  /// Returns ISO-like formatted string.
  static String toISODateString(
    Map<String, dynamic> etDate, [
    Map<String, dynamic>? time,
  ]) {
    final y = etDate['year']!.toString();
    final m = etDate['month']!.toString().padLeft(2, '0');
    final d = etDate['day']!.toString().padLeft(2, '0');

    if (time == null) return '$y-$m-$d';

    final hr = time['hour']!.toString().padLeft(2, '0');
    final min = time['minute']!.toString().padLeft(2, '0');
    final suffix = time['period'] == 'night' ? '+12h' : '';

    return '$y-$m-${d}T$hr:$min$suffix';
  }

  /// Formats a Gregorian date using its English month name.
  ///
  /// [gDate] - Gregorian date object with year, month, day.
  ///
  /// Returns formatted string like "September 11, 2023".
  static String formatGregorianStandard(Map<String, dynamic> gDate) {
    final monthIndex = gDate['month']! - 1;
    final monthName = (monthIndex >= 0 && monthIndex < MonthNames.gregorian.length)
        ? MonthNames.gregorian[monthIndex]
        : 'Month${gDate['month']}';
    return '$monthName ${gDate['day']}, ${gDate['year']}';
  }

  /// Formats a Gregorian date object with the weekday name, month name, day, and year.
  ///
  /// [gDate] - Gregorian date object with year, month, day.
  /// [lang] - The language to use for the weekday name. Defaults to 'english'.
  ///
  /// Returns formatted string like "Monday, September 11, 2023".
  static String formatGregorianWithWeekday(
    Map<String, dynamic> gDate, [
    String lang = 'english',
  ]) {
    final date = DateTime.utc(gDate['year']!, gDate['month']!, gDate['day']!);
    final weekdayIndex = date.weekday % 7; // DateTime Monday=1..Sunday=7 -> Sunday=0
    final weekdayName = lang == 'english'
        ? DaysOfWeek.english[weekdayIndex]
        : DaysOfWeek.amharic[weekdayIndex];
    return '$weekdayName, ${formatGregorianStandard(gDate)}';
  }

  /// Formats a Gregorian date and time as a string.
  ///
  /// [gDate] - Gregorian date object with year, month, day.
  /// [time] - An instance of the Time class.
  /// [lang] - Language for the time-of-day suffix. Defaults to 'amharic'.
  ///
  /// Returns formatted string like "September 11, 2023 08:30 ጠዋት".
  static String formatGregorianWithTime(
    Map<String, dynamic> gDate,
    Time time, [
    String lang = 'amharic',
  ]) {
    final base = formatGregorianStandard(gDate);
    final timeString = time.format({
      'lang': lang,
      'useGeez': false,
      'zeroAsDash': false,
    });

    return '$base $timeString';
  }

  /// Returns a standard ISO 8601 date-time string for a Gregorian date. Unlike
  /// [toISODateString], the Ethiopian `time` (12-hour, day/night) is converted
  /// to Gregorian 24-hour time via [Time.toGregorian] and no non-standard
  /// suffix is appended, so the result is a valid ISO 8601 string.
  ///
  /// [gDate] - Gregorian date object with year, month, day.
  /// [time] - Optional Ethiopian time to convert.
  static String toGregorianISODateString(
    Map<String, dynamic> gDate, [
    Time? time,
  ]) {
    final y = gDate['year']!.toString();
    final m = gDate['month']!.toString().padLeft(2, '0');
    final d = gDate['day']!.toString().padLeft(2, '0');

    if (time == null) return '$y-$m-$d';

    final greg = time.toGregorian();
    final hr = greg['hour']!.toString().padLeft(2, '0');
    final min = greg['minute']!.toString().padLeft(2, '0');

    return '$y-$m-${d}T$hr:$min';
  }
}

/// Convenience functions that match the original JavaScript API

/// Formats an Ethiopian date using language-specific month name and Arabic numerals.
String formatStandard(Map<String, dynamic> etDate, [String lang = 'amharic']) {
  return DateFormatter.formatStandard(etDate, lang);
}

/// Formats an Ethiopian date in Geez numerals with Amharic month name.
String formatInGeezAmharic(Map<String, dynamic> etDate) {
  return DateFormatter.formatInGeezAmharic(etDate);
}

/// Formats an Ethiopian date and time as a string.
String formatWithTime(
  Map<String, dynamic> etDate,
  Time time, [
  String lang = 'amharic',
]) {
  return DateFormatter.formatWithTime(etDate, time, lang);
}

/// Formats an Ethiopian date object with the weekday name.
String formatWithWeekday(
  Map<String, dynamic> etDate, [
  String lang = 'amharic',
  bool useGeez = false,
]) {
  return DateFormatter.formatWithWeekday(etDate, lang, useGeez);
}

/// Returns Ethiopian date in short "yyyy/mm/dd" format.
String formatShort(Map<String, dynamic> etDate) {
  return DateFormatter.formatShort(etDate);
}

/// Returns an ISO-like string.
String toISODateString(
  Map<String, dynamic> etDate, [
  Map<String, dynamic>? time,
]) {
  return DateFormatter.toISODateString(etDate, time);
}

/// Formats a Gregorian date using its English month name.
String formatGregorianStandard(Map<String, dynamic> gDate) {
  return DateFormatter.formatGregorianStandard(gDate);
}

/// Formats a Gregorian date object with the weekday name.
String formatGregorianWithWeekday(
  Map<String, dynamic> gDate, [
  String lang = 'english',
]) {
  return DateFormatter.formatGregorianWithWeekday(gDate, lang);
}

/// Formats a Gregorian date and time as a string.
String formatGregorianWithTime(
  Map<String, dynamic> gDate,
  Time time, [
  String lang = 'amharic',
]) {
  return DateFormatter.formatGregorianWithTime(gDate, time, lang);
}

/// Returns a standard ISO 8601 date-time string for a Gregorian date.
String toGregorianISODateString(Map<String, dynamic> gDate, [Time? time]) {
  return DateFormatter.toGregorianISODateString(gDate, time);
}
