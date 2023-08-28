import 'package:flutter/material.dart';
import '../riverpod_ble.dart';

////////////////////////////////////////////////////////////////////////////
/// Exceptions
////////////////////////////////////////////////////////////////////////////

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
