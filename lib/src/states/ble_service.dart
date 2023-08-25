import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

part 'ble_service.freezed.dart';

@freezed
class BleService with _$BleService {
  factory BleService(
    String deviceId,
    String deviceName,
    BleUUID serviceUuid,
    List<BleCharacteristic> characteristics, {
    @Default(false) bool isPrimary,
  }) = _BleService;
}
