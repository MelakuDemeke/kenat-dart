/// Holiday calculations and saint commemorations
/// Handles fixed and movable holidays, Islamic holidays, and saint days

import 'conversions.dart';
import 'constants.dart';
import 'utils.dart';
import 'errors/error_handler.dart';
import 'bahire_hasab.dart';

/// Fixed holidays with their Ethiopian calendar dates
// Reuse constants defined in constants.dart (holidayInfo, HolidayTags, etc.)
// Keep a local fixedHolidays map for quick lookup consistent with JS implementation
class FixedHolidays {
  static const Map<String, Map<String, dynamic>> holidays = {
    'enkutatash': {
      'month': 1,
      'day': 1,
      'tags': [HolidayTags.public, HolidayTags.cultural],
    },
    'meskel': {
      'month': 1,
      'day': 17,
      'tags': [
        HolidayTags.public,
        HolidayTags.religious,
        HolidayTags.christian,
      ],
    },
    'beherbehereseb': {
      'month': 3,
      'day': 29,
      'tags': [HolidayTags.public, HolidayTags.state],
    },
    'gena': {
      'month': 4,
      'day': 29,
      'tags': [
        HolidayTags.public,
        HolidayTags.religious,
        HolidayTags.christian,
      ],
    },
    'timket': {
      'month': 5,
      'day': 11,
      'tags': [
        HolidayTags.public,
        HolidayTags.religious,
        HolidayTags.christian,
      ],
    },
    'martyrsDay': {
      'month': 6,
      'day': 12,
      'tags': [HolidayTags.public, HolidayTags.state],
    },
    'adwa': {
      'month': 6,
      'day': 23,
      'tags': [HolidayTags.public, HolidayTags.state],
    },
    'labour': {
      'month': 8,
      'day': 23,
      'tags': [HolidayTags.public, HolidayTags.state],
    },
    'patriots': {
      'month': 8,
      'day': 27,
      'tags': [HolidayTags.public, HolidayTags.state],
    },
  };
}

/// Holiday calculation class
class HolidayCalculator {
  /// Finds all Islamic holiday occurrences within an Ethiopian year
  static List<Map<String, dynamic>> findAllIslamicOccurrences(
    int ethiopianYear,
    int hijriMonth,
    int hijriDay,
  ) {
    final startGregorianYear = Conversions.toGC(ethiopianYear, 1, 1)['year']!;
    final endGregorianYear = Conversions.toGC(ethiopianYear, 13, 5)['year']!;
    final occurrences = <Map<String, dynamic>>[];

    void checkGregorianYear(int gYear) {
      final hijriYearAtStart = IslamicConversions.getHijriYear(
        DateTime(gYear, 1, 1),
      );
      final hijriYearsToCheck = [hijriYearAtStart, hijriYearAtStart + 1];

      for (final hYear in hijriYearsToCheck) {
        final gregorianDate = IslamicConversions.hijriToGregorian(
          hYear,
          hijriMonth,
          hijriDay,
          gYear,
        );
        if (gregorianDate != null && gregorianDate.year == gYear) {
          final ecDate = Conversions.toEC(
            gregorianDate.year,
            gregorianDate.month,
            gregorianDate.day,
          );

          // Check previous day only if needed: if the current mapping's
          // Ethiopian year is not the target but the previous day's is,
          // prefer the previous day. This avoids shifting occurrences like
          // Moulid that are already correctly aligned.
          final prev = DateTime(
            gregorianDate.year,
            gregorianDate.month,
            gregorianDate.day,
          ).subtract(const Duration(days: 1));
          final prevEc = Conversions.toEC(prev.year, prev.month, prev.day);

          if (ecDate['year'] == ethiopianYear) {
            // Current mapping already falls within the target Ethiopian year;
            // prefer it. Only prefer the previous Gregorian day when the
            // current mapping's Ethiopian year does NOT match the target but
            // the previous day's mapping does. This mirrors the original JS
            // library behavior.
            occurrences.add({
              'gregorian': {
                'year': gregorianDate.year,
                'month': gregorianDate.month,
                'day': gregorianDate.day,
              },
              'ethiopian': ecDate,
            });
          } else if (prevEc['year'] == ethiopianYear) {
            occurrences.add({
              'gregorian': {
                'year': prev.year,
                'month': prev.month,
                'day': prev.day,
              },
              'ethiopian': prevEc,
            });
          }
        }
      }
    }

    checkGregorianYear(startGregorianYear);
    if (startGregorianYear != endGregorianYear) {
      checkGregorianYear(endGregorianYear);
    }

    // Remove duplicates based on Ethiopian date
    final uniqueOccurrences = <String, Map<String, dynamic>>{};
    for (final occurrence in occurrences) {
      final key =
          '${occurrence['ethiopian']['year']}/${occurrence['ethiopian']['month']}/${occurrence['ethiopian']['day']}';
      uniqueOccurrences[key] = occurrence;
    }

    return uniqueOccurrences.values.toList();
  }

  /// Finds the start and end dates of a specific Hijri month that falls within an Ethiopian year
  static List<Map<String, dynamic>> findHijriMonthRanges(
    int ethiopianYear,
    int hijriMonth,
  ) {
    final startGregorianYear = Conversions.toGC(ethiopianYear, 1, 1)['year']!;
    final endGregorianYear = Conversions.toGC(ethiopianYear, 13, 5)['year']!;
    final ranges = <Map<String, dynamic>>[];

    void findRangeInGregorianYear(int gYear) {
      final hijriYearAtStart = IslamicConversions.getHijriYear(
        DateTime(gYear, 1, 1),
      );
      final hijriYearsToCheck = [
        hijriYearAtStart - 1,
        hijriYearAtStart,
        hijriYearAtStart + 1,
      ];

      for (final hYear in hijriYearsToCheck) {
        final startDateGregorian = IslamicConversions.hijriToGregorian(
          hYear,
          hijriMonth,
          1,
          gYear,
        );
        if (startDateGregorian == null) continue;

        final nextMonth = hijriMonth == 12 ? 1 : hijriMonth + 1;
        final nextYear = hijriMonth == 12 ? hYear + 1 : hYear;
        DateTime? endDateGregorian;

        final endDateCandidate =
            IslamicConversions.hijriToGregorian(
              nextYear,
              nextMonth,
              1,
              gYear,
            ) ??
            IslamicConversions.hijriToGregorian(
              nextYear,
              nextMonth,
              1,
              gYear + 1,
            );

        if (endDateCandidate != null) {
          endDateGregorian = DateTime(
            endDateCandidate.year,
            endDateCandidate.month,
            endDateCandidate.day,
          ).subtract(const Duration(days: 1));
        } else {
          continue;
        }

        final startEC = Conversions.toEC(
          startDateGregorian.year,
          startDateGregorian.month,
          startDateGregorian.day,
        );
        final endEC = Conversions.toEC(
          endDateGregorian.year,
          endDateGregorian.month,
          endDateGregorian.day,
        );

        if (startEC['year'] == ethiopianYear ||
            endEC['year'] == ethiopianYear) {
          ranges.add({'start': startEC, 'end': endEC});
        }
      }
    }

    findRangeInGregorianYear(startGregorianYear);
    if (startGregorianYear != endGregorianYear) {
      findRangeInGregorianYear(endGregorianYear);
    }

    // Remove duplicates
    final uniqueRanges = <String, Map<String, dynamic>>{};
    for (final range in ranges) {
      final key =
          '${range['start']['year']}/${range['start']['month']}/${range['start']['day']}';
      uniqueRanges[key] = range;
    }

    return uniqueRanges.values.toList();
  }

  /// Gets all Moulid dates for a year
  static List<Map<String, dynamic>> getAllMoulidDates(int year) {
    return findAllIslamicOccurrences(year, 3, 12);
  }

  /// Gets all Eid al-Fitr dates for a year
  static List<Map<String, dynamic>> getAllEidFitrDates(int year) {
    return findAllIslamicOccurrences(year, 10, 1);
  }

  /// Gets all Eid al-Adha dates for a year
  static List<Map<String, dynamic>> getAllEidAdhaDates(int year) {
    return findAllIslamicOccurrences(year, 12, 10);
  }

  /// Gets a specific holiday for a given year
  static Map<String, dynamic>? getHoliday(
    String holidayKey,
    dynamic ethYear, [
    Map<String, dynamic>? options,
  ]) {
    validateNumericInputs('getHoliday', {'ethYear': ethYear});
    final intYear = ethYear as int;
    options ??= {};
    final lang = options['lang'] ?? 'amharic';

    final holidayInfo = Holidays.getHolidayInfo(holidayKey);
    if (holidayInfo == null) return null;

    final name = holidayInfo['name']?[lang] ?? holidayInfo['name']?['english'];
    final description =
        holidayInfo['description']?[lang] ??
        holidayInfo['description']?['english'];

    // Check fixed holidays
    if (FixedHolidays.holidays.containsKey(holidayKey)) {
      final rules = FixedHolidays.holidays[holidayKey]!;
      return {
        'key': holidayKey,
        'tags': rules['tags'],
        'movable': false,
        'name': name,
        'description': description,
        'ethiopian': {
          'year': intYear,
          'month': rules['month'],
          'day': rules['day'],
        },
      };
    }

    // Check movable Christian holidays
    final tewsakKey = _keyToTewsakMap[holidayKey];
    if (tewsakKey != null) {
      final date = BahireHasab.getMovableHoliday(tewsakKey, ethYear);
      return {
        'key': holidayKey,
        'tags': MovableHolidays.tags[holidayKey] ?? [],
        'movable': true,
        'name': name,
        'description': description,
        'ethiopian': date,
        'gregorian': Conversions.toGC(
          date['year']!,
          date['month']!,
          date['day']!,
        ),
      };
    }

    // Check Islamic holidays
    List<Map<String, dynamic>> muslimDateData;
    switch (holidayKey) {
      case 'eidFitr':
        muslimDateData = getAllEidFitrDates(ethYear);
        break;
      case 'eidAdha':
        muslimDateData = getAllEidAdhaDates(ethYear);
        break;
      case 'moulid':
        muslimDateData = getAllMoulidDates(ethYear);
        break;
      default:
        muslimDateData = [];
    }

    if (muslimDateData.isNotEmpty) {
      final data = muslimDateData.first;
      return {
        'key': holidayKey,
        'tags': MovableHolidays.tags[holidayKey] ?? [],
        'movable': true,
        'name': name,
        'description': description,
        'ethiopian': data['ethiopian'],
        'gregorian': data['gregorian'],
      };
    }

    return null;
  }

  /// Gets all holidays in a specific month
  static List<Map<String, dynamic>> getHolidaysInMonth(
    dynamic ethYear,
    dynamic ethMonth, [
    Map<String, dynamic>? options,
  ]) {
    // Validate types inside the function to match JS behavior
    validateNumericInputs('getHolidaysInMonth', {
      'ethYear': ethYear,
      'ethMonth': ethMonth,
    });

    final intYear = ethYear as int;
    final intMonth = ethMonth as int;

    if (intMonth < 1 || intMonth > 13) {
      throw InvalidInputTypeError(
        'getHolidaysInMonth',
        'ethMonth',
        'number between 1 and 13',
        ethMonth,
      );
    }
    options ??= {};
    final lang = options['lang'] ?? 'amharic';
    final filter = options['filter'];

    final allHolidaysForMonth = <Map<String, dynamic>>[];
    final allHolidayKeys = Holidays.allKeys;

    for (final key in allHolidayKeys) {
      final holiday = getHoliday(key, intYear, {'lang': lang});
      if (holiday != null && holiday['ethiopian']['month'] == intMonth) {
        allHolidaysForMonth.add(holiday);
      }
    }

    // Handle cases where Islamic holidays occur twice
    final muslimHolidays = <Map<String, dynamic>>[];
    muslimHolidays.addAll(
      getAllMoulidDates(ethYear).map((d) => {...d, 'key': 'moulid'}),
    );
    muslimHolidays.addAll(
      getAllEidFitrDates(ethYear).map((d) => {...d, 'key': 'eidFitr'}),
    );
    muslimHolidays.addAll(
      getAllEidAdhaDates(ethYear).map((d) => {...d, 'key': 'eidAdha'}),
    );

    for (final data in muslimHolidays) {
      if (data['ethiopian']['month'] == intMonth) {
        final holidayInfo = Holidays.getHolidayInfo(data['key']);
        final holidayObj = {
          'key': data['key'],
          'tags': MovableHolidays.tags[data['key']] ?? [],
          'movable': true,
          'name':
              holidayInfo?['name']?[lang] ?? holidayInfo?['name']?['english'],
          'description':
              holidayInfo?['description']?[lang] ??
              holidayInfo?['description']?['english'],
          'ethiopian': data['ethiopian'],
          'gregorian': data['gregorian'],
        };

        // Avoid duplicates
        final isDuplicate = allHolidaysForMonth.any(
          (h) =>
              h['ethiopian']['year'] == holidayObj['ethiopian']['year'] &&
              h['ethiopian']['month'] == holidayObj['ethiopian']['month'] &&
              h['ethiopian']['day'] == holidayObj['ethiopian']['day'],
        );

        if (!isDuplicate) {
          allHolidaysForMonth.add(holidayObj);
        }
      }
    }

    // Apply filter if provided
    if (filter != null) {
      final filterTags = filter is List ? filter : [filter];
      allHolidaysForMonth.removeWhere((holiday) {
        final holidayTags = holiday['tags'] as List<String>? ?? [];
        return !holidayTags.any((tag) => filterTags.contains(tag));
      });
    }

    // Sort by day
    allHolidaysForMonth.sort(
      (a, b) => a['ethiopian']['day'] - b['ethiopian']['day'],
    );
    return allHolidaysForMonth;
  }

  /// Gets all holidays for a year
  static List<Map<String, dynamic>> getHolidaysForYear(
    int ethYear, [
    Map<String, dynamic>? options,
  ]) {
    validateNumericInputs('getHolidaysForYear', {'ethYear': ethYear});
    options ??= {};
    final lang = options['lang'] ?? 'amharic';
    final filter = options['filter'];

    final allHolidaysForYear = <Map<String, dynamic>>[];

    // Process all fixed and Christian movable holidays
    final singleOccurrenceKeys = [
      ...FixedHolidays.holidays.keys,
      ..._keyToTewsakMap.keys,
    ];

    for (final key in singleOccurrenceKeys) {
      final holiday = getHoliday(key, ethYear, {'lang': lang});
      if (holiday != null) {
        allHolidaysForYear.add(holiday);
      }
    }

    // Process all occurrences of Islamic holidays
    void addMuslimHolidays(String key, List<Map<String, dynamic>> dateArray) {
      for (final data in dateArray) {
        final holidayInfo = Holidays.getHolidayInfo(key);
        allHolidaysForYear.add({
          'key': key,
          'tags': MovableHolidays.tags[key] ?? [],
          'movable': true,
          'name':
              holidayInfo?['name']?[lang] ?? holidayInfo?['name']?['english'],
          'description':
              holidayInfo?['description']?[lang] ??
              holidayInfo?['description']?['english'],
          'ethiopian': data['ethiopian'],
          'gregorian': data['gregorian'],
        });
      }
    }

    addMuslimHolidays('moulid', getAllMoulidDates(ethYear));
    addMuslimHolidays('eidFitr', getAllEidFitrDates(ethYear));
    addMuslimHolidays('eidAdha', getAllEidAdhaDates(ethYear));

    // Apply filter if provided
    if (filter != null) {
      final filterTags = filter is List ? filter : [filter];
      allHolidaysForYear.removeWhere((holiday) {
        final holidayTags = holiday['tags'] as List<String>? ?? [];
        return !holidayTags.any((tag) => filterTags.contains(tag));
      });
    }

    // Sort by month and day
    allHolidaysForYear.sort((a, b) {
      if (a['ethiopian']['month'] != b['ethiopian']['month']) {
        return a['ethiopian']['month'] - b['ethiopian']['month'];
      }
      return a['ethiopian']['day'] - b['ethiopian']['day'];
    });

    return allHolidaysForYear;
  }
}

/// Key to tewsak mapping for movable holidays
const Map<String, String> _keyToTewsakMap = {
  'nineveh': 'NINEVEH',
  'abiyTsome': 'ABIY_TSOME',
  'debreZeit': 'DEBRE_ZEIT',
  'hosanna': 'HOSANNA',
  'siklet': 'SIKLET',
  'fasika': 'TINSAYE',
  'rikbeKahnat': 'RIKBE_KAHNAT',
  'erget': 'ERGET',
  'paraclete': 'PARACLETE',
  'tsomeHawaryat': 'TSOME_HAWARYAT',
  'tsomeDihnet': 'TSOME_DIHENET',
};

/// Convenience functions that match the original JavaScript API

/// Gets a specific holiday for a given year
Map<String, dynamic>? getHoliday(
  String holidayKey,
  dynamic ethYear, [
  Map<String, dynamic>? options,
]) {
  return HolidayCalculator.getHoliday(holidayKey, ethYear, options);
}

/// Gets all holidays in a specific month
List<Map<String, dynamic>> getHolidaysInMonth(
  dynamic ethYear,
  dynamic ethMonth, [
  Map<String, dynamic>? options,
]) {
  return HolidayCalculator.getHolidaysInMonth(ethYear, ethMonth, options);
}

/// Gets all holidays for a year
List<Map<String, dynamic>> getHolidaysForYear(
  int ethYear, [
  Map<String, dynamic>? options,
]) {
  return HolidayCalculator.getHolidaysForYear(ethYear, options);
}

/// Finds the start and end dates of a specific Hijri month within an Ethiopian year
List<Map<String, dynamic>> findHijriMonthRanges(
  int ethiopianYear,
  int hijriMonth,
) {
  return HolidayCalculator.findHijriMonthRanges(ethiopianYear, hijriMonth);
}
