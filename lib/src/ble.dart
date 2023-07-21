import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:simple_logger/simple_logger.dart';
import 'states/ble_device.dart';

part 'ble.g.dart';

/// Riverpod access to Bluetooth LE
/// flutter_blue_plus variation

final fb = FlutterBluePlus.instance;
final _logger = SimpleLogger();

@riverpod
class BleScanner extends _$BleScanner {
  StreamSubscription? subscription;

  @override
  List<BleDevice> build() {
    start();
    return <BleDevice>[];
  }

  /// Scanner status
  bool isScanning() => subscription != null;

  /// (Re)start scanning
  void start() {
    _logger.info("Start scanning...");
    stop();

    fb.startScan(timeout: const Duration(seconds: 30));

    subscription = fb.scanResults.listen((results) {
      final scanResult = results
          .map((r) =>
              BleDevice.scanned(r.device.remoteId.str, r.device.localName))
          .toList();
      state = scanResult;
    });
  }

  /// Stop scanning
  void stop() {
    subscription?.cancel();
    subscription = null;
  }
}
