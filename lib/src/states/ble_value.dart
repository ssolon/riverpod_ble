import 'dart:math';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';
import 'package:riverpod_ble/src/ble_bitstring.dart';

part 'ble_value.freezed.dart';
part 'ble_value.g.dart';

/// Convert [rawValue] to a [BleValue] using [f] if provided otherwise use
/// the [PresentationValue] from [rawValue] and if that's not there use
/// the default which will have [FormatType.unkonwn].
///
/// Note: numeric values are assumed to be little-endian which conforms
/// to the GATT spec. Some devices don't follow this.
BleValue convertRawValue(BleRawValue rawValue, BlePresentationFormat? f,
    [int valueBitOffset = 0]) {
  f ??= rawValue.format;
  f ??= BlePresentationFormat();
  final width = f.gattFormat.widthInBits ?? 8;
  final octets = extractBits(rawValue.values, valueBitOffset, width);
  return f.gattFormat.category.converter(octets, f);
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

// FIXME: How big is a boolean?
BleValue booleanConverter(List<int> values, BlePresentationFormat f) =>
    BleValue.boolean(values, f.gattFormat, values.isNotEmpty && values[0] != 0);

BleValue textConverter(List<int> values, BlePresentationFormat f) {
  final chars =
      f.gattFormat == FormatTypes.utf16s ? bytesToWords(values) : values;
  return BleValue.utf(values, f.gattFormat, String.fromCharCodes(chars));
}

BleValue unsignedConverter(List<int> values, BlePresentationFormat f) {
  final width = f.gattFormat.widthInBits;
  final v = (width == null) ? values : extractBits(values, 0, width);
  return BleValue.numeric(values, f.gattFormat, toBigEndian(v));
}

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
  boolean(1, ConverterCategory.boolean), // How wide?
  uint2(2, ConverterCategory.unsignedInteger, 2),
  uint4(3, ConverterCategory.unsignedInteger, 4),
  uint8(4, ConverterCategory.unsignedInteger, 8),
  uint12(5, ConverterCategory.unsignedInteger, 12),
  uint16(6, ConverterCategory.unsignedInteger, 16),
  uint24(7, ConverterCategory.unsignedInteger, 24),
  uint32(8, ConverterCategory.unsignedInteger, 32),
  uint48(9, ConverterCategory.unsignedInteger, 48),
  uint64(10, ConverterCategory.unsignedInteger, 64),
  uint128(11, ConverterCategory.bigInt, 128),
  sint8(12, ConverterCategory.integer, 8),
  sint12(13, ConverterCategory.integer, 12),
  sint16(14, ConverterCategory.integer, 16),
  sint24(15, ConverterCategory.integer, 24),
  sint32(16, ConverterCategory.integer, 32),
  sint48(17, ConverterCategory.integer, 48),
  sint64(18, ConverterCategory.integer, 64),
  sint128(19, ConverterCategory.bigInt, 128),
  float32(20, ConverterCategory.float, 32),
  float64(21, ConverterCategory.float, 64),
  medfloat16(22, ConverterCategory.float, 16),
  medfloat32(23, ConverterCategory.float, 32),
  uint16_2(24, ConverterCategory.unsupported),
  utf8s(25, ConverterCategory.text),
  utf16s(26, ConverterCategory.text),
  struct(27, ConverterCategory.unsupported),
  medASN1(28, ConverterCategory.unsupported);

  final int value;
  final ConverterCategory category;
  final int? widthInBits;
  const FormatTypes(this.value, this.category, [this.widthInBits])
      : assert(
            ((identical(category, ConverterCategory.integer) ||
                        identical(
                            category, ConverterCategory.unsignedInteger) ||
                        identical(category, ConverterCategory.bigInt) ||
                        identical(category, ConverterCategory.float)) &&
                    (widthInBits != null)) ||
                identical(category, ConverterCategory.unknown) ||
                identical(category, ConverterCategory.boolean) ||
                identical(category, ConverterCategory.text) ||
                identical(category, ConverterCategory.unsupported),
            "widthInBits must be provided for numeric categories: $category, $widthInBits");
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

  factory BlePresentationFormat.fromJson(Map<String, dynamic> json) =>
      _$BlePresentationFormatFromJson(json);
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
///
/// [toString()] is overridden to return the [toString()] of the current value.
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
        (raw, format) => raw,
        boolean: (r, f, v) => v,
        utf: (r, f, v) => v,
        numeric: (r, f, v) => v,
        bigNumeric: (r, f, v) => v,
        float: (r, f, v) => v,
        unsupported: (raw, format) => raw,
      ).toString();
}
