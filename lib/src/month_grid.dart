/// Calendar grid generation for months
/// Creates calendar grids with holidays, saints, and various display options
library;

import 'conversions.dart';
import 'holidays.dart';
import 'geez_converter.dart';
import 'constants.dart';
import 'utils.dart';
import 'errors/error_handler.dart';
import 'saints.dart';

/// MonthGrid class for generating calendar grids
class MonthGrid {
  late int year;
  late int month;
  late int weekStart;
  late bool useGeez;
  late String weekdayLang;
  late List<String>? holidayFilter;
  late String? mode;
  late bool showAllSaints;

  /// Constructor for MonthGrid
  ///
  /// [config] - Configuration options for the grid.
  MonthGrid([Map<String, dynamic>? config]) {
    config ??= {};
    _validateConfig(config);

    final current = DateTime.now();
    final currentEthiopian = Conversions.toEC(
      current.year,
      current.month,
      current.day,
    );

    year = config['year'] ?? currentEthiopian['year']!;
    month = config['month'] ?? currentEthiopian['month']!;
    weekStart = config['weekStart'] ?? 0;
    useGeez = config['useGeez'] ?? false;
    weekdayLang = config['weekdayLang'] ?? 'amharic';
    holidayFilter = config['holidayFilter'];
    mode = config['mode'];
    showAllSaints = config['showAllSaints'] ?? false;
  }

  /// Validates the configuration parameters
  void _validateConfig(Map<String, dynamic> config) {
    final year = config['year'];
    final month = config['month'];
    final weekStart = config['weekStart'];
    final weekdayLang = config['weekdayLang'];

    if ((year != null && month == null) || (year == null && month != null)) {
      throw InvalidGridConfigError(
        'If providing year or month, both must be provided.',
      );
    }
    if (year != null) {
      validateNumericInputs('MonthGrid.constructor', {'year': year});
    }
    if (month != null) {
      validateNumericInputs('MonthGrid.constructor', {'month': month});
    }
    if (weekStart != null) {
      validateNumericInputs('MonthGrid.constructor', {'weekStart': weekStart});
      if (weekStart < 0 || weekStart > 6) {
        throw InvalidGridConfigError(
          'Invalid weekStart value: $weekStart. Must be between 0 and 6.',
        );
      }
    }
    if (weekdayLang != null) {
      if (weekdayLang is! String ||
          !['amharic', 'english'].contains(weekdayLang)) {
        // Instead of throwing, default to 'amharic' to be more forgiving and
        // match expected JS behavior in tests that pass an invalid weekdayLang.
        config['weekdayLang'] = 'amharic';
      }
    }
  }

  /// Creates a new MonthGrid instance and generates the grid
  static Map<String, dynamic> create([Map<String, dynamic>? config]) {
    final instance = MonthGrid(config);
    return instance.generate();
  }

  /// Generates the calendar grid
  Map<String, dynamic> generate() {
    final rawDays = _getRawDays();
    final holidays = _getFilteredHolidays();
    final saints = _getSaintsMap();
    final paddedDays = _mergeDays(rawDays, holidays, saints);
    final headers = _getWeekdayHeaders();
    final monthName = _getLocalizedMonthName();
    final yearLabel = _getLocalizedYear();

    return {
      'headers': headers,
      'days': paddedDays,
      'year': yearLabel,
      'month': month,
      'monthName': monthName,
      'up': () => up().generate(),
      'down': () => down().generate(),
    };
  }

  /// Gets raw days for the month
  List<Map<String, dynamic>> _getRawDays() {
    final daysInMonth = EthiopianCalendarUtils.getEthiopianDaysInMonth(
      year,
      month,
    );
    final days = <Map<String, dynamic>>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final ethiopian = {'year': year, 'month': month, 'day': day};
      final gregorian = Conversions.toGC(year, month, day);
      days.add({'ethiopian': ethiopian, 'gregorian': gregorian});
    }

    return days;
  }

  /// Gets filtered holidays for the month
  List<Map<String, dynamic>> _getFilteredHolidays() {
    List<String>? filter = holidayFilter;
    if (mode == 'christian') filter = [HolidayTags.christian];
    if (mode == 'orthodox') filter = [HolidayTags.orthodox, HolidayTags.christian];
    if (mode == 'muslim') filter = [HolidayTags.muslim];
    if (mode == 'public') filter = [HolidayTags.public];

    return HolidayCalculator.getHolidaysInMonth(year, month, {
      'lang': weekdayLang,
      'filter': filter,
    });
  }

  /// Gets saints map for the month
  Map<int, List<Map<String, dynamic>>> _getSaintsMap() {
    if (mode != 'christian' && mode != 'orthodox') return {};
    return OrthodoxSaints.getSaintsForMonth(month, weekdayLang);
  }

  /// Merges days with holidays and saints
  List<Map<String, dynamic>?> _mergeDays(
    List<Map<String, dynamic>> rawDays,
    List<Map<String, dynamic>> holidaysList,
    Map<int, List<Map<String, dynamic>>> saintsMap,
  ) {
    final today = DateTime.now();
    final todayEthiopian = Conversions.toEC(today.year, today.month, today.day);

    final labels = weekdayLang == 'english'
        ? DaysOfWeek.english
        : DaysOfWeek.amharic;
    final monthLabels = weekdayLang == 'english'
        ? MonthNames.english
        : MonthNames.amharic;

    final holidayMap = <String, List<Map<String, dynamic>>>{};
    for (final h in holidaysList) {
      final key =
          '${h['ethiopian']['year']}-${h['ethiopian']['month']}-${h['ethiopian']['day']}';
      holidayMap.putIfAbsent(key, () => []).add(h);
    }

    final mapped = rawDays.map((day) {
      final eth = day['ethiopian'];
      final greg = day['gregorian'];
      final weekday = getWeekday(eth['year']!, eth['month']!, eth['day']!);
      final key = '${eth['year']}-${eth['month']}-${eth['day']}';
      List<Map<String, dynamic>> holidays = holidayMap[key] ?? [];

      if (mode == 'christian' || mode == 'orthodox') {
        holidays = [...holidays, ...(saintsMap[eth['day']] ?? [])];
      }

      if (mode == 'muslim' && weekday == 5) {
        final j = Holidays.jummah;
        holidays.add({
          'key': 'jummah',
          'name': j.name[weekdayLang] ?? j.name['english'],
          'description': j.description[weekdayLang] ?? j.description['english'],
          'tags': [HolidayTags.religious, HolidayTags.muslim],
        });
      }

      return {
        'ethiopian': {
          'year': useGeez ? toGeez(eth['year']) : eth['year'],
          'month': useGeez ? monthLabels[eth['month'] - 1] : eth['month'],
          'day': useGeez ? toGeez(eth['day']) : eth['day'],
        },
        'gregorian': greg,
        'weekday': weekday,
        'weekdayName': labels[weekday],
        'isToday':
            eth['year'] == todayEthiopian['year'] &&
            eth['month'] == todayEthiopian['month'] &&
            eth['day'] == todayEthiopian['day'],
        'holidays': holidays,
      };
    }).toList();

    // Add padding for proper calendar grid alignment
    final firstDayWeekday = mapped.isNotEmpty ? mapped.first['weekday'] : 0;
    final offset = ((firstDayWeekday - weekStart + 7) % 7);
    final padded = List<Map<String, dynamic>?>.filled(
      offset,
      null,
      growable: true,
    );
    padded.addAll(mapped);

    return padded;
  }

  /// Gets weekday headers
  List<String> _getWeekdayHeaders() {
    final labels = weekdayLang == 'english'
        ? DaysOfWeek.english
        : DaysOfWeek.amharic;
    final result = <String>[];
    result.addAll(labels.sublist(weekStart));
    result.addAll(labels.sublist(0, weekStart));
    return result;
  }

  /// Gets localized month name
  String _getLocalizedMonthName() {
    final labels = weekdayLang == 'english'
        ? MonthNames.english
        : MonthNames.amharic;
    return labels[month - 1];
  }

  /// Gets localized year
  String _getLocalizedYear() {
    return useGeez ? toGeez(year) : year.toString();
  }

  /// Moves to the next month
  MonthGrid up() {
    if (month == 13) {
      month = 1;
      year++;
    } else {
      month++;
    }
    return this;
  }

  /// Moves to the previous month
  MonthGrid down() {
    if (month == 1) {
      month = 13;
      year--;
    } else {
      month--;
    }
    return this;
  }
}

/// Convenience function to create a MonthGrid
Map<String, dynamic> createMonthGrid([Map<String, dynamic>? config]) {
  return MonthGrid.create(config);
}
