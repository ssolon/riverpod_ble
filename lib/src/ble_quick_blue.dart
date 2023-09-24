/// Quick Blue version

import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:riverpod_ble/src/states/ble_scan_result.dart';

import '../riverpod_ble.dart';

class QuickBlueBle extends Ble {
  final _devicesSeen = HashSet<BleScannedDevice>(
    equals: (p0, p1) => p0.device == p1.device,
    hashCode: (p0) => p0.device.hashCode,
  );
  final _scannerStatusStreamController = StreamController<bool>.broadcast();

  @override
  BleCharacteristic bleCharacteristicFor(
      nativeCharacteristic, String deviceName) {
    // TODO: implement bleCharacteristicFor
    throw UnimplementedError();
  }

  @override
  bool isScanningNow = false;

  @override
  void startScan({Duration timeout = const Duration(seconds: 30)}) {
    Future.delayed(timeout, () => stopScan());

    _devicesSeen.clear();
    QuickBlue.startScan();
    isScanningNow = true;
    _scannerStatusStreamController.add(true);
  }

  @override
  void stopScan() {
    QuickBlue.stopScan();
    isScanningNow = false;
    _scannerStatusStreamController.add(false);
  }

  @override
  Stream<bool> get scannerStatusStream => _scannerStatusStreamController.stream;

  @override
  Stream<List<BleScannedDevice>> get scannerResults =>
      QuickBlue.scanResultStream.map((r) {
        _devicesSeen.add(
          BleScannedDevice(
              BleDevice.scanned(
                deviceId: r.deviceId,
                name: r.name,
                services: [],
              ),
              r.rssi,
              DateTime.now(),
              r),
        );
        return _devicesSeen.toList(growable: false);
      });

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
  List characteristicsFrom(nativeService) {
    // TODO: implement characteristicsFrom
    throw UnimplementedError();
  }

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName) {
    // TODO: implement connectTo
    throw UnimplementedError();
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
  List descriptorsFrom(nativeCharacteristic) {
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
  Future<List> servicesFrom(native) {
    // TODO: implement servicesFrom
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
      // TODO Does quick_blue have exception base class?
      PlatformException platform => platform.message,
      _ => null,
    };

    // If we didn't get anything fall back on [toString].
    return message ?? o.toString();
  }
}
