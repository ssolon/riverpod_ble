import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_uuid.dart';
import 'ble_connection_state.dart';

part 'ble_device.freezed.dart';

/// A unique identifier for a BLE device.
///
/// Since the device name can change, we use the device ID to uniquely identify
/// a device and the device name to display to the user.
/// Some platforms don't return the device name when we connect to a device, so
/// we need to store the device name when we scan for devices and pass it back
/// if we want it to be available, from [connectedDevices] for example.
///
@immutable
class BleDeviceId {
  final String id;
  final String name;

  const BleDeviceId(this.id, this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BleDeviceId && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BleDeviceId(id: $id, name: $name)';
}

@freezed
class BleDevice<T> with _$BleDevice {
  factory BleDevice.scanned({
    required BleDeviceId deviceId,
    @Default([]) List<BleUUID> services,
    Map<int, List<int>>? manufacturerData,
    Map<BleUUID, List<int>>? serviceData,
  }) = Scanned;

  factory BleDevice({
    required BleDeviceId deviceId,
    required T nativeDevice,
    @Default([]) List<BleUUID> services,
    Map<int, List<int>>? manufacturerData,
    Map<BleUUID, List<int>>? serviceData,
    required BleConnectionState status,
  }) = _BleDevice;
}
