import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import 'package:win_ble/win_ble.dart' as win;
import 'package:win_ble/win_file.dart';

import '../riverpod_ble.dart';
import 'states/ble_scan_result.dart';

final logger = Logger("BleWinBle");

/// Class to hold the state for a device since win_ble doesn't have a stateful
/// object for it.
class WinDevice {
  final String deviceId;
  final String deviceName;
  late final _connectionStreamController =
      StreamController<BleConnectionState>.broadcast();

  BleConnectionState connectionState = BleConnectionState.unknownState();

  WinDevice(this.deviceId, this.deviceName);

  WinDevice.from(BluetoothDevice device)
      : this(device.remoteId.str, device.platformName);

  /// Connection stream for this device
  Stream<BleConnectionState> get connectionStream =>
      _connectionStreamController.stream;

  /// Notification of [BleConnectionState]
  void onConnectionStateChanged(BleConnectionState newState) {
    connectionState = newState;
    _connectionStreamController.add(newState);
  }
}

class BleWinBle
    extends Ble<WinDevice, BleService, win.BleCharacteristic, BleDescriptor> {
  /// Native scan results
  StreamSubscription<win.BleDevice>? scannerStream;

  /// Keep track of scanned devices since we get them one by one
  final _devicesSeen = HashSet<BleScannedDevice>(
    equals: (p0, p1) => p0.device == p1.device,
    hashCode: (p0) => p0.device.hashCode,
  );

  /// Stream with scanner status messages
  final _scannerStatusStreamController = StreamController<bool>.broadcast();

  /// Stream with scanned devices found
  final _scannerResultsStreamController =
      StreamController<List<BleScannedDevice>>();

  /// Stream with connection status messages
  late final _connectionStatusStreamSubscription;

  void initialize() async {
    await win.WinBle.initialize(
      serverPath: await WinServer.path,
      enableLog: true,
    );

    // Listen for connection events
    _connectionStatusStreamSubscription =
        win.WinBle.connectionStream.listen((event) {
      final deviceId = event["device"];
      if (deviceId != null) {
        final bleDevice = maybeDeviceFor(deviceId);
        if (bleDevice != null) {
          bleDevice.onConnectionStateChanged((event['connected'] as bool)
              ? BleConnectionState.connected()
              : BleConnectionState.disconnected());
        }
      }
    });
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
    // Unused: we query the backend for the characteristic
    throw UnimplementedError("bleCharacteristicFor");
  }

  @override
  BleDescriptor bleDescriptorFor(nativeDescriptor, String deviceName) {
    // TODO: implement bleDescriptorFor
    throw UnimplementedError("bleDescriptorFor");
  }

  @override
  BleService bleServiceFor(nativeService, String deviceName) {
    // TODO: implement bleServiceFor
    throw UnimplementedError("bleServiceFor");
  }

  @override
  BleUUID characteristicUuidFrom(nativeCharacteristic) {
    // TODO: implement characteristicUuidFrom
    throw UnimplementedError("setNotifyCharacteristic");
  }

  @override
  List<win.BleCharacteristic> characteristicsFrom(nativeService) {
    // TODO: implement characteristicsFrom
    throw UnimplementedError("characteristicUuidFrom");
  }

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName) async {
    final completer = Completer<BleDevice>();

    try {
      final device = deviceFor(deviceId, deviceName);
      StreamSubscription? connectionSubscription;

      try {
        connectionSubscription = device.connectionStream.listen(
          (event) {
            //TODO  What about re-connection and old stuff in the queue?
            // For now just complete based on whatever comes in

            // Stop listening since this is a one-shot
            connectionSubscription?.cancel();

            completer.complete(bleDeviceFor(device));
          },
        );
      } catch (e, t) {
        completer.completeError(e, t);
      }

      win.WinBle.connect(device.deviceId);

      // Wait for the status to go through our connection stream
    } catch (e, t) {
      completer.completeError(e, t);
    }

    return completer.future;
  }

  @override
  Future<List<BleDevice>> connectedDevices() {
    final results = devices.values
        .where((e) => connectionStatusOf(e) is Connected)
        .map((d) async => await bleDeviceFor(d));

    return Future.wait(results);
  }

  @override
  FutureOr<BleConnectionState> connectionStatusOf(native) {
    return native.connectionState;
  }

  @override
  Stream<BleConnectionState> connectionStreamFor(
          String deviceId, String deviceName) =>
      deviceFor(deviceId, deviceName).connectionStream;

  @override
  BleUUID descriptorUuidFrom(nativeDescriptor) {
    // TODO: implement descriptorUuidFrom
    throw UnimplementedError("descriptorUuidFrom");
  }

  @override
  List<BleDescriptor> descriptorsFrom(
      win.BleCharacteristic nativeCharacteristic) {
    // TODO: implement descriptorsFrom
    throw UnimplementedError("descriptorsFrom");
  }

  @override
  String deviceIdOf(WinDevice native) => native.deviceId;

  /// It appears that WinBle will add a disconnect event to the stream
  /// before the disconnect even finishes!
  @override
  Future<void> disconnectFrom(String deviceId, String deviceName) async {
    try {
      await win.WinBle.disconnect(deviceId);
      // TODO Should we delete the WinDevice if it was disconnected?
    } catch (e) {
      throw BleDisconnectException(deviceId, deviceName, "", causedBy: e);
    }
  }

  @override
  FutureOr<bool> isConnected(String deviceId, String deviceName) {
    return maybeDeviceFor(deviceId)?.connectionState ==
        BleConnectionState.connected();
  }

  @override
  String nameOf(WinDevice native) => native.deviceName;

  @override
  WinDevice nativeFrom({required String deviceId, required String name}) =>
      WinDevice(deviceId, name);

  @override
  Future<List<int>> readCharacteristic(
      {required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) {
    // TODO: implement readCharacteristic
    throw UnimplementedError("readCharacteristic");
  }

  @override
  Future<List<int>> readDescriptor(
      {required String deviceId,
      required String name,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid,
      required BleUUID descriptorUuid}) {
    // TODO: implement readDescriptor
    throw UnimplementedError("readDescriptor");
  }

  @override
  BleUUID serviceUuidFrom(nativeService) {
    // TODO: implement serviceUuidFrom
    throw UnimplementedError("serviceUuidFrom");
  }

  @override
  Future<List<BleService>> servicesFor(String deviceId, String name) async {
    //TODO Store service information in WinDevice?
    return Future.value((await win.WinBle.discoverServices(deviceId))
        .map(
          (e) => BleService(deviceId, name, BleUUID(e), []),
        )
        .toList());
  }

  @override
  Future<List<BleService>> servicesFrom(WinDevice native) {
    // Unused: we query for services when needed
    throw UnimplementedError("servicesFrom");
  }

  @override
  Future<Stream<List<int>>> setNotifyCharacteristic(
      {required bool notify,
      required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) {
    // TODO: implement setNotifyCharacteristic
    throw UnimplementedError("setNotifyCharacteristic");
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
