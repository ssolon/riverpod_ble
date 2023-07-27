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
    @Default([]) List<Object> services,
    required BleConnectionStatus status,
  }) = _BleDevice;

  factory BleDevice.error({
    required String deviceId,
    String? name,
    required Object error,
    StackTrace? stack,
  }) = Error;
}
