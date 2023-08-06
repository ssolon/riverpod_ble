import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_uuid.dart';
import 'ble_connection_status.dart';

part 'ble_device.freezed.dart';

@freezed
class BleDevice with _$BleDevice {
  factory BleDevice.initial() = Initial;
  factory BleDevice.connecting({required String deviceId}) = Connecting;

  factory BleDevice.scanned({
    required String deviceId,
    String? name,
    @Default([]) List<BleUUID> services,
  }) = Scanned;

  factory BleDevice({
    required String deviceId,
    String? name,
    @Default([]) List<BleUUID> services,
    required BleConnectionStatus status,
  }) = _BleDevice;

  factory BleDevice.error({
    required String deviceId,
    String? name,
    required Object error,
    StackTrace? stack,
  }) = Error;
}
