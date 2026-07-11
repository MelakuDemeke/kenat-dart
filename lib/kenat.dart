/// A comprehensive Ethiopian calendar library for Dart/Flutter
///
/// This library provides full support for Ethiopian calendar operations including:
/// - Date conversions between Ethiopian and Gregorian calendars
/// - Holiday calculations (fixed and movable)
/// - Fasting period calculations
/// - Bahire Hasab calculations
/// - Date formatting in various styles
/// - Calendar grid generation
/// - Ethiopian time system with day/night periods
/// - Geez numeral conversion
///
/// Example usage:
/// ```dart
/// import 'package:kenat/kenat.dart';
///
/// void main() {
///   // Create a Kenat instance from current date
///   final now = Kenat.now();
///   print(now.formatStandard()); // "መስከረም 10 2016"
///
///   // Create from Ethiopian date
///   final ethiopianDate = Kenat.fromEthiopian(2016, 1, 10);
///   print(ethiopianDate.getGregorian()); // {year: 2023, month: 9, day: 17}
///
///   // Get holidays for current month
///   final holidays = now.getHolidaysInMonth();
///   print(holidays.length); // Number of holidays this month
///
///   // Format with Geez numerals
///   print(now.formatInGeez()); // "መስከረም ፲፩ ፳፻፲፮"
/// }
/// ```
library;

// Core classes
export 'src/kenat.dart';
export 'src/time.dart';

// Utility classes
export 'src/constants.dart';
export 'src/utils.dart';
export 'src/conversions.dart';
export 'src/geez_converter.dart';
export 'src/day_arithmetic.dart';

// Calendar calculations
export 'src/bahire_hasab.dart';
export 'src/holidays.dart';
export 'src/fasting.dart';
export 'src/saints.dart' show OrthodoxSaints;

// Formatting and display
export 'src/formatting.dart';
export 'src/month_grid.dart';
export 'src/render/print_month_calendar_grid.dart';

// Error handling
export 'src/errors/error_handler.dart';

// Convenience exports for commonly used functions
export 'src/conversions.dart' show toGC, toEC;
export 'src/geez_converter.dart' show toGeez, toArabic;
export 'src/day_arithmetic.dart'
    show addDays, addMonths, addYears, diffInDays, diffInMonths, diffInYears;
export 'src/bahire_hasab.dart' show getBahireHasab, getMovableHoliday;
export 'src/holidays.dart'
    show getHoliday, getHolidaysInMonth, getHolidaysForYear;
export 'src/fasting.dart'
    show getFastingPeriod, getFastingInfo, isTsomeDihnetFastDay;
export 'src/formatting.dart'
    show
        formatStandard,
        formatInGeezAmharic,
        formatWithTime,
        formatWithWeekday,
        formatShort,
        formatGregorianStandard,
        formatGregorianWithWeekday,
        formatGregorianWithTime,
        toGregorianISODateString;
export 'src/month_grid.dart' show createMonthGrid;
