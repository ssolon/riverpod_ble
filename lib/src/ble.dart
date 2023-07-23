import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:simple_logger/simple_logger.dart';
import 'states/ble_device.dart';
import 'states/ble_scan_result.dart';

part 'ble.g.dart';

/// Riverpod access to Bluetooth LE
/// flutter_blue_plus variation

final fb = FlutterBluePlus.instance;
final _logger = SimpleLogger();

@riverpod

/// Scanner for BLE devices.
///
/// Notifies with [BleScanResult] object which can contain either a list of
/// scanned devices or control information about the state of the scanner.
///
/// Typically you will use [bleScannedDevicesProvider] to receive just the
/// devices that have been found during the scan and [bleScannerStatusProvider]
/// to receive scanner status information.
///
class BleScanner extends _$BleScanner {
  bool _isScanning = false;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _resultsSubscription;

  @override
  BleScanResults build() {
    _statusSubscription = fb.isScanning.listen(
      (event) {
        _logger.info("BleScanner: scanning=$event");
        _isScanning = event;
        state = isScanning
            ? BleScanResults.scanStarted()
            : BleScanResults.scanDone();
      },
    );

    // Cleanup
    ref.onDispose(() {
      stop();
      _statusSubscription?.cancel();
    });

    start();

    return BleScanResults.initial();
  }

  /// Scanner status
  bool get isScanning => _isScanning;

  /// (Re)start scanning
  void start() {
    _logger.info("Start scanning...");
    stop();

    _resultsSubscription = fb.scanResults.listen((results) {
      final scannedDevices = results
          .map((r) => BleScannedDevice(
              BleDevice.scanned(
                r.device.remoteId.str,
                r.device.localName,
                r.advertisementData.serviceUuids,
              ),
              r.rssi,
              r.timeStamp))
          .toList();
      state = BleScanResults(scannedDevices);
    }, onDone: () {
      _logger.info("BleScanner: done");
    }, onError: (error) {
      _logger.severe("BleScanner: Error=$error");
    });

    fb.startScan(timeout: const Duration(seconds: 30));
  }

  /// Stop scanning
  void stop() {
    if (fb.isScanningNow) {
      fb.stopScan();
    }

    _resultsSubscription?.cancel();
    _resultsSubscription = null;
  }
}

/// Returns scanned devices as they are found.
///
/// You would usually watch this provider to get only the devices found and
/// none of the status events.
///
/// Watch [bleScannerStatusProvider] for scanner status.
///
/// A rescan can be triggered by:
///         ```ref.invalidate(bleScannerProvider)```
///
@riverpod
class BleScannedDevices extends _$BleScannedDevices {
  @override
  List<BleScannedDevice> build() {
    ref.listen(bleScannerProvider, (previous, next) {
      next.maybeMap((value) {
        state = value.devices;
      }, orElse: () {});
    });

    return [];
  }
}

/// Returns the current status of the scanner as a boolean.
///
/// True for scanning and false for not scanning.
@riverpod
class BleScannerStatus extends _$BleScannerStatus {
  @override
  bool build() {
    ref.listen(bleScannerProvider, (previous, next) {
      next.map<void>(
        (value) {},
        initial: (value) {},
        scanStarted: (value) => state = true,
        scanDone: (value) => state = false,
      );
    });
    return false;
  }
}
