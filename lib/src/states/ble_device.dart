import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_connection_status.dart';

part 'ble_device.freezed.dart';

@freezed
class BleDevice with _$BleDevice {
  factory BleDevice.initial() = Initial;

  factory BleDevice.connecting({required String deviceId}) = Connecting;

  factory BleDevice.scanned({
    required String deviceId,
    String? name,
    @Default([]) List<String> services,
  }) = Scanned;

  factory BleDevice({
    required String deviceId,
    String? name,
    required BleConnectionStatus status,
    @Default([]) List<Object> services,
  }) = _BleDevice;

  factory BleDevice.error({
    required Object error,
    StackTrace? stack,
  }) = Error;
}
