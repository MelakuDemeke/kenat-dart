/// Custom error classes for the Ethiopian calendar library

/// Base class for all custom errors in the Kenat library.
class KenatError implements Exception {
  final String message;
  final String type;

  KenatError(this.message) : type = 'KenatError';

  @override
  String toString() => 'KenatError: $message';

  /// Provides a serializable representation of the error.
  Map<String, dynamic> toJson() {
    return {'type': type, 'message': message};
  }
}

/// Thrown when an Ethiopian date is numerically invalid (e.g., month 14).
class InvalidEthiopianDateError extends KenatError {
  final Map<String, int> date;

  InvalidEthiopianDateError(int year, int month, int day)
    : date = {'year': year, 'month': month, 'day': day},
      super('Invalid Ethiopian date: $year/$month/$day');

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'date': date,
      'validRange': {
        'month': '1–13',
        'day': '1–30 (or 5/6 for the 13th month)',
      },
    };
  }
}

/// Thrown when a Gregorian date is numerically invalid.
class InvalidGregorianDateError extends KenatError {
  final Map<String, int> date;

  InvalidGregorianDateError(int year, int month, int day)
    : date = {'year': year, 'month': month, 'day': day},
      super('Invalid Gregorian date: $year/$month/$day');

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'date': date,
      'validRange': {'month': '1–12', 'day': '1–31 (depending on month)'},
    };
  }
}

/// Thrown when a date string provided to the constructor has an invalid format.
class InvalidDateFormatError extends KenatError {
  final String inputString;

  InvalidDateFormatError(this.inputString)
    : super(
        'Invalid date string format: "$inputString". Expected \'yyyy/mm/dd\' or \'yyyy-mm-dd\'.',
      );

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'inputString': inputString};
  }
}

/// Thrown when the Kenat constructor receives an input type it cannot handle.
class UnrecognizedInputError extends KenatError {
  final dynamic input;

  UnrecognizedInputError(this.input)
    : super(
        'Unrecognized input type for Kenat constructor: ${input.runtimeType}',
      );

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'inputType': input.runtimeType.toString()};
  }
}

/// Thrown for errors occurring during Ge'ez numeral conversion.
class GeezConverterError extends KenatError {
  GeezConverterError(String message) : super(message);
}

/// Thrown when a function receives an argument of an incorrect type.
class InvalidInputTypeError extends KenatError {
  final String functionName;
  final String parameterName;
  final String expectedType;
  final dynamic receivedValue;

  InvalidInputTypeError(
    this.functionName,
    this.parameterName,
    this.expectedType,
    this.receivedValue,
  ) : super(
        'Invalid type for parameter \'$parameterName\' in function \'$functionName\'. Expected \'$expectedType\' but got \'${receivedValue.runtimeType}\'.',
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'functionName': functionName,
      'parameterName': parameterName,
      'expectedType': expectedType,
      'receivedType': receivedValue.runtimeType.toString(),
    };
  }
}

/// Thrown for errors related to invalid time components.
class InvalidTimeError extends KenatError {
  InvalidTimeError(String message) : super(message);
}

/// Thrown for invalid configuration options passed to MonthGrid.
class InvalidGridConfigError extends KenatError {
  InvalidGridConfigError(String message) : super(message);
}
