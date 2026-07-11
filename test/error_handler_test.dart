import 'package:test/test.dart';
import 'package:kenat/src/errors/error_handler.dart';

/// Regression tests for the `toJson()['type']` bug: previously every
/// KenatError subclass reported the literal string 'KenatError' regardless
/// of its actual runtime type, because `type` was set unconditionally in the
/// base class constructor and never overridden. `type` is now a getter
/// derived from `runtimeType`, so every subclass self-reports correctly -
/// mirroring TS's `this.constructor.name` behavior.
void main() {
  group('KenatError.toJson()["type"] reflects the concrete subclass', () {
    test('KenatError itself', () {
      final e = KenatError('generic');
      expect(e.toJson()['type'], equals('KenatError'));
    });

    test('InvalidEthiopianDateError', () {
      final e = InvalidEthiopianDateError(2016, 14, 1);
      expect(e.toJson()['type'], equals('InvalidEthiopianDateError'));
      expect(e.toJson()['date'], equals({'year': 2016, 'month': 14, 'day': 1}));
    });

    test('InvalidGregorianDateError', () {
      final e = InvalidGregorianDateError(2016, 2, 30);
      expect(e.toJson()['type'], equals('InvalidGregorianDateError'));
    });

    test('InvalidDateFormatError', () {
      final e = InvalidDateFormatError('not-a-date');
      expect(e.toJson()['type'], equals('InvalidDateFormatError'));
      expect(e.toJson()['inputString'], equals('not-a-date'));
    });

    test('UnrecognizedInputError', () {
      final e = UnrecognizedInputError(42);
      expect(e.toJson()['type'], equals('UnrecognizedInputError'));
    });

    test('GeezConverterError', () {
      final e = GeezConverterError('bad geez input');
      expect(e.toJson()['type'], equals('GeezConverterError'));
    });

    test('InvalidInputTypeError', () {
      final e = InvalidInputTypeError('fn', 'param', 'number', 'oops');
      expect(e.toJson()['type'], equals('InvalidInputTypeError'));
    });

    test('InvalidTimeError', () {
      final e = InvalidTimeError('bad time');
      expect(e.toJson()['type'], equals('InvalidTimeError'));
    });

    test('InvalidGridConfigError', () {
      final e = InvalidGridConfigError('bad config');
      expect(e.toJson()['type'], equals('InvalidGridConfigError'));
    });

    test('UnknownHolidayError', () {
      final e = UnknownHolidayError('FAKE_KEY');
      expect(e.toJson()['type'], equals('UnknownHolidayError'));
      expect(e.toJson()['holidayKey'], equals('FAKE_KEY'));
      expect(e.message, contains('FAKE_KEY'));
    });
  });

  group('toString() also reflects the subclass name', () {
    test('subclass toString includes its own type, not the literal "KenatError"', () {
      final e = InvalidTimeError('bad time');
      expect(e.toString(), startsWith('InvalidTimeError:'));
    });
  });
}
