import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_uuid.dart';
import 'ble_connection_state.dart';

part 'ble_device.freezed.dart';

@freezed
class BleDevice<T> with _$BleDevice {
  factory BleDevice.scanned({
    required String deviceId,
    required String name,
    @Default([]) List<BleUUID> services,
    Map<int, List<int>>? manufacturerData,
    Map<BleUUID, List<int>>? serviceData,
  }) = Scanned;

  factory BleDevice({
    required String deviceId,
    required String name,
    required T nativeDevice,
    @Default([]) List<BleUUID> services,
    Map<int, List<int>>? manufacturerData,
    Map<BleUUID, List<int>>? serviceData,
    required BleConnectionState status,
  }) = _BleDevice;
}
