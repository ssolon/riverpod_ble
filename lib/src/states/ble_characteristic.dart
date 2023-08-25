import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

part 'ble_characteristic.freezed.dart';
part 'ble_characteristic.g.dart';

@freezed
class BleCharacteristic with _$BleCharacteristic {
  factory BleCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleCharacteristicProperties properties,
    required List<BleDescriptor> descriptors,
  }) = _BleCharacteristic;

  factory BleCharacteristic.fromJson(Map<String, dynamic> json) =>
      _$BleCharacteristicFromJson(json);
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

  factory BleCharacteristicProperties.fromJson(Map<String, dynamic> json) =>
      _$BleCharacteristicPropertiesFromJson(json);
}

@freezed
class BleDescriptor with _$BleDescriptor {
  factory BleDescriptor({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleUUID descriptorUuid,
  }) = _BleDescriptor;

  factory BleDescriptor.fromJson(Map<String, dynamic> json) =>
      _$BleDescriptorFromJson(json);
}
