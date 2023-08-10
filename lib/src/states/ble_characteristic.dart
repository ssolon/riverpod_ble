import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

part 'ble_characteristic.freezed.dart';

@freezed
class BleCharacteristic with _$BleCharacteristic {
  factory BleCharacteristic({
    required String deviceId,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleCharacteristicProperties properties,
    required List<BleDescriptor> descriptors,
  }) = _BleCharacteristic;
}

@freezed
class BleCharacteristicProperties with _$BleCharacteristicProperties {
  factory BleCharacteristicProperties({
    required bool broadcast,
    required bool read,
    required bool writeWithoutResponse,
    required bool write,
    required bool notify,
    required bool indicate,
    required bool authenticatedSignedWrites,
    required bool extendedProperties,
    required bool notifyEncryptionRequired,
    required bool indicateEncryptionRequired,
  }) = _BleCharateristicProperties;
}

@freezed
class BleDescriptor with _$BleDescriptor {
  factory BleDescriptor({
    required String deviceId,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleUUID descriptorUuid,
  }) = _BleDescriptor;
}
