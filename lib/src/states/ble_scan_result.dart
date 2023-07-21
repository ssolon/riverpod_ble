import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_device.dart';

part 'ble_scan_result.freezed.dart';

@freezed
class BleScanResult with _$BleScanResult {
  factory BleScanResult(
    BleDevice device,
    int rssi,
    DateTime timeStamp,
  ) = _BleScanResult;
}
