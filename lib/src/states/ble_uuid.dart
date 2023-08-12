import 'package:flutter/foundation.dart';

/// Our own take on a Bluetooth LE UUID.

@immutable
class BleUUID {
  static const baseUUIDSuffix = '-0000-1000-8000-00805f9b34fb';

  /// String version of UUID
  final String str;

  static final validateRegex = RegExp(
      r'^[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}$',
      caseSensitive: false);

  static final validHexStringRegex =
      RegExp(r'^[0-9a-f]+$', caseSensitive: false);

  const BleUUID._(this.str);

  /// Create from a [uuidString] which must be in standard UUID format
  /// or a hex string for a short uuid.
  factory BleUUID(String uuidString) {
    final str = uuidString.toLowerCase();

    if (validateUUID(str)) {
      return BleUUID._(str);
    }

    // Check for hex string
    if (!validateHexString(str)) {
      throw FormatException("Malformed BleUUID String", str);
    }

    return BleUUID.fromInt(int.parse(str, radix: 16));
  }

  /// Create from integer [shortUUID]
  factory BleUUID.fromInt(int shortUUID) {
    return BleUUID(
        "${shortUUID.toRadixString(16).padLeft(8, '0')}$baseUUIDSuffix");
  }

  /// Return true if uuid is short
  bool get isShort => str.endsWith(baseUUIDSuffix);

  /// Return short UUID as int or null if not short
  int? get shortUUID =>
      isShort ? int.parse(str.substring(0, 8), radix: 16) : null;

  @override
  bool operator ==(Object other) =>
      other is BleUUID && other.runtimeType == runtimeType && other.str == str;

  @override
  int get hashCode => str.hashCode;

  /// Show the short form is short else the long
  @override
  String toString() => switch (shortUUID) {
        int s => "0x${s.toRadixString(16)}",
        _ => str,
      };

  /// Check [uuidstring] has a valid standard string format
  static bool validateUUID(String uuidString) {
    return validateRegex.hasMatch(uuidString);
  }

  /// Check [uuidstring] is a valid hex number as string
  static bool validateHexString(String s) {
    return validHexStringRegex.hasMatch(s);
  }
}
