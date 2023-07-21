import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_connection_status.dart';

part 'ble_connection_event.freezed.dart';

@freezed
class BleConnectionEvent with _$BleConnectionEvent {
  factory BleConnectionEvent({
    required String deviceId,
    String? name,
    required BleConnectionStatus status,
  }) = _BleConnectionEvent;

  // factory BleConnectionEvent.fromJson(Map<String, dynamic> json) =>
  // _$BleConnectionEventFromJson(json);
}
