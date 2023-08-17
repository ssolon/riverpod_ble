import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_connection_status.freezed.dart';

@freezed
class BleConnectionStatus with _$BleConnectionStatus {
  factory BleConnectionStatus.initial() = Initial;
  factory BleConnectionStatus.error(Object error, StackTrace? stackTrace) =
      Error;
  factory BleConnectionStatus.connected() = Connected;
  factory BleConnectionStatus.disconnected() = Disconnected;
}
