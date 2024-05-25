import 'package:freezed_annotation/freezed_annotation.dart';

import 'ble_device.dart';

part 'ble_scan_result.freezed.dart';

@freezed
class BleScannedDevice with _$BleScannedDevice {
  factory BleScannedDevice(
      BleDevice device, int rssi, DateTime timeStamp, Object nativeDevice,
      [bool? connectable]) = _BleScannedDevice;
}

@freezed
class BleScanResults with _$BleScanResults {
  factory BleScanResults(
    List<BleScannedDevice> devices,
  ) = _BleScanResults;

  factory BleScanResults.initial() = Initial;
  factory BleScanResults.scanStarted() = ScanStarted;
  factory BleScanResults.scanDone() = ScanDone;
}

/// Convenience method to get the deviceId from a BleScannedDevice
String? scannedDeviceIdOf(BleScannedDevice device) {
  return device.device.mapOrNull(
    (value) => value.deviceId.id,
    scanned: (value) => value.deviceId.id,
  );
}
