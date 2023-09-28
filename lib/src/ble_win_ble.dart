import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:win_ble/win_ble.dart' as win;
import 'package:win_ble/win_file.dart';

import '../riverpod_ble.dart';
import 'states/ble_scan_result.dart';

final logger = Logger("BleWinBle");

class BleWinBle extends Ble<win.BleDevice, BleService, win.BleCharacteristic,
    BleDescriptor> {
  /// Native scan results
  StreamSubscription<win.BleDevice>? scannerStream;

  /// Keep track of scanned devices since we get them one by one
  final _devicesSeen = HashSet<BleScannedDevice>(
    equals: (p0, p1) => p0.device == p1.device,
    hashCode: (p0) => p0.device.hashCode,
  );

  /// Stream with scanner status messages
  final _scannerStatusStreamController = StreamController<bool>.broadcast();

  /// Stream with connection status messages
  final _connectionStatusStream = StreamController.broadcast();
  final _connectedDevices = <String>{};

  final _scannerResultsStreamController =
      StreamController<List<BleScannedDevice>>();

  void initialize() async {
    await win.WinBle.initialize(
      serverPath: await WinServer.path,
      enableLog: true,
    );
  }

  @override
  void startScan({Duration timeout = const Duration(seconds: 30)}) {
    _devicesSeen.clear();

    scannerStream = win.WinBle.scanStream.listen(
      (event) {
        logger.fine("ScannerStream event=${event.name}");
        _devicesSeen.add(
          BleScannedDevice(
            BleDevice.scanned(
              deviceId: event.address,
              name: event.name,
              services: event.serviceUuids.map((e) => BleUUID(e)).toList(),
            ),
            int.parse(event.rssi),
            // TODO Parse string -> DateTime
            DateTime.now(),
            event,
          ),
        );
        _scannerResultsStreamController
            .add(_devicesSeen.toList(growable: false));
      },
    );

    win.WinBle.startScanning();
    _scannerStatusStreamController.add(true);
    isScanningNow = true;
  }

  @override
  void stopScan() {
    win.WinBle.stopScanning();
    _scannerStatusStreamController.add(false);
    isScanningNow = false;
  }

  @override
  Stream<bool> get scannerStatusStream => _scannerStatusStreamController.stream;

  @override
  bool isScanningNow = false;

  @override
  Stream<List<BleScannedDevice>> get scannerResults =>
      _scannerResultsStreamController.stream;

  @override
  BleCharacteristic bleCharacteristicFor(
      nativeCharacteristic, String deviceName) {
    // TODO: implement bleCharacteristicFor
    throw UnimplementedError();
  }

  @override
  BleDescriptor bleDescriptorFor(nativeDescriptor, String deviceName) {
    // TODO: implement bleDescriptorFor
    throw UnimplementedError();
  }

  @override
  BleService bleServiceFor(nativeService, String deviceName) {
    // TODO: implement bleServiceFor
    throw UnimplementedError();
  }

  @override
  BleUUID characteristicUuidFrom(nativeCharacteristic) {
    // TODO: implement characteristicUuidFrom
    throw UnimplementedError();
  }

  @override
  List<win.BleCharacteristic> characteristicsFrom(nativeService) {
    // TODO: implement characteristicsFrom
    throw UnimplementedError();
  }

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName) {
    // TODO: implement connectTo
    throw UnimplementedError('connectTo is not implemented for Windows');
  }

  @override
  Future<List<BleDevice>> connectedDevices() {
    // TODO: implement connectedDevices
    throw UnimplementedError();
  }

  @override
  FutureOr<BleConnectionState> connectionStatusOf(native) {
    // TODO: implement connectionStatusOf
    throw UnimplementedError();
  }

  @override
  Stream<BleConnectionState> connectionStreamFor(
      String deviceId, String deviceName) {
    // TODO: implement connectionStreamFor
    throw UnimplementedError();
  }

  @override
  BleUUID descriptorUuidFrom(nativeDescriptor) {
    // TODO: implement descriptorUuidFrom
    throw UnimplementedError();
  }

  @override
  List<BleDescriptor> descriptorsFrom(
      win.BleCharacteristic nativeCharacteristic) {
    // TODO: implement descriptorsFrom
    throw UnimplementedError();
  }

  @override
  String deviceIdOf(native) {
    // TODO: implement deviceIdOf
    throw UnimplementedError();
  }

  @override
  Future<void> disconnectFrom(String deviceId, String deviceName) {
    // TODO: implement disconnectFrom
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> isConnected(String deviceId, String deviceName) {
    // TODO: implement isConnected
    throw UnimplementedError();
  }

  @override
  String nameOf(native) {
    // TODO: implement nameOf
    throw UnimplementedError();
  }

  @override
  nativeFrom({required String deviceId, required String name}) {
    // TODO: implement nativeFrom
    throw UnimplementedError();
  }

  @override
  Future<List<int>> readCharacteristic(
      {required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) {
    // TODO: implement readCharacteristic
    throw UnimplementedError();
  }

  @override
  Future<List<int>> readDescriptor(
      {required String deviceId,
      required String name,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid,
      required BleUUID descriptorUuid}) {
    // TODO: implement readDescriptor
    throw UnimplementedError();
  }

  @override
  BleUUID serviceUuidFrom(nativeService) {
    // TODO: implement serviceUuidFrom
    throw UnimplementedError();
  }

  @override
  Future<List<BleService>> servicesFor(String deviceId, String name) {
    // TODO: implement servicesFor
    throw UnimplementedError();
  }

  @override
  Future<List<BleService>> servicesFrom(win.BleDevice native) {
    // TODO: implement servicesFrom
    throw UnimplementedError();
  }

  @override
  Future<Stream<List<int>>> setNotifyCharacteristic(
      {required bool notify,
      required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) {
    // TODO: implement setNotifyCharacteristic
    throw UnimplementedError();
  }

  @override
  String exceptionDisplayMessage(Object o) {
    final message = switch (o) {
      PlatformException platform => platform.message,
      _ => null,
    };

    // If we didn't get anything fall back on [toString].
    return message ?? o.toString();
  }
}
