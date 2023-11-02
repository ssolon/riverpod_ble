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
  List<WinBleService>? services;

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

// Our "native" service since there really isn't one in the backend
class WinBleService {
  final String deviceId;
  final String deviceName;
  final BleUUID serviceUuid;
  List<WinBleCharacteristic>? characteristics;

  WinBleService(this.deviceId, this.deviceName, this.serviceUuid,
      [this.characteristics]);
}

/// Our "native" characteristic since the real one lacks some stuff we want
class WinBleCharacteristic {
  final String deviceId;
  final String deviceName;
  final BleUUID serviceUuid;
  final BleUUID characteristicUuid;
  final BleCharacteristicProperties properties;

  WinBleCharacteristic({
    required this.deviceId,
    required this.deviceName,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.properties,
  });
}

class BleWinBle
    extends Ble<WinDevice, WinBleService, WinBleCharacteristic, BleDescriptor> {
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
      StreamController<List<BleScannedDevice>>.broadcast();

  /// Stream subscription with bluetooth state messages
  late final StreamSubscription? _bluetoothStateStreamSubscription;

  /// Stream subscription with connection status messages
  late final StreamSubscription? _connectionStatusStreamSubscription;

  @override
  Future<void> initialize() async {
    logger.fine("ble.initialize: setup subscriptions");

    // Listen for bluetooth state
    _bluetoothStateStreamSubscription = win.WinBle.bleState.listen(
      (event) => bluetoothAdapterStateStreamController.add(
        switch (event) {
          win.BleState.On => BleBluetoothState.on,
          win.BleState.Off => BleBluetoothState.off,
          win.BleState.Unknown => BleBluetoothState.unknown,
          win.BleState.Disabled => BleBluetoothState.disabled,
          win.BleState.Unsupported => BleBluetoothState.unsupported,
        },
      ),
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

    logger.fine("ble.initialize: starting");
    await win.WinBle.initialize(
      serverPath: await WinServer.path,
      enableLog: true,
    );
  }

  @override
  Future<void> dispose() {
    _bluetoothStateStreamSubscription?.cancel();
    _connectionStatusStreamSubscription?.cancel();
    win.WinBle.dispose();
    return Future.value();
  }

  @override
  void startScan(
      {Duration timeout = const Duration(seconds: 30),
      List<String>? withServices}) {
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
  BleCharacteristic bleCharacteristicFrom(nativeCharacteristic, deviceName) {
    final props = nativeCharacteristic.properties;

    return BleCharacteristic(
      deviceId: nativeCharacteristic.deviceId,
      deviceName: nativeCharacteristic.deviceName,
      serviceUuid: nativeCharacteristic.serviceUuid,
      characteristicUuid: characteristicUuidFrom(nativeCharacteristic),
      properties: BleCharacteristicProperties(
        broadcast: props.broadcast,
        read: props.read,
        writeWithoutResponse: props.writeWithoutResponse,
        write: props.write,
        notify: props.notify,
        indicate: props.indicate,
        authenticatedSignedWrites: props.authenticatedSignedWrites,
        extendedProperties: false,
        notifyEncryptionRequired: false,
        indicateEncryptionRequired: false,
        // TODO Support these?
        // reliableWrite: c.reliableWrite,
        // writableAuxiliaries: c.writableAuxiliaries,
      ),
      descriptors: [],
    );
  }

  @override
  BleDescriptor bleDescriptorFor(nativeDescriptor, String deviceName) {
    // TODO: implement bleDescriptorFor
    throw UnimplementedError("bleDescriptorFor");
  }

  List<BleCharacteristic> bleCharacteristicsFrom(WinBleService nativeService) {
    return List<BleCharacteristic>.from(nativeService.characteristics
            ?.map((e) => bleCharacteristicFrom(e, e.deviceName)) ??
        <BleCharacteristic>[]);
  }

  @override
  BleService bleServiceFrom(WinBleService nativeService, String deviceName) =>
      BleService(
        nativeService.deviceId,
        nativeService.deviceName,
        nativeService.serviceUuid,
        bleCharacteristicsFrom(nativeService),
      );

  @override
  BleUUID characteristicUuidFrom(nativeCharacteristic) =>
      nativeCharacteristic.characteristicUuid;

  @override
  Future<List<WinBleCharacteristic>> characteristicsFor(
      BleUUID serviceUuid, String deviceId, String name) async {
    final service = await serviceFor(serviceUuid, deviceId, name);

    if (service.characteristics == null || service.characteristics!.isEmpty) {
      final nativeCharacteristics = await win.WinBle.discoverCharacteristics(
          address: deviceId, serviceId: serviceUuid.str);

      logger.finest(
          "characteristicsFor: service=$serviceUuid results=${nativeCharacteristics.length}");

      service.characteristics = nativeCharacteristics
          .map((c) => WinBleCharacteristic(
                deviceId: deviceId,
                deviceName: name,
                serviceUuid: serviceUuid,
                characteristicUuid: BleUUID(c.uuid),
                properties: BleCharacteristicProperties(
                  broadcast: c.properties.broadcast ?? false,
                  read: c.properties.read ?? false,
                  writeWithoutResponse:
                      c.properties.writeWithoutResponse ?? false,
                  write: c.properties.write ?? false,
                  notify: c.properties.notify ?? false,
                  indicate: c.properties.indicate ?? false,
                  authenticatedSignedWrites:
                      c.properties.authenticatedSignedWrites ?? false,
                  extendedProperties: false,
                  notifyEncryptionRequired: false,
                  indicateEncryptionRequired: false,
                  // TODO Support these?
                  // reliableWrite: c.reliableWrite,
                  // writableAuxiliaries: c.writableAuxiliaries,
                ),
              ))
          .toList();

      logger.finest("characteristicsFor: added");
    }

    return Future.value(service.characteristics);
  }

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName,
      [List<String> services = const <String>[]]) async {
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
      WinBleCharacteristic nativeCharacteristic) {
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
      // TODO Might be a good idea now that we store services
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
      required BleUUID characteristicUuid}) async {
    return await win.WinBle.read(
        address: deviceId,
        serviceId: serviceUuid.str,
        characteristicId: characteristicUuid.str);
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
  BleUUID serviceUuidFrom(nativeService) => nativeService.serviceUuid;

  @override
  Future<List<WinBleService>> servicesFor(String deviceId, String name) async {
    final device = deviceFor(deviceId, name);

    device.services ??= (await win.WinBle.discoverServices(deviceId))
        .map(
          (e) => WinBleService(deviceId, name, BleUUID(e)),
        )
        .toList();

    return Future.value(device.services);
  }

  @override
  Future<List<BleService>> bleServicesFor(String deviceId, String name) async {
    final nativeServices = await servicesFor(deviceId, name);
    return nativeServices
        .map((s) => BleService(
              s.deviceId,
              s.deviceName,
              s.serviceUuid,
              (s.characteristics ?? [])
                  .map((e) => bleCharacteristicFrom(e, name))
                  .toList(),
            ))
        .toList();
  }

  @override
  Future<List<WinBleService>> servicesFrom(WinDevice native) {
    // Unused: we query for services when needed
    throw UnimplementedError("servicesFrom");
  }

  @override
  Future<Stream<List<int>>> setNotifyCharacteristic(
      {required bool notify,
      required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) async {
    try {
      await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      if (notify) {
        await win.WinBle.subscribeToCharacteristic(
            address: deviceId,
            serviceId: serviceUuid.str,
            characteristicId: characteristicUuid.str);
        return win.WinBle.characteristicValueStreamOf(
                address: deviceId,
                serviceId: serviceUuid.str,
                characteristicId: characteristicUuid.str)
            .map(
          (value) {
            return List<int>.from(value);
          },
        );
      } else {
        await win.WinBle.unSubscribeFromCharacteristic(
            address: deviceId,
            serviceId: serviceUuid.str,
            characteristicId: characteristicUuid.str);
        // TODO Separate to subscribe/unsubscribe so we don't pass back dummy?
        return Future.value(StreamController<List<int>>().stream);
      }
    } catch (e) {
      return Future.error(FailedToEnableNotification(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
        reason: notify
            ? "Subscribing to characteristic"
            : "Unsubscribing from characteristic",
        causedBy: e,
      ));
    }
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
