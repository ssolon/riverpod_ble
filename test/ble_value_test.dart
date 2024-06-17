import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ble/src/states/ble_value.dart';

void main() {
  group('No format tests', () {
    test('No values, no format', () {
      final v = BleRawValue(values: [], format: null);
      final r = convertRawValue(v, null);
      expect(
          r.maybeMap(
            (value) => true,
            orElse: () => false,
          ),
          true,
          reason: 'No formats defaults to base');
      expect(
          r.maybeWhen(
            (values, f) => values.isEmpty,
            orElse: () => false,
          ),
          true,
          reason: 'No formats defaults to base');
      expect(r.format, FormatTypes.unknown);
    });

    test('Format in raw, no explicit', () {
      final testValues = [1, 2, 3, 4];
      final f = BlePresentationFormat(gattFormat: FormatTypes.medASN1);
      final v = BleRawValue(values: testValues, format: f);
      final r = convertRawValue(v, null);

      expect(r.format, FormatTypes.medASN1,
          reason: 'Format type passed through');
      expect(
          r.maybeWhen((raw, format) => false,
              unsupported: (raw, format) => true, orElse: () => false),
          true,
          reason: 'Unsupported from raw');
      expect(
          r.maybeWhen((raw, format) => raw,
              unsupported: (raw, format) => raw, orElse: () => null),
          testValues,
          reason: 'Values passed through');
    });
    test('No format in raw, explicit passed', () {
      final testValues = [1, 2, 3, 4];
      final v = BleRawValue(values: testValues, format: null);
      final f = BlePresentationFormat(gattFormat: FormatTypes.medASN1);
      final r = convertRawValue(v, f);

      expect(
          r.maybeWhen(
            (raw, format) => false,
            unsupported: (raw, format) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Unsupported type explicitly passed');
    });
    test('Format in raw, explicit passed', () {
      final testValues = [1, 2, 3, 4];
      final v = BleRawValue(values: testValues, format: null);
      final f = BlePresentationFormat(gattFormat: FormatTypes.medASN1);
      final fexplicit = BlePresentationFormat(); // default to unknown
      final r = convertRawValue(v, f);

      expect(
          r.maybeWhen(
            (raw, format) => false,
            unsupported: (raw, format) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Unsupported type from raw');
    });
  });
  group('Boolean converter tests', () {
    test('Boolean no value', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.boolean);
      final v = BleRawValue(values: [], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen((raw, format) => false,
              boolean: (raw, format, value) => true, orElse: () => false),
          true,
          reason: 'Result is boolean');
      expect(
          r.maybeWhen((raw, format) => false,
              boolean: (raw, format, value) => value == false,
              orElse: () => false),
          true,
          reason: 'Empty value is false');
    });
    test('Boolean zero value', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.boolean);
      final v = BleRawValue(values: [0], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen((raw, format) => false,
              boolean: (raw, format, value) => true, orElse: () => false),
          true,
          reason: 'Result is boolean');
      expect(
          r.maybeWhen((raw, format) => false,
              boolean: (raw, format, value) => value == false,
              orElse: () => false),
          true,
          reason: 'Zero value is false');
    });
    test('Boolean some value', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.boolean);
      final v = BleRawValue(values: [1], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen((raw, format) => false,
              boolean: (raw, format, value) => true, orElse: () => false),
          true,
          reason: 'Result is boolean');
      expect(
          r.maybeWhen((raw, format) => false,
              boolean: (raw, format, value) => value == true,
              orElse: () => false),
          true,
          reason: 'Value is true');
    });
  });

  group('Text converter tests', () {
    test('No values to empty string', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.utf8s);
      final v = BleRawValue(values: [], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen(
            (raw, format) => false,
            utf: (raw, format, value) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Convert to text');
      expect(
          r.maybeWhen(
            (raw, format) => 'bad',
            utf: (raw, format, value) => value,
            orElse: () => 'else',
          ),
          '',
          reason: 'Empty values to empty string');
    });

    test('Some values utf8', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.utf8s);
      final v =
          BleRawValue(values: [116, 101, 115, 116, 105, 110, 103], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen(
            (raw, format) => false,
            utf: (raw, format, value) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Convert to text');
      expect(
          r.maybeWhen(
            (raw, format) => 'bad',
            utf: (raw, format, value) => value,
            orElse: () => 'empty',
          ),
          'testing',
          reason: 'Text value');
    });

    test('Some values utf16', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.utf16s);
      final v = BleRawValue(
          values: [116, 0, 101, 0, 115, 0, 116, 0, 105, 0, 110, 0, 103, 0],
          format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen(
            (raw, format) => false,
            utf: (raw, format, value) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Convert to text');
      expect(
          r.maybeWhen(
            (raw, format) => 'bad',
            utf: (raw, format, value) => value,
            orElse: () => 'empty',
          ),
          'testing',
          reason: 'Text value');
    });
  });

  group('Numeric converter tests', () {
    numericTest(List<int> values, FormatTypes ftype, expected,
        [bool isBigInt = false]) {
      final f = BlePresentationFormat(gattFormat: ftype);
      final v = BleRawValue(values: values, format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeMap(
            (value) => false,
            numeric: (value) => !isBigInt,
            bigNumeric: (value) => isBigInt,
            orElse: () => false,
          ),
          true,
          reason: 'Converts to numeric');
      expect(
          r.maybeWhen(
            (raw, format) => 9999,
            numeric: (raw, format, value) => value,
            bigNumeric: (raw, format, value) => value,
            orElse: () => 6666,
          ),
          expected);
    }

    test('Empty values to zero', () => numericTest([], FormatTypes.uint2, 0));
    test('uint2', () => numericTest([0xd2, 0x84], FormatTypes.uint2, 2));
    test('uint4', () => numericTest([0xd2, 0x84], FormatTypes.uint4, 2));
    test('uint8', () => numericTest([0xd2, 0x84], FormatTypes.uint8, 210));
    test('uint12', () => numericTest([0xd2, 0x84], FormatTypes.uint12, 1234));
    test('uint16', () => numericTest([0xd2, 0x84], FormatTypes.uint16, 34002));
    test('uint24',
        () => numericTest([0x0, 0x00, 0x01, 0xff], FormatTypes.uint24, 65536));
    test('uint32',
        () => numericTest([0, 0, 0, 1, 0xff], FormatTypes.uint32, 16777216));
    test(
        'uint48',
        () =>
            numericTest([0, 0, 0, 0, 0, 1], FormatTypes.uint48, 1099511627776));
    test(
        'uint64',
        () => numericTest(
            [0, 0, 0, 0, 0, 0, 0, 1], FormatTypes.uint64, 72057594037927936));
    test(
        'uint128',
        () => numericTest(
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            FormatTypes.uint128,
            BigInt.parse('1329227995784915872903807060280344576'),
            true));
    test('sint8', () => numericTest([0xfb, 0xff], FormatTypes.sint8, -5));
    test('sint12', () => numericTest([0x2e, 0xfb], FormatTypes.sint12, -1234));
    test('sint16', () => numericTest([0x2e, 0xfb], FormatTypes.sint16, -1234));
    test('sint24',
        () => numericTest([0xff, 0xff, 0xfe], FormatTypes.sint24, -65537));
    test(
        'sint32',
        () => numericTest(
            [0xff, 0xff, 0xff, 0xfe], FormatTypes.sint32, -16777217));
    test(
        'sint48',
        () => numericTest([0xff, 0xff, 0xff, 0xff, 0xff, 0xfe],
            FormatTypes.sint48, -1099511627777));
    test(
        'sint64',
        () => numericTest([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe],
            FormatTypes.sint64, -72057594037927937));
    test(
        'sint128',
        () => numericTest([
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xff,
              0xfe,
            ], FormatTypes.uint128,
                BigInt.parse('-1329227995784915872903807060280344577'), true));
  });

  group('Float tests', () {
    test('Float32 test', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.float32);
      final v = BleRawValue(values: [0x2e, 0x0c, 0xff, 0x66], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen(
            (raw, format) => false,
            float: (raw, format, value) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Convert to float');
      expect(
          r.maybeWhen(
            (raw, format) => 'bad',
            float: (raw, format, value) => value,
            orElse: () => 'empty',
          ),
          6.022140643549849e+23,
          reason: 'Float value');
    });
    test('Float64 test', () {
      final f = BlePresentationFormat(gattFormat: FormatTypes.float64);
      final v = BleRawValue(
          values: [0x17, 0xc5, 0x57, 0xca, 0x85, 0xe1, 0xdf, 0x44], format: f);
      final r = convertRawValue(v, null);
      expect(
          r.maybeWhen(
            (raw, format) => false,
            float: (raw, format, value) => true,
            orElse: () => false,
          ),
          true,
          reason: 'Convert to float');
      expect(
          r.maybeWhen(
            (raw, format) => 'bad',
            float: (raw, format, value) => value,
            orElse: () => 'empty',
          ),
          6.02214076e+23,
          reason: 'Float value');
    });
  });
}
