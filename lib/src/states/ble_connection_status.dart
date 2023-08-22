import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_connection_status.freezed.dart';

@freezed
class BleConnectionState with _$BleConnectionState {
  factory BleConnectionState.initial() = Initial;
  factory BleConnectionState.error(Object error, StackTrace? stackTrace) =
      Error;
  factory BleConnectionState.connected() = Connected;
  factory BleConnectionState.disconnected() = Disconnected;
}
