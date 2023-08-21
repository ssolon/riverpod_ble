import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

part 'ble_value.freezed.dart';

/// Convert [rawValue] to a [BleValue] using [f] if provided otherwise use
/// the [PresentationValue] from [rawValue] and if that's not there use
/// the default which will have [FormatType.unkonwn].
BleValue convertRawValue(BleRawValue rawValue, BlePresentationFormat? f) {
  f ??= rawValue.format;
  f ??= BlePresentationFormat();
  return f.gattFormat.category.converter(rawValue.values, f);
}

/// Category of values we understand and how to convert them
enum ConverterCategory {
  unknown(unkownConverter),
  boolean(booleanConverter),
  text(textConverter),
  integer(signedConverter),
  unsignedInteger(unsignedConverter),
  bigInt(bigIntConverter),
  float(floatConverter),
  unsupported(unsupportedConverter),
  ;

  final BleValue Function(List<int>, BlePresentationFormat format) converter;
  const ConverterCategory(this.converter);
}

BleValue unkownConverter(List<int> values, BlePresentationFormat f) =>
    BleValue(values, f.gattFormat);

BleValue booleanConverter(List<int> values, BlePresentationFormat f) =>
    BleValue.boolean(values, f.gattFormat, values.isNotEmpty && values[0] != 0);

BleValue textConverter(List<int> values, BlePresentationFormat f) {
  final chars =
      f.gattFormat == FormatTypes.utf16s ? bytesToWords(values) : values;
  return BleValue.utf(values, f.gattFormat, String.fromCharCodes(chars));
}

BleValue unsignedConverter(List<int> values, BlePresentationFormat f) =>
    BleValue.numeric(values, f.gattFormat, toBigEndian(values));

BleValue signedConverter(List<int> values, BlePresentationFormat f) {
  if (values.isEmpty) {
    return BleValue.numeric(values, f.gattFormat, 0);
  }

  int v = toBigEndian(values);

  int result = switch (f.gattFormat) {
    FormatTypes.sint8 => v.toSigned(8),
    FormatTypes.sint12 => v.toSigned(12),
    FormatTypes.sint16 => v.toSigned(16),
    FormatTypes.sint24 => v.toSigned(24),
    FormatTypes.sint32 => v.toSigned(32),
    FormatTypes.sint48 => v.toSigned(48),
    FormatTypes.sint64 => v.toSigned(64),
    _ => throw BleValueConverterNotSupported("signedConverter", f.gattFormat),
  };

  return BleValue.numeric(values, f.gattFormat, result);
}

BleValue bigIntConverter(List<int> values, BlePresentationFormat f) {
  final bigString =
      values.reversed.map((v) => v.toRadixString(16).padLeft(2, '0')).join();

  return BleValue.bigNumeric(
      values, f.gattFormat, BigInt.parse("0x$bigString").toSigned(128));
}

BleValue floatConverter(List<int> values, BlePresentationFormat f) {
  final u8list = Uint8List.fromList(values);
  final bd = ByteData.sublistView(u8list);

  final v = switch (f.gattFormat) {
    FormatTypes.float32 => bd.getFloat32(0, Endian.little),
    FormatTypes.float64 => bd.getFloat64(0, Endian.little),
    _ => throw BleValueConverterNotSupported('floatConverter', f.gattFormat),
  };

  return BleValue.float(values, f.gattFormat, v);
}

BleValue unsupportedConverter(List<int> values, BlePresentationFormat f) =>
    BleValue.unsupported(values, f.gattFormat);

@immutable
class BleValueConverterNotSupported extends RiverpodBleException {
  final String converter;
  final FormatTypes gattFormat;

  const BleValueConverterNotSupported(this.converter, this.gattFormat);
}

int toBigEndian(List<int> values) =>
    values.reversed.fold(0, (result, i) => result << 8 | i);

List<int> bytesToWords(List<int> values) {
  List<int> result = [];
  for (var i = 0; i < values.length; i += 2) {
    result.add(values[i] | (values[i + 1] << 8));
  }
  return result;
}

/// Treat the list of bytes (stored as ints) as a little endian unsigned integer
/// and return the value.
/// This assumes that the entire list represents the integer value.
int uint(List<int> v) => v.reversed.fold(0, (result, b) => result << 8 | b);

/// Bluetooth LE formattypes
/// from https://bitbucket.org/bluetooth-SIG/public/src/main/assigned_numbers/core/formattypes.yaml
/// and https://btprodspecificationrefs.blob.core.windows.net/assigned-numbers/Assigned%20Number%20Types/Assigned_Numbers.pdf
/// section 2.4.1
enum FormatTypes {
  unknown(0, ConverterCategory.unknown),
  boolean(1, ConverterCategory.boolean),
  uint2(2, ConverterCategory.unsignedInteger),
  uint4(3, ConverterCategory.unsignedInteger),
  uint8(4, ConverterCategory.unsignedInteger),
  uint12(5, ConverterCategory.unsignedInteger),
  uint16(6, ConverterCategory.unsignedInteger),
  uint24(7, ConverterCategory.unsignedInteger),
  uint32(8, ConverterCategory.unsignedInteger),
  uint48(9, ConverterCategory.unsignedInteger),
  uint64(10, ConverterCategory.unsignedInteger),
  uint128(11, ConverterCategory.bigInt),
  sint8(12, ConverterCategory.integer),
  sint12(13, ConverterCategory.integer),
  sint16(14, ConverterCategory.integer),
  sint24(15, ConverterCategory.integer),
  sint32(16, ConverterCategory.integer),
  sint48(17, ConverterCategory.integer),
  sint64(18, ConverterCategory.integer),
  sint128(19, ConverterCategory.bigInt),
  float32(20, ConverterCategory.float),
  float64(21, ConverterCategory.float),
  medfloat16(22, ConverterCategory.float),
  medfloat32(23, ConverterCategory.float),
  uint16_2(24, ConverterCategory.unsupported),
  utf8s(25, ConverterCategory.text),
  utf16s(26, ConverterCategory.text),
  struct(27, ConverterCategory.unsupported),
  medASN1(28, ConverterCategory.unsupported);

  final int value;
  final ConverterCategory category;

  const FormatTypes(this.value, this.category);
}

/// Gatt presentation format from 0x2904 descriptor
/// From https://os.mbed.com/docs/mbed-os/v6.16/mbed-os-api-doxy/struct_gatt_characteristic_1_1_presentation_format__t.html#ab45581ed2e95d07f1b964ffa6d1605a8
///
/// Create your own to control conversion.
@freezed
class BlePresentationFormat with _$BlePresentationFormat {
  factory BlePresentationFormat({
    @Default(FormatTypes.unknown) FormatTypes gattFormat,
    int? exponent,
    int? gattUnit,
    int? gattNamespace,
    int? gannNdesc,
  }) = _BlePresentationFormat;
}

/// Raw values returned from reading a characteristic
///
/// Contains [BlePresentationFormat] filled in if the characteristic
/// has a Presentation Format (0x2090) descriptor.
@freezed
class BleRawValue with _$BleRawValue {
  factory BleRawValue({
    required List<int> values,
    BlePresentationFormat? format,
  }) = _BleRawValue;
}

/// Converted (if possible) value.
@freezed
class BleValue with _$BleValue {
  const BleValue._();

  factory BleValue(
    List<int> raw,
    FormatTypes format,
  ) = _BleValue;

  factory BleValue.numeric(
    List<int> raw,
    FormatTypes format,
    num value,
  ) = Numeric;

  factory BleValue.bigNumeric(
    List<int> raw,
    FormatTypes format,
    BigInt value,
  ) = BigNumeric;

  factory BleValue.float(
    List<int> raw,
    FormatTypes format,
    double value,
  ) = Float;

  factory BleValue.utf(
    List<int> raw,
    FormatTypes format,
    String value,
  ) = Utf;

  factory BleValue.boolean(
    List<int> raw,
    FormatTypes format,
    bool value,
  ) = Boolean;

  factory BleValue.unsupported(
    List<int> raw,
    FormatTypes format,
  ) = Unsupported;

  @override
  String toString() => when(
        (raw, format) => raw.toString(),
        boolean: (r, f, v) => v.toString(),
        utf: (r, f, v) => v.toString(),
        numeric: (r, f, v) => v.toString(),
        bigNumeric: (r, f, v) => v.toString(),
        float: (r, f, v) => v.toString(),
        unsupported: (raw, format) => raw.toString(),
      );
}
