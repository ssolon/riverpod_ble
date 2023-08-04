import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_service.freezed.dart';

@freezed
class BleService with _$BleService {
  factory BleService(
    String uuid,
  ) = _BleService;
}
