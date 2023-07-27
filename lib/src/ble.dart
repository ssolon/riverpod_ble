import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_ble/src/states/ble_connection_status.dart';
import 'package:simple_logger/simple_logger.dart';
import 'states/ble_device.dart';
import 'states/ble_scan_result.dart';

part 'ble.g.dart';

/// Riverpod access to Bluetooth LE
/// flutter_blue_plus variation

final _ble = _FlutterBluePlusBle();

final _logger = SimpleLogger();

/// Internal state for the Ble module
/// Should be a singleton since it holds device states.
abstract class _Ble<T> {
  /// Keep track of the devices we know about at their native type
  Map<String, T> devices = {};

  /// Register a native device
  T register(T native) => devices.putIfAbsent(deviceIdOf(native), () => native);

  /// Return the native device for [deviceId]
  T? device(String deviceId) {
    return devices[deviceId];
  }

  /// Make a native type from Ble device
  T nativeFrom({required String deviceId, required String name});

  /// Get the devicedId from a native device
  String deviceIdOf(T native);

  /// Get the name from a native device
  String nameOf(T native);

  /// Get the connection status of a native device
  FutureOr<BleConnectionStatus> connectionStatusOf(T native);

  /// Get the service (if present) from a native device
  Future<List<Object>> servicesOf(T native);

  /// Return the device for [deviceId] or create a new one
  T deviceFor(String deviceId, String? name) {
    return switch (device(deviceId)) {
      T d => d,
      _ => register(nativeFrom(deviceId: deviceId, name: name ?? '')),
    };
  }

  /// Create a [BleDevice] for the native device [native]
  Future<BleDevice> bleDeviceFor(T native) async => BleDevice(
        deviceId: deviceIdOf(native),
        name: nameOf(native),
        status: await connectionStatusOf(native),
      );

  /// Connect to a device [deviceId]
  Future<void> connectTo(String deviceId);

  /// Disconnect from device
  Future<void> disconnectFrom(String deviceId, String name);
}

/// FlutterBluePlus variation
class _FlutterBluePlusBle extends _Ble<BluetoothDevice> {
  _FlutterBluePlusBle() {
    // TODO Make this settable somewhere
    // TODO This needs to happen after bluetooth is initialized?
    FlutterBluePlus.setLogLevel(LogLevel.info);
  }

  @override
  String deviceIdOf(BluetoothDevice device) => device.remoteId.str;

  @override
  String nameOf(BluetoothDevice device) => device.localName;

  @override
  Future<List<Object>> servicesOf(BluetoothDevice device) =>
      device.services.toList();

  @override
  FutureOr<BleConnectionStatus> connectionStatusOf(
          BluetoothDevice native) async =>
      Future.value(switch (await native.connectionState.first) {
        BluetoothConnectionState.connecting => BleConnectionStatus.connecting(),
        BluetoothConnectionState.connected => BleConnectionStatus.connected(),
        BluetoothConnectionState.disconnecting =>
          BleConnectionStatus.disconnecting(),
        BluetoothConnectionState.disconnected =>
          BleConnectionStatus.disconnected(),
      });

  @override
  BluetoothDevice nativeFrom(
          {required String deviceId, required String name}) =>
      BluetoothDevice.fromProto(
        BmBluetoothDevice(
            localName: name, remoteId: deviceId, type: BmBluetoothSpecEnum.le),
      );

  @override
  Future<BleDevice> connectTo(String id, {String? name}) async {
    final native = deviceFor(id, name);
    await native.connect();
    return Future.value(bleDeviceFor(native));
  }

  @override
  Future<void> disconnectFrom(String id, String name) async {
    try {
      final native = deviceFor(id, name);
      native.disconnect();
    } catch (e) {
      return Future.error("disconnecFrom $id/$name error=$e");
    }
  }
}

/// Scanner for BLE devices.
///
/// Notifies with [BleScanResult] object which can contain either a list of
/// scanned devices or control information about the state of the scanner.
///
/// Typically you will use [bleScannedDevicesProvider] to receive just the
/// devices that have been found during the scan and [bleScannerStatusProvider]
/// to receive scanner status information.
///
@riverpod
class BleScanner extends _$BleScanner {
  bool _isScanning = false;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _resultsSubscription;

  @override
  BleScanResults build() {
    _statusSubscription = FlutterBluePlus.isScanning.listen(
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

    _resultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      final scannedDevices = results.map((r) {
        _ble.register(r.device);
        return BleScannedDevice(
            BleDevice.scanned(
              deviceId: r.device.remoteId.str,
              name: r.device.localName,
              services: r.advertisementData.serviceUuids,
            ),
            r.rssi,
            r.timeStamp,
            r.device);
      }).toList();
      state = BleScanResults(scannedDevices);
    }, onDone: () {
      _logger.info("BleScanner: done");
    }, onError: (error) {
      _logger.severe("BleScanner: Error=$error");
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
  }

  /// Stop scanning
  void stop() {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
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

/// Creates and handle a connection
@riverpod
class BleConnection extends _$BleConnection {
  @override
  Future<BleDevice> build(String deviceId, String name) async {
    ref.onDispose(() {
      _logger.fine("BleConnection: dispose");
      _ble.disconnectFrom(deviceId, name);
    });

    state = const AsyncValue<BleDevice>.loading();

    try {
      return await _ble.connectTo(deviceId);
    } catch (e) {
      return Future.error("Error connecting to $deviceId/$name = $e");
    }
  }
}
