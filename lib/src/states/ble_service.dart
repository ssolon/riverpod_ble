import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

part 'ble_service.freezed.dart';

@freezed
class BleService with _$BleService {
  factory BleService(
    BleUUID uuid,
  ) = _BleService;
}
