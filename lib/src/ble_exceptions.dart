import 'package:flutter/material.dart';
import '../riverpod_ble.dart';

////////////////////////////////////////////////////////////////////////////
/// Exceptions
////////////////////////////////////////////////////////////////////////////

mixin BleDeviceInfo {
  String get deviceId;
  String get deviceName;
}

// Make this not one of our so it gets "foreign" error handling
class UnsupportedByPlatformException implements Exception {
  final String operation;
  final String platform;

  UnsupportedByPlatformException(this.operation, this.platform);

  @override
  String toString() =>
      "Operation=$operation is not supported by platform=$platform";
}

///  Base class for one our exceptions
class RiverpodBleException with CausedBy implements Exception {
  @override
  final Object? causedBy;

// TODO add optional stackTrace so we don't lose it
  // final Object? stackTrace;

  const RiverpodBleException({this.causedBy});
}

@immutable
class BleInitializationError extends RiverpodBleException {
  final String? reason;

  const BleInitializationError({this.reason, super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Initialization exception",
        [
          (n: 'reason', v: maybeUnknown(reason)),
        ],
        [],
      );
}

/// Exception thrown when something that should never happen -- happens.
@immutable
class BleUnexpectedError extends RiverpodBleException {
  final String? reason;

  const BleUnexpectedError({this.reason, super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Unexpected exception",
        [
          (n: 'reason', v: maybeUnknown(reason)),
        ],
        [],
      );
}

@immutable
class BleBluetoothNotAvailableException extends RiverpodBleException {
  final String? reason;
  const BleBluetoothNotAvailableException({this.reason, super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Bluetooth not available",
        [
          (n: 'reason', v: maybeUnknown(reason)),
        ],
        [],
      );
}

@immutable
class BleBluetoothNoAdapter extends BleBluetoothNotAvailableException {
  final String? reason;
  const BleBluetoothNoAdapter({this.reason, super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Bluetooth adapter not available",
        [
          (n: 'reason', v: maybeUnknown(reason)),
        ],
        [],
      );
}

@immutable
class BleBluetoothAdapterNotPowered extends BleBluetoothNotAvailableException {
  const BleBluetoothAdapterNotPowered({super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Bluetooth adapter not powered",
        [],
        [],
      );
}

@immutable
class BleConnectionException extends RiverpodBleException with BleDeviceInfo {
  @override
  final String deviceId;
  @override
  final String deviceName;
  final String reason;

  const BleConnectionException(this.deviceId, this.deviceName, this.reason,
      {super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Connection failure",
        [
          (n: 'reason', v: maybeUnknown(reason)),
          (n: 'deviceName', v: deviceName),
          (n: 'deviceId', v: deviceId),
        ],
        [],
      );
}

@immutable
class BleConnectionRequiresServices extends BleConnectionException {
  const BleConnectionRequiresServices(String deviceId, String deviceName,
      {causedBy})
      : super(deviceId, deviceName, "Connection requires service definitions",
            causedBy: causedBy);
}

@immutable
class BleDisconnectException extends BleConnectionException {
  const BleDisconnectException(super.deviceId, super.deviceName, super.reason,
      {super.causedBy});

  @override
  String formatBase(base) => 'Failed to disconnect';
}

@immutable
class BleServiceFetchException extends RiverpodBleException with BleDeviceInfo {
  @override
  final String deviceId;
  @override
  final String deviceName;
  final String? reason;

  const BleServiceFetchException(this.deviceId, this.deviceName,
      {this.reason, super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Exception fetching services",
        [
          (n: 'deviceName', v: deviceName),
          (n: 'deviceId', v: deviceId),
        ],
        [(n: 'reason', v: reason)],
      );
}

@immutable
class UnknownService extends RiverpodBleException with BleDeviceInfo {
  final BleUUID serviceUuid;
  @override
  final String deviceId;
  @Deprecated('Use deviceName')
  final String name;
  final String? reason;

  @override
  String get deviceName => name;

  const UnknownService(this.serviceUuid, this.deviceId, this.name,
      {this.reason, super.causedBy});

  @override
  String toString() => exceptionMessage(
        "Unknown service",
        [
          (n: 'serviceUuid', v: serviceUuid),
          (n: 'deviceName', v: name),
          (n: 'deviceId', v: deviceId),
        ],
        [
          (n: 'reason', v: reason),
        ],
      );
}

@immutable
class CharacteristicsDiscoverException extends RiverpodBleException
    with BleDeviceInfo {
  final BleUUID serviceUuid;
  @override
  final String deviceId;
  @override
  final String deviceName;
  final String? reason;

  const CharacteristicsDiscoverException({
    required this.serviceUuid,
    required this.deviceId,
    required this.deviceName,
    this.reason,
    super.causedBy,
  });

  @override
  String toString() => exceptionMessage("CharacteristicsDiscoverException", [
        (n: 'deviceName', v: deviceName),
        (n: 'deviceId', v: deviceId),
        (n: 'serviceUuid', v: serviceUuid),
      ], [
        (n: 'reason', v: reason ?? ''),
      ]);
}

@immutable
class CharacteristicException extends RiverpodBleException with BleDeviceInfo {
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  @override
  final String deviceId;
  @override
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
  String toString() => exceptionMessage("CharacteristicException", [
        (n: 'deviceName', v: deviceName),
        (n: 'deviceId', v: deviceId),
        (n: 'serviceUuid', v: serviceUuid),
        (n: 'characteristicUuid', v: characteristicUuid),
      ], [
        (n: 'reason', v: reason ?? ''),
      ]);
}

@immutable
class WritingCharacteristicException extends CharacteristicException {
  const WritingCharacteristicException({
    required super.characteristicUuid,
    required super.serviceUuid,
    required super.deviceId,
    required super.deviceName,
    super.reason,
    super.causedBy,
  });

  @override
  String formatBase(s) => "Failed to write characteristic";
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

  /// Just change the base message and use our super to format
  @override
  String formatBase(s) => super.formatBase('Unknown characteristic');
}

@immutable
class FailedNotificationException extends CharacteristicException {
  const FailedNotificationException(
      {required super.characteristicUuid,
      required super.serviceUuid,
      required super.deviceId,
      required super.deviceName,
      super.reason,
      super.causedBy});

  @override
  String formatBase(base) =>
      super.formatBase("Characteristic notification exception");
}

@immutable
class FailedToEnableNotification extends FailedNotificationException {
  const FailedToEnableNotification(
      {required super.characteristicUuid,
      required super.serviceUuid,
      required super.deviceId,
      required super.deviceName,
      super.reason,
      super.causedBy});

  @override
  String formatBase(base) => super.formatBase("Failed to enable notification");
}

@immutable
class FailedToDisableNotification extends FailedNotificationException {
  const FailedToDisableNotification(
      {required super.characteristicUuid,
      required super.serviceUuid,
      required super.deviceId,
      required super.deviceName,
      super.reason,
      super.causedBy});

  @override
  String formatBase(base) => super.formatBase("Failed to disable notification");
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
  String formatBase(base) => super.formatBase("Failed to read characteristic");
}

@immutable
class GetDescriptorsException extends RiverpodBleException with BleDeviceInfo {
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  @override
  final String deviceId;
  @Deprecated('Use deviceName')
  final String name;
  final String? reason;

  @override
  String get deviceName => name;

  const GetDescriptorsException({
    required this.characteristicUuid,
    required this.serviceUuid,
    required this.deviceId,
    required this.name,
    this.reason,
    super.causedBy,
  });

  @override
  String toString() => exceptionMessage(
        'Get Descriptors exception',
        [
          (n: 'reason', v: (n) => maybeUnknown(reason)),
          (n: 'characteristicUuid', v: characteristicUuid),
          (n: 'serviceUuid', v: serviceUuid),
          (n: 'deviceId', v: deviceId),
          (n: 'deviceName', v: name),
        ],
        [],
      );
}

@immutable
class DescriptorException extends RiverpodBleException with BleDeviceInfo {
  final BleUUID descriptorUuid;
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  @override
  final String deviceId;
  @Deprecated('Use deviceName')
  final String name;
  final String? reason;

  @override
  String get deviceName => name;

  const DescriptorException({
    required this.descriptorUuid,
    required this.characteristicUuid,
    required this.serviceUuid,
    required this.deviceId,
    required this.name,
    this.reason,
    super.causedBy,
  });

  @override
  String toString() => exceptionMessage(
        'Descriptor exception',
        [
          (n: 'reason', v: (n) => maybeUnknown(reason)),
          (n: 'descriptorUuid', v: descriptorUuid),
          (n: 'characteristicUuid', v: characteristicUuid),
          (n: 'serviceUuid', v: serviceUuid),
          (n: 'deviceId', v: deviceId),
          (n: 'deviceName', v: name),
        ],
        [],
      );
}

@immutable
class UnknownDescriptorException extends DescriptorException {
  const UnknownDescriptorException({
    required super.descriptorUuid,
    required super.characteristicUuid,
    required super.serviceUuid,
    required super.deviceId,
    required super.name,
    super.reason,
    super.causedBy,
  });

  @override
  String formatBase(String base) => "Uknown descriptor";
}

@immutable
class UuidDefinitionException extends RiverpodBleException {
  final String yamlFilePath;

  const UuidDefinitionException(this.yamlFilePath, {super.causedBy});

  @override
  String toString() => exceptionMessage(
      "Error reading uuid definition file", [(n: 'path', v: yamlFilePath)], []);
}

@immutable
class BleUuidNameException extends RiverpodBleException {
  final BleUUID uuid;
  final String yamlFilepath;

  const BleUuidNameException(this.uuid, this.yamlFilepath, {super.causedBy});

  @override
  String toString() => exceptionMessage("Error getting name for uuid",
      [(n: "uuid", v: uuid), (n: "path", v: yamlFilepath)], []);
}

@immutable
class BleNameForCharacteristicException extends CharacteristicException
    with BleDeviceInfo {
  BleNameForCharacteristicException({
    required super.characteristicUuid,
    required super.serviceUuid,
    required super.deviceId,
    required super.deviceName,
    super.reason,
    super.causedBy,
  });

  @override
  String formatBase(base) =>
      super.formatBase("Failed to get characteristic name");
}

/// Function to return 'Unknown' for a null value
Object maybeUnknown(v) => v ?? 'Unknown';

/// Predicate that can be used by a class hierarchy that mixes in [CausedBy]
/// to find the cause that is a [BleConnectionException].
bool isBleConnectionCause(o) => o is BleConnectionException;
