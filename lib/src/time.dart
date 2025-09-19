/// Ethiopian time system class with day/night periods
/// Handles 12-hour Ethiopian time format with day and night periods

import 'geez_converter.dart';
import 'constants.dart';
import 'errors/error_handler.dart';
import 'utils.dart';

/// Ethiopian time class that handles 12-hour time format with day/night periods
class Time {
  final int hour;
  final int minute;
  final String period;

  // Private generative constructor used by the public factory.
  Time._(this.hour, this.minute, this.period);

  /// Constructs a Time instance representing an Ethiopian time.
  /// Accepts dynamic inputs to mimic JS flexibility; validates and casts internally.
  factory Time(
    dynamic hourInput, [
    dynamic minuteInput = 0,
    dynamic periodInput = 'day',
  ]) {
    // Validate that numeric parts are numbers
    try {
      validateNumericInputs('Time.constructor', {
        'hour': hourInput,
        'minute': minuteInput,
      });
    } catch (e) {
      rethrow;
    }

    int h;
    int m;
    String p;
    try {
      h = (hourInput as num).toInt();
      m = (minuteInput as num).toInt();
      p = (periodInput is String) ? periodInput : periodInput.toString();
    } on TypeError catch (_) {
      throw InvalidInputTypeError(
        'Time.constructor',
        'hour/minute',
        'number',
        hourInput,
      );
    }

    if (h < 1 || h > 12) {
      throw InvalidTimeError(
        'Invalid Ethiopian hour: $h. Must be between 1 and 12.',
      );
    }
    if (m < 0 || m > 59) {
      throw InvalidTimeError('Invalid minute: $m. Must be between 0 and 59.');
    }
    if (p != 'day' && p != 'night') {
      throw InvalidTimeError(
        'Invalid period: "$p". Must be \'day\' or \'night\'.',
      );
    }

    return Time._(h, m, p);
  }

  /// Creates a Time instance from a Gregorian 24-hour time.
  ///
  /// [hour] - The Gregorian hour (0-23).
  /// [minute] - The minute (0-59). Defaults to 0.
  ///
  /// Returns a new Time instance.
  /// Throws [InvalidTimeError] If the Gregorian time is invalid.
  static Time fromGregorian(int hour, [int minute = 0]) {
    validateNumericInputs('Time.fromGregorian', {
      'hour': hour,
      'minute': minute,
    });

    if (hour < 0 || hour > 23) {
      throw InvalidTimeError(
        'Invalid Gregorian hour: $hour. Must be between 0 and 23.',
      );
    }
    if (minute < 0 || minute > 59) {
      throw InvalidTimeError(
        'Invalid minute: $minute. Must be between 0 and 59.',
      );
    }

    // Normalize Gregorian hour to an Ethiopian base (where 6 AM is 0)
    int tempHour = hour - 6;
    if (tempHour < 0) {
      tempHour += 24;
    }

    final period = (tempHour < 12) ? 'day' : 'night';
    int ethHour = tempHour % 12;
    ethHour = (ethHour == 0) ? 12 : ethHour;

    return Time(ethHour, minute, period);
  }

  /// Converts the Ethiopian time to Gregorian 24-hour format.
  ///
  /// Returns a map with hour and minute keys.
  Map<String, int> toGregorian() {
    // Convert Ethiopian 1-12 hour to a 0-11 offset, where 12 o'clock is 0.
    int gregHour = hour % 12;

    if (period == 'day') {
      gregHour += 6;
    } else {
      // 'night'
      gregHour += 18;
    }

    // Handle the 24-hour wrap-around (e.g., 6 night becomes 24, which should be 0)
    gregHour = gregHour % 24;

    return {'hour': gregHour, 'minute': minute};
  }

  /// Creates a `Time` object from a string representation.
  ///
  /// This static method parses a time string, which can include hours, minutes, and an optional period (day/night).
  /// It supports both Arabic numerals (e.g., "1", "30") and Ethiopic numerals (e.g., "፩", "፴") for hours and minutes.
  ///
  /// The time string must contain a colon (`:`) separating the hour and minute.
  ///
  /// [timeString] - The string representation of the time.
  /// Expected formats:
  /// - "HH:MM" (e.g., "6:30", "፮:፴")
  /// - "HH:MM period" (e.g., "6:30 night", "፮:፴ ማታ")
  /// Where:
  ///   - HH: Hour (Arabic or Ethiopic numeral).
  ///   - MM: Minute (Arabic or Ethiopic numeral).
  ///   - period: Optional. Case-insensitive. Recognized values are "night" or "ማታ".
  ///     If the period is omitted, or if a third part is present but not recognized as "night" or "ማታ",
  ///     the time is assumed to be in the 'day' period.
  ///
  /// Returns a new `Time` object representing the parsed time.
  ///
  /// Throws [InvalidTimeError] If the `timeString` is:
  ///   - Not a string or an empty string.
  ///   - Missing the colon (`:`) separator.
  ///   - Formatted incorrectly (e.g., not enough parts after splitting).
  ///   - Contains non-numeric values for hour or minute that cannot be parsed into numbers
  ///     (neither as Arabic nor as Ethiopic numerals via `toArabic`).
  static Time fromString(String timeString) {
    if (timeString.trim().isEmpty) {
      throw InvalidTimeError(
        'Input must be a non-empty string, but received "$timeString".',
      );
    }

    if (!timeString.contains(':')) {
      throw InvalidTimeError(
        'Invalid time string format: "$timeString". Time must include a colon \':\' separator.',
      );
    }

    int parseNumber(String str) {
      final arabicNum = int.tryParse(str);
      if (arabicNum != null) {
        return arabicNum;
      }
      try {
        return toArabic(str);
      } catch (e) {
        throw InvalidTimeError('Invalid number in time string: "$str"');
      }
    }

    final parts = timeString
        .split(RegExp(r'[:\s]+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length < 2) {
      throw InvalidTimeError('Invalid time string format: "$timeString".');
    }

    final hour = parseNumber(parts[0]);
    final minute = parseNumber(parts[1]);

    String period = 'day';
    if (parts.length > 2) {
      final periodStr = parts[2].toLowerCase();
      if (periodStr == 'night' || periodStr == 'ማታ') {
        period = 'night';
      }
    }
    return Time(hour, minute, period);
  }

  /// Adds a duration to the current time.
  ///
  /// [duration] - Map with hours and/or minutes to add.
  /// Returns a new Time instance with the added duration.
  /// Throws [InvalidTimeError] If duration is not a valid map.
  Time add(Map<String, dynamic> duration) {
    if (duration.isEmpty) {
      throw InvalidTimeError('Duration must be a non-empty map.');
    }
    final hoursRaw = duration['hours'] ?? 0;
    final minutesRaw = duration['minutes'] ?? 0;
    validateNumericInputs('Time.add', {
      'hours': hoursRaw,
      'minutes': minutesRaw,
    });
    final int hours = (hoursRaw as num).toInt();
    final int minutes = (minutesRaw as num).toInt();

    final greg = toGregorian();
    int totalMinutes =
        greg['hour']! * 60 + greg['minute']! + hours * 60 + minutes;
    totalMinutes =
        ((totalMinutes % 1440) + 1440) % 1440; // Normalize to a 24-hour cycle

    final newHour = (totalMinutes / 60).floor();
    final newMinute = totalMinutes % 60;

    return Time.fromGregorian(newHour, newMinute);
  }

  /// Subtracts a duration from the current time.
  ///
  /// [duration] - Map with hours and/or minutes to subtract.
  /// Returns a new Time instance with the subtracted duration.
  /// Throws [InvalidTimeError] If duration is not a valid map.
  Time subtract(dynamic duration) {
    if (duration is! Map<String, dynamic>) {
      throw InvalidTimeError('Duration must be a non-empty map.');
    }
    Map<String, dynamic> dur = duration;
    if (dur.isEmpty) {
      throw InvalidTimeError('Duration must be a non-empty map.');
    }
    final hoursRaw = dur['hours'] ?? 0;
    final minutesRaw = dur['minutes'] ?? 0;
    final int hours = (hoursRaw as num).toInt();
    final int minutes = (minutesRaw as num).toInt();

    return add({'hours': -hours, 'minutes': -minutes});
  }

  /// Calculates the difference between this time and another.
  ///
  /// [otherTime] - Another Time instance to compare against.
  /// Returns a map with the absolute difference in hours and minutes.
  /// Throws [InvalidTimeError] If otherTime is not a Time instance.
  Map<String, int> diff(Time otherTime) {
    final t1 = toGregorian();
    final t2 = otherTime.toGregorian();
    final totalMinutes1 = t1['hour']! * 60 + t1['minute']!;
    final totalMinutes2 = t2['hour']! * 60 + t2['minute']!;

    int diff = (totalMinutes1 - totalMinutes2).abs();

    // Time wraps in a 24h cycle, so find the shortest path
    if (diff > 720) diff = 1440 - diff;

    return {'hours': (diff / 60).floor(), 'minutes': diff % 60};
  }

  /// Formats the time as a string.
  ///
  /// [options] - Formatting options map.
  /// - [lang] - The language for the period label. Defaults to 'english' if useGeez is false, otherwise 'amharic'.
  /// - [useGeez] - Whether to use Ge'ez numerals. Defaults to true.
  /// - [showPeriodLabel] - Whether to show the period label. Defaults to true.
  /// - [zeroAsDash] - Whether to represent zero minutes as a dash. Defaults to true.
  ///
  /// Returns the formatted time string.
  String format([Map<String, dynamic>? options]) {
    options ??= {};

    // If useGeez is explicitly false, the default language should be English.
    final defaultLang = options['useGeez'] == false ? 'english' : 'amharic';
    final lang = options['lang'] ?? defaultLang;
    final useGeez = options['useGeez'] ?? true;
    final showPeriodLabel = options['showPeriodLabel'] ?? true;
    final zeroAsDash = options['zeroAsDash'] ?? true;

    String formatNum(int num) {
      if (useGeez) return toGeez(num);
      return num.toString().padLeft(2, '0');
    }

    final hourStr = formatNum(hour);

    String minuteStr;
    if (zeroAsDash && minute == 0) {
      minuteStr = '_';
    } else {
      minuteStr = useGeez ? toGeez(minute) : minute.toString().padLeft(2, '0');
    }

    String periodLabel = '';
    if (showPeriodLabel) {
      if (lang == 'english') {
        // Use English labels for the period
        periodLabel = period; // 'day' or 'night'
      } else {
        // Default to Amharic labels from constants
        final amharicLabels = {
          'day': PeriodLabels.day,
          'night': PeriodLabels.night,
        };
        periodLabel = amharicLabels[period] ?? '';
      }
    }

    final label = periodLabel.isNotEmpty ? ' $periodLabel' : '';
    return '$hourStr:$minuteStr$label';
  }

  @override
  String toString() {
    return format({'useGeez': false, 'lang': 'english'});
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Time) return false;
    return hour == other.hour &&
        minute == other.minute &&
        period == other.period;
  }

  @override
  int get hashCode => Object.hash(hour, minute, period);
}
