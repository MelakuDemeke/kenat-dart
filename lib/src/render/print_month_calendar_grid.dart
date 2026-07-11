/// Console ASCII calendar grid printer
///
/// Port of kenat's `render/printMonthCalendarGrid.ts`: prints a simple
/// month grid (Ethiopian day / Gregorian day per cell) to stdout.
library;

import '../constants.dart';
import '../geez_converter.dart';
import '../utils.dart';
import '../errors/error_handler.dart';

/// Prints an ASCII calendar grid for an Ethiopian month to stdout.
///
/// [ethiopianYear] - The Ethiopian year being printed (used only for the
///   header line).
/// [ethiopianMonth] - The Ethiopian month, 1-13 (used only for the header
///   line and validation).
/// [calendarData] - A list of day maps, each shaped like
///   `{'ethiopian': {'day': ...}, 'gregorian': {'year': ..., 'month': ...,
///   'day': ...}}` - the shape returned by `Kenat#getCalendarDays`.
/// [useGeez] - If true, renders the Ethiopian day numbers (and year in the
///   header) using Geez numerals.
void printMonthCalendarGrid(
  int ethiopianYear,
  int ethiopianMonth,
  List<Map<String, dynamic>> calendarData, [
  bool useGeez = false,
]) {
  validateNumericInputs('printMonthCalendarGrid', {
    'ethiopianYear': ethiopianYear,
    'ethiopianMonth': ethiopianMonth,
  });
  if (ethiopianMonth < 1 || ethiopianMonth > 13) {
    throw InvalidInputTypeError(
      'printMonthCalendarGrid',
      'ethiopianMonth',
      'number between 1 and 13',
      ethiopianMonth,
    );
  }
  if (calendarData.isEmpty) {
    // This function would crash if calendarData is empty, so we check it.
    // ignore: avoid_print
    print('Calendar data is empty or invalid. Cannot print grid.');
    return;
  }

  const daysOfWeekShort = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.writeln(
    '   ${MonthNames.amharic[ethiopianMonth - 1]} ${useGeez ? toGeez(ethiopianYear) : ethiopianYear}',
  );
  buffer.writeln(daysOfWeekShort.join('  '));

  final firstDayGregorian =
      calendarData[0]['gregorian'] as Map<String, dynamic>;
  final jsDate = DateTime(
    firstDayGregorian['year'] as int,
    firstDayGregorian['month'] as int,
    firstDayGregorian['day'] as int,
  );
  // DateTime.weekday: Monday=1..Sunday=7 -> shift so Monday=0..Sunday=6.
  final weekDay = (jsDate.weekday - 1) % 7;

  var row = List<String>.filled(weekDay, '    ', growable: true);

  for (final day in calendarData) {
    final eth = day['ethiopian'] as Map<String, dynamic>;
    final greg = day['gregorian'] as Map<String, dynamic>;
    final ethDayNum = eth['day'];
    final ethDay = useGeez
        ? toGeez(ethDayNum).padLeft(2, '፩')
        : ethDayNum.toString().padLeft(2, ' ');
    final gregDay = greg['day'].toString().padLeft(2, ' ');
    row.add('$ethDay/$gregDay');

    if (row.length == 7) {
      buffer.writeln(row.join(' '));
      row = [];
    }
  }

  if (row.isNotEmpty) {
    buffer.writeln(row.join(' ').padRight(27));
  }

  // ignore: avoid_print
  print(buffer.toString().trimRight());
}
