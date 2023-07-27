import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_connection_status.freezed.dart';

@freezed
class BleConnectionStatus with _$BleConnectionStatus {
  factory BleConnectionStatus.initial() = Initial;
  factory BleConnectionStatus.connecting() = Connecting;
  factory BleConnectionStatus.error(Object error, StackTrace? stackTrace) =
      Error;
  factory BleConnectionStatus.connected() = Connected;
  factory BleConnectionStatus.disconnecting() = Disconnecting;
  factory BleConnectionStatus.disconnected() = Disconnected;
}
