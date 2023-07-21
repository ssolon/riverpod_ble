import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_value_changed.freezed.dart';

@freezed
class BleValueChanged with _$BleValueChanged {
  factory BleValueChanged(
          String deviceId, String characteristicId, Uint8List value) =
      _BleValueChanged;
  factory BleValueChanged.error(Object? error, StackTrace? stackTrace) = Error;
}
