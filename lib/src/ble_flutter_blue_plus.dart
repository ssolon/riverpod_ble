/// FlutterBluePlus variation

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_ble/src/states/ble_scan_result.dart';
import '../riverpod_ble.dart';

final _logger = Logger("FlutterBluePlusBle");

class FlutterBluePlusBle extends Ble<BluetoothDevice, BluetoothService,
    BluetoothCharacteristic, BluetoothDescriptor> {
  FlutterBluePlusBle() {
    // TODO Make this settable somewhere
    // TODO This needs to happen after bluetooth is initialized?
    FlutterBluePlus.setLogLevel(LogLevel.info);
  }

  @override
  void startScan({Duration timeout = const Duration(seconds: 30)}) {
    FlutterBluePlus.startScan(timeout: timeout);
  }

  @override
  void stopScan() => FlutterBluePlus.stopScan();

  @override
  Stream<bool> get scannerStatusStream => FlutterBluePlus.isScanning;

  @override
  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  @override
  Stream<List<BleScannedDevice>> get scannerResults =>
      FlutterBluePlus.scanResults.map(
        (results) => results.map((r) {
          register(r.device);
          return BleScannedDevice(
              BleDevice.scanned(
                deviceId: r.device.remoteId.str,
                name: r.device.localName,
                services: r.advertisementData.serviceUuids
                    .map((e) => BleUUID(e))
                    .toList(),
              ),
              r.rssi,
              r.timeStamp,
              r.device);
        }).toList(),
      );

  @override
  String deviceIdOf(BluetoothDevice native) => native.remoteId.str;

  @override
  String nameOf(BluetoothDevice native) => native.localName;

  @override
  Future<List<BluetoothService>> servicesFrom(BluetoothDevice native) async {
    _logger.fine("servicesFrom");
    // return Future.value((await device.servicesStream.toList()).first);

    final services = native.servicesList ?? await native.discoverServices();

    return Future.value(services);
  }

  @override
  FutureOr<BleConnectionState> connectionStatusOf(
          BluetoothDevice native) async =>
      Future.value(_connectionStateFrom(await native.connectionState.first));

  BleConnectionState _connectionStateFrom(BluetoothConnectionState s) =>
      switch (s) {
        BluetoothConnectionState.connected => BleConnectionState.connected(),
        BluetoothConnectionState.disconnected =>
          BleConnectionState.disconnected(),
        _ => throw const BleDisconnectException(
            '???', '????', "Unknown native connect state"),
      };

  @override
  Stream<BleConnectionState> connectionStreamFor(
      String deviceId, String deviceName) {
    return deviceFor(deviceId, deviceName).connectionState.transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) => sink.add(_connectionStateFrom(data)),
          ),
        );
  }

  @override
  BluetoothDevice nativeFrom(
          {required String deviceId, required String name}) =>
      BluetoothDevice.fromProto(
        BmBluetoothDevice(
            localName: name, remoteId: deviceId, type: BmBluetoothSpecEnum.le),
      );

  @override
  Future<List<BleDevice>> connectedDevices() async {
    final devices = await FlutterBluePlus.connectedSystemDevices;
    final result = <BleDevice>[];
    for (final d in devices) {
      result.add(await bleDeviceFor(d));
    }
    return result;
  }

  @override
  FutureOr<bool> isConnected(String deviceId, String deviceName) async {
    final connected = await connectedDevices();
    _logger.fine("_ble.isConnected checking ${connected.length} devices");
    return connected.any(
      (e) => e.maybeMap((v) => v.deviceId == deviceId, orElse: () => false),
    );
  }

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName) async {
    final native = deviceFor(deviceId, deviceName);
    await native.connect();
    return Future.value(bleDeviceFor(native));
  }

  @override
  Future<void> disconnectFrom(String deviceId, String deviceName) async {
    try {
      final native = deviceFor(deviceId, deviceName);
      native.disconnect();
    } catch (e) {
      return Future.error(
          BleDisconnectException(deviceId, deviceName, '', causedBy: e));
    }
  }

  @override
  Future<List<BleService>> servicesFor(String deviceId, String name) async {
    final native = deviceFor(deviceId, name);

    try {
      final services = await servicesFrom(native);
      final result = <BleService>[
        for (final s in services) bleServiceFor(s, name),
      ];

      return Future.value(result);
    } catch (e) {
      return Future.error(BleServiceFetchException(deviceId, name,
          causedBy: e, reason: 'Discovering services'));
    }
  }

  @override
  BleCharacteristic bleCharacteristicFor(
      BluetoothCharacteristic nativeCharacteristic, String deviceName) {
    final c = nativeCharacteristic;
    final deviceId = c.remoteId.str;

    return BleCharacteristic(
      deviceId: deviceId,
      deviceName: deviceName,
      serviceUuid: BleUUID(c.serviceUuid.toString()),
      characteristicUuid: BleUUID(c.characteristicUuid.toString()),
      properties: BleCharacteristicProperties(
        broadcast: c.properties.broadcast,
        read: c.properties.read,
        writeWithoutResponse: c.properties.writeWithoutResponse,
        write: c.properties.write,
        notify: c.properties.notify,
        indicate: c.properties.indicate,
        authenticatedSignedWrites: c.properties.authenticatedSignedWrites,
        extendedProperties: c.properties.extendedProperties,
        notifyEncryptionRequired: c.properties.notifyEncryptionRequired,
        indicateEncryptionRequired: c.properties.indicateEncryptionRequired,
      ),
      descriptors: [
        for (final d in c.descriptors) bleDescriptorFor(d, deviceName),
      ],
    );
  }

  @override
  BleDescriptor bleDescriptorFor(
      BluetoothDescriptor nativeDescriptor, String deviceName) {
    final d = nativeDescriptor;
    final deviceId = d.remoteId.str;
    return BleDescriptor(
      deviceId: deviceId,
      deviceName: deviceName,
      serviceUuid: BleUUID(d.serviceUuid.toString()),
      characteristicUuid: BleUUID(d.characteristicUuid.toString()),
      descriptorUuid: BleUUID(d.descriptorUuid.toString()),
    );
  }

  @override
  BleService bleServiceFor(BluetoothService nativeService, String deviceName) {
    final s = nativeService;
    final deviceId = s.remoteId.str;
    return BleService(
      deviceId,
      deviceName,
      BleUUID(s.serviceUuid.toString()),
      [for (final c in s.characteristics) bleCharacteristicFor(c, deviceName)],
    );
  }

  /// Getting errors with multiple descriptor reads from different services
  /// so use a Mutex to restrict access to a single call at a time.
  /// Also seems to be a problem when mixing characteristic and descriptor
  /// reads.
  ///
  /// TODO Find out if this is a bug or a "feature" of the underlying library
  /// Some indications online are that only single operations are
  /// possible so this might not be enough.
  /// Maybe this should be per device like the insufficient mutex already
  /// in the flutter_blue_plus underlying library.
  final readDescriptorMutex = Mutex();

  /// Get the values for a descriptor
  Future<List<int>> readDescriptor({
    required String deviceId,
    required String name,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleUUID descriptorUuid,
  }) async {
    // Only allow a single

    _logger.fine('_ble: readDescriptor start $descriptorUuid');
    final descriptor = await descriptorFor(
        descriptorUuid, characteristicUuid, serviceUuid, deviceId, name);

    try {
      return await readDescriptorMutex.protect(() async {
        _logger.fine('_ble: readDescriptor read start $descriptorUuid');
        final values = await descriptor.read();
        _logger.fine('_ble: readDescriptor done $descriptorUuid');
        return Future.value(values);
      });
    } catch (e, t) {
      // TODO !!!! Figure out if descriptor isn't there and have own exception
      return Future.error(DescriptorException(
          descriptorUuid: descriptorUuid,
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          name: name,
          causedBy: e,
          reason: "Read descriptor"));
    }
  }

  Future<List<int>> readCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  }) async {
    try {
      final characteristic = await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      return await readDescriptorMutex.protect(() async {
        final values = await characteristic.read();
        return Future.value(values);
      });
    } catch (e) {
      return Future.error(CharacteristicException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
        causedBy: e,
        reason: "Read characteristic",
      ));
    }
  }

  Future<Stream<List<int>>> setNotifyCharacteristic({
    required bool notify,
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  }) async {
    try {
      final characteristic = await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      return await readDescriptorMutex.protect(() async {
        final notification = await characteristic.setNotifyValue(notify);
        if (notify && !notification) {
          return Future.error(FailedToEnableNotification(
            characteristicUuid: characteristicUuid,
            serviceUuid: serviceUuid,
            deviceId: deviceId,
            deviceName: deviceName,
          ));
        }
        return Future.value(characteristic.onValueReceived);
      });
    } catch (e) {
      return Future.error(ReadingCharacteristicException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
      ));
    }
  }

  @override
  BleUUID characteristicUuidFrom(
          BluetoothCharacteristic nativeCharacteristic) =>
      BleUUID(nativeCharacteristic.uuid.toString());

  @override
  List<BluetoothCharacteristic> characteristicsFrom(
          BluetoothService nativeService) =>
      nativeService.characteristics;

  @override
  BleUUID descriptorUuidFrom(BluetoothDescriptor nativeDescriptor) =>
      BleUUID(nativeDescriptor.descriptorUuid.toString());

  @override
  List<BluetoothDescriptor> descriptorsFrom(
      BluetoothCharacteristic nativeCharacteristic) {
    return nativeCharacteristic.descriptors;
  }

  @override
  BleUUID serviceUuidFrom(BluetoothService nativeService) =>
      BleUUID(nativeService.uuid.toString());

  @override
  String exceptionDisplayMessage(Object o) {
    final message = switch (o) {
      FlutterBluePlusException blue => blue.description,
      PlatformException platform => platform.message,
      _ => null,
    };

    // If we didn't get anything fall back on [toString].
    return message ?? o.toString();
  }
}
