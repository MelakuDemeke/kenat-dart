/// Geez numeral conversion functions
/// Converts Arabic numerals to Ethiopic (Geez) numerals and vice versa

import 'errors/error_handler.dart';

/// Geez numeral symbols
class GeezSymbols {
  static const List<String> ones = [
    '',
    '፩',
    '፪',
    '፫',
    '፬',
    '፭',
    '፮',
    '፯',
    '፰',
    '፱',
  ];
  static const List<String> tens = [
    '',
    '፲',
    '፳',
    '፴',
    '፵',
    '፶',
    '፷',
    '፸',
    '፹',
    '፺',
  ];
  static const String hundred = '፻';
  static const String tenThousand = '፼';
}

/// Geez numeral converter class
class GeezConverter {
  /// Converts a natural number to Ethiopic numeral string.
  ///
  /// [input] - The number to convert (positive integer only).
  /// Returns Ethiopic numeral string.
  /// Throws [GeezConverterError] If input is not a valid positive integer.
  static String toGeez(dynamic input) {
    if (input is! num && input is! String) {
      throw GeezConverterError("Input must be a number or a string.");
    }

    final numValue = input is String ? int.tryParse(input) : input as num?;

    if (numValue == null ||
        !numValue.isFinite ||
        numValue != numValue.round() ||
        numValue < 0) {
      throw GeezConverterError("Input must be a non-negative integer.");
    }

    final intValue = numValue.round();

    if (intValue == 0)
      return '0'; // Often Ge'ez doesn't have a zero, but useful for modern contexts.

    // Helper for numbers 1-99
    String convertBelow100(int n) {
      if (n <= 0) return '';
      final tensDigit = (n / 10).floor();
      final onesDigit = n % 10;
      return GeezSymbols.tens[tensDigit] + GeezSymbols.ones[onesDigit];
    }

    if (intValue < 100) {
      return convertBelow100(intValue);
    }

    if (intValue == 100) return GeezSymbols.hundred;

    if (intValue < 10000) {
      final hundreds = (intValue / 100).floor();
      final remainder = intValue % 100;
      // For numbers like 101, it's ፻፩, not ፩፻፩. If the hundred part is 1, don't add a prefix.
      final hundredPart =
          (hundreds > 1 ? convertBelow100(hundreds) : '') + GeezSymbols.hundred;
      return hundredPart + convertBelow100(remainder);
    }

    // For numbers >= 10000, use recursion
    final tenThousandPart = (intValue / 10000).floor();
    final remainder = intValue % 10000;

    // If the ten-thousand part is 1, no prefix is needed (e.g., ፼, not ፩፼)
    final tenThousandGeez =
        (tenThousandPart > 1 ? toGeez(tenThousandPart) : '') +
        GeezSymbols.tenThousand;

    return tenThousandGeez + (remainder > 0 ? toGeez(remainder) : '');
  }

  /// Converts a Ge'ez numeral string to its Arabic numeral equivalent.
  ///
  /// [geezStr] - The Ge'ez numeral string to convert.
  /// Returns the Arabic numeral representation of the input string.
  /// Throws [GeezConverterError] If the input is not a valid Ge'ez numeral string.
  static int toArabic(String geezStr) {
    if (geezStr.trim().isEmpty) {
      return 0; // Or throw error, depending on desired behavior for empty string
    }

    final reverseMap = <String, int>{};

    // Build reverse mapping for ones
    for (int i = 0; i < GeezSymbols.ones.length; i++) {
      final char = GeezSymbols.ones[i];
      if (char.isNotEmpty) reverseMap[char] = i;
    }

    // Build reverse mapping for tens
    for (int i = 0; i < GeezSymbols.tens.length; i++) {
      final char = GeezSymbols.tens[i];
      if (char.isNotEmpty) reverseMap[char] = i * 10;
    }

    reverseMap[GeezSymbols.hundred] = 100;
    reverseMap[GeezSymbols.tenThousand] = 10000;

    int total = 0;
    int currentNumber = 0;

    for (final char in geezStr.split('')) {
      final value = reverseMap[char];

      if (value == null) {
        throw GeezConverterError("Unknown Ge'ez numeral: $char");
      }

      if (value == 100 || value == 10000) {
        // If currentNumber is 0, it implies a standalone ፻ or ፼, so treat it as 1 * multiplier.
        currentNumber = (currentNumber == 0 ? 1 : currentNumber) * value;

        // ፼ acts as a separator for large numbers. Add the completed segment to the total.
        if (value == 10000) {
          total += currentNumber;
          currentNumber = 0;
        }
      } else {
        // Add simple digit values (1-99)
        currentNumber += value;
      }
    }

    // Add any remaining part (for numbers that don't end in ፼)
    total += currentNumber;
    return total;
  }
}

/// Convenience functions that match the original JavaScript API
/// These provide static access to the conversion functions

/// Converts a natural number to Ethiopic numeral string.
String toGeez(dynamic input) {
  return GeezConverter.toGeez(input);
}

/// Converts a Ge'ez numeral string to its Arabic numeral equivalent.
int toArabic(String geezStr) {
  return GeezConverter.toArabic(geezStr);
}
