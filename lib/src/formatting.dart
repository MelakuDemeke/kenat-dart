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
    final monthName = names[etDate['month']! - 1];
    return '$monthName ${etDate['day']} ${etDate['year']}';
  }

  /// Formats an Ethiopian date in Geez numerals with Amharic month name.
  ///
  /// [etDate] - Ethiopian date object with year, month, day.
  ///
  /// Returns formatted string like "መስከረም ፲፩ ፳፻፲፮".
  static String formatInGeezAmharic(Map<String, dynamic> etDate) {
    final monthName = MonthNames.amharic[etDate['month']! - 1];
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
    final monthName = lang == 'english'
        ? MonthNames.english[etDate['month']! - 1]
        : MonthNames.amharic[etDate['month']! - 1];
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
