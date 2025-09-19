import 'package:test/test.dart';

import 'package:kenat/src/geez_converter.dart';
import 'package:kenat/src/errors/error_handler.dart';

void main() {
  group('toGeez', () {
    test('converts single digits correctly', () {
      expect(toGeez(1), '፩');
      expect(toGeez(2), '፪');
      expect(toGeez(9), '፱');
    });

    test('converts tens correctly', () {
      expect(toGeez(10), '፲');
      expect(toGeez(20), '፳');
      expect(toGeez(99), '፺፱');
    });

    test('converts hundreds correctly', () {
      expect(toGeez(100), '፻');
      expect(toGeez(101), '፻፩');
      expect(toGeez(110), '፻፲');
      expect(toGeez(123), '፻፳፫');
      expect(toGeez(999), '፱፻፺፱');
    });

    test('converts thousands and ten thousands correctly', () {
      expect(toGeez(1000), '፲፻');
      expect(toGeez(10000), '፼');
    });

    test('returns "0" for input 0', () {
      expect(toGeez(0), '0');
    });

    test('accepts string input', () {
      expect(toGeez('123'), '፻፳፫');
      expect(toGeez('10000'), '፼');
    });

    test('throws error for invalid input', () {
      expect(() => toGeez(-1), throwsA(isA<GeezConverterError>()));
      expect(() => toGeez('abc'), throwsA(isA<GeezConverterError>()));
      expect(() => toGeez(null), throwsA(anything));
      expect(() => toGeez(null), throwsA(isA<Exception>()));
      // Dart's dynamic typing means passing `undefined` is not applicable.
      expect(() => toGeez(1.5), throwsA(isA<GeezConverterError>()));
    });
  });

  group('toArabic', () {
    test("converts single Ge'ez numerals to Arabic", () {
      expect(toArabic('፩'), 1);
      expect(toArabic('፪'), 2);
      expect(toArabic('፱'), 9);
    });

    test("converts Ge'ez tens to Arabic", () {
      expect(toArabic('፲'), 10);
      expect(toArabic('፳'), 20);
      expect(toArabic('፺፱'), 99);
    });

    test("converts Ge'ez hundreds to Arabic", () {
      expect(toArabic('፻'), 100);
      expect(toArabic('፻፩'), 101);
      expect(toArabic('፻፲'), 110);
      expect(toArabic('፻፳፫'), 123);
      expect(toArabic('፱፻፺፱'), 999);
    });

    test("converts Ge'ez thousands and ten thousands to Arabic", () {
      expect(toArabic('፲፻'), 1000);
      expect(toArabic('፼'), 10000);
      expect(toArabic('፲፼'), 100000);
    });

    test('handles complex numbers', () {
      expect(toArabic('፲፻፺፱'), 1099);
      // The following expectation mirrors the JS test but may need review if semantics differ.
      expect(toArabic('፬፻'), 400);
    });

    test("throws error for unknown Ge'ez numerals", () {
      expect(
        () => toArabic('A'),
        throwsA(
          predicate((e) => e.toString().contains("Unknown Ge'ez numeral")),
        ),
      );
      expect(
        () => toArabic('፩X'),
        throwsA(
          predicate((e) => e.toString().contains("Unknown Ge'ez numeral")),
        ),
      );
    });

    test('throws error for non-string input', () {
      final dyn = toArabic as dynamic;
      bool matcher(dynamic e) =>
          e is GeezConverterError || e is TypeError || e is NoSuchMethodError;

      expect(() => dyn(null), throwsA(predicate((e) => matcher(e))));
      expect(() => dyn(123), throwsA(predicate((e) => matcher(e))));
    });

    test('converts round-trip toGeez -> toArabic', () {
      final nums = [1, 10, 99, 100, 123, 999, 1000, 10000, 12345, 999999];
      for (final n in nums) {
        expect(toArabic(toGeez(n)), n);
      }
    });
  });
}
