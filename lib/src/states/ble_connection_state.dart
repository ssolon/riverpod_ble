import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_connection_state.freezed.dart';

@freezed
class BleConnectionState with _$BleConnectionState {
  factory BleConnectionState.unknownState() = UnknownState;
  factory BleConnectionState.error(Object error, StackTrace? stackTrace) =
      ConnectionStateError;
  factory BleConnectionState.connected() = Connected;
  factory BleConnectionState.disconnected() = Disconnected;
}
