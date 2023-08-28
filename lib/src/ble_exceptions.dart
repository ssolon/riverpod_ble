import 'package:flutter/material.dart';
import '../riverpod_ble.dart';

////////////////////////////////////////////////////////////////////////////
/// Exceptions
////////////////////////////////////////////////////////////////////////////

/// Exception message formatting helper types
typedef MsgVarDef = ({String n, Object v});
typedef MsgVarList = List<MsgVarDef>;

/// Mixin to augment classes with a reference to another object.
/// Used by [Exception] subclasses to create a chain of references of exceptions
/// that can be search to determine a source of exceptions to simplify error
/// handling while still maintaining a history of the exception for logging
/// and debuggin purposes.
///

mixin CausedBy {
  /// An object which is the immediate cause of the [this] object.
  Object? get causedBy;

  /// Trace back along [causedBy] references returning the first object
  /// that satisfies the [isCause] predicate provided. If none is found
  /// null is returned.
  ///
  /// [isCause] will be called for each object, starting with this,
  /// and working back while the [causedBy] objects have this mixin.
  ///
  Object? isCaused(bool Function(Object o) isCause) {
    Object? check = this;

    while (check != null) {
      if (isCause(check)) {
        return check;
      }

      check = check is CausedBy ? check.causedBy : null;
    }

    return null;
  }

  /// Format a message for an exception using [base], [vars] and [opts].
  ///
  /// The [base] string will be followed by "key=value" pairs from [vars],
  /// separated by spaces and then followed by "key=value" pairs from [opts] where
  /// the value is not empty and ending with [causedBy] appended, if not null.
  String exceptionMessage(String base, MsgVarList vars, MsgVarList opts) {
    bool needsQuote(String v) => v.isEmpty || v.contains(RegExp(r'\s'));

    String valItem(String v) => needsQuote(v) ? "'$v'" : v;

    String varItem(MsgVarDef d) => "${d.n}=${valItem(d.v.toString())}";
    String? optItem(MsgVarDef d) =>
        d.v.toString().isNotEmpty ? varItem(d) : null;

    final varStrings = vars.map(varItem);
    final optStrings = opts.map(optItem).expand((e) => e == null ? [] : [e]);
    final causeString =
        causedBy != null ? "causedBy:${causedBy!.toString()}" : '';

    return "$base:"
            "${varStrings.isEmpty ? '' : ' '}${varStrings.join(' ')}"
            "${optStrings.isEmpty ? '' : ' '}${optStrings.join(' ')}"
            "${causeString.isEmpty ? '' : ' '}$causeString"
        .trim();
  }
}

///  Base class for one our exceptions
class RiverpodBleException with CausedBy implements Exception {
  @override
  final Object? causedBy;

  const RiverpodBleException({this.causedBy});
}

@immutable
class BleConnectionException extends RiverpodBleException {
  final String deviceId;
  final String deviceName;
  final String reason;

  const BleConnectionException(this.deviceId, this.deviceName, this.reason,
      {super.causedBy});

  @override
  String toString() => "Failed to connect to $deviceName ($deviceId): $reason";
}

@immutable
class BleDisconnectException extends BleConnectionException {
  const BleDisconnectException(super.deviceId, super.deviceName, super.reason,
      {super.causedBy});

  @override
  String toString() =>
      "Failed to disconnect from $deviceName ($deviceId):$reason:${super.toString()}";
}

@immutable
class UnknownService extends RiverpodBleException {
  final BleUUID serviceUuid;
  final String deviceId;
  final String name;
  final String? reason;

  const UnknownService(this.serviceUuid, this.deviceId, this.name,
      {this.reason, super.causedBy});

  @override
  String toString() =>
      "Unknown service=$serviceUuid for device=$deviceId/$name $reason";
}

@immutable
class CharacteristicException extends RiverpodBleException {
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  final String deviceId;
  final String deviceName;
  final String? reason;

  const CharacteristicException({
    required this.characteristicUuid,
    required this.serviceUuid,
    required this.deviceId,
    required this.deviceName,
    this.reason,
    super.causedBy,
  });

  @override
  String toString() => exceptionMessage("CharacteristicException:", [
        (n: 'deviceName', v: deviceName),
        (n: 'deviceId', v: deviceId),
        (n: 'serviceUuid', v: serviceUuid),
      ], [
        (n: 'reason', v: reason ?? ''),
      ]);
  // final r = reason != null ? " reason=$reason:" : '';
  // return "$r"
  //     " characteristic=$characteristicUuid"
  //     " serviceUuid=$serviceUuid"
  //     " device=$deviceId/$deviceName";
}

@immutable
class UnknownCharacteristic extends CharacteristicException {
  const UnknownCharacteristic({
    required super.characteristicUuid,
    required super.serviceUuid,
    required super.deviceId,
    required super.deviceName,
    super.reason,
    super.causedBy,
  });

  @override
  String toString() => "Unknown characteristic: ${super.toString()}";
}

@immutable
class FailedToEnableNotification extends CharacteristicException {
  const FailedToEnableNotification(
      {required super.characteristicUuid,
      required super.serviceUuid,
      required super.deviceId,
      required super.deviceName,
      super.reason,
      super.causedBy});

  @override
  String toString() => "Failed to enable notification: ${super.toString()}";
}

@immutable
class ReadingCharacteristicException extends CharacteristicException {
  const ReadingCharacteristicException({
    required super.characteristicUuid,
    required super.serviceUuid,
    required super.deviceId,
    required super.deviceName,
    super.reason,
    super.causedBy,
  });

  @override
  String toString() => "Failed to read characteristic: ${super.toString()}";
}

@immutable
class UnknownDescriptor extends RiverpodBleException {
  final BleUUID descriptorUuid;
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  final String deviceId;
  final String name;

  const UnknownDescriptor(
    this.descriptorUuid,
    this.characteristicUuid,
    this.serviceUuid,
    this.deviceId,
    this.name, {
    super.causedBy,
  });

  @override
  String toString() => "Unknown descriptor=$descriptorUuid"
      " characteristic=$characteristicUuid"
      " service=$serviceUuid for device=$deviceId/$name";
}

/// Predicate that can be used by a class hierarchy that mixes in [CausedBy]
/// to find the cause that is a [BleConnectionException].
bool isBleConnectionCause(o) => o is BleConnectionException;
