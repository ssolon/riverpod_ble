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
  Future<void> initialize() async {
    bluetoothAdapterStateStreamController.add(await FlutterBluePlus.isAvailable
        ? BleBluetoothState.on
        : BleBluetoothState.unknown);

    return Future.value();
  }

  @override
  Future<void> dispose() {
    return Future.value();
  }

  @override
  void startScan(
      {Duration timeout = const Duration(seconds: 30),
      List<BleUUID>? withServices}) {
    final guids = withServices?.map((e) => Guid(e.str)).toList() ?? [];
    FlutterBluePlus.startScan(timeout: timeout, withServices: guids);
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
                name: r.device.platformName,
                services: r.advertisementData.serviceUuids
                    .map((e) => BleUUID(e.uuid128))
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
  String nameOf(BluetoothDevice native) => native.platformName;

  @override
  Future<List<BluetoothService>> servicesFrom(BluetoothDevice native) async {
    return native.servicesList.isEmpty
        ? await native.discoverServices()
        : native.servicesList;
  }

  @override
  Future<List<BluetoothService>> servicesFor(
      String deviceId, String name) async {
    _logger.fine("servicesFor");

    final device = deviceFor(deviceId, name);
    final services = servicesFrom(device);

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
        BmBluetoothDevice(remoteId: deviceId, platformName: name),
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
  Future<BleDevice> connectTo(String deviceId, String deviceName,
      [List<String> services = const <String>[]]) async {
    final native = deviceFor(deviceId, deviceName);
    await native.connect();

    // Version 1.28.9 no long clears services on disconnect or reconnect
    // so we'll always do the discover here
    // We'll probably need it anyway!
    await native.discoverServices();

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
  Future<List<BleService>> bleServicesFor(String deviceId, String name) async {
    try {
      final services = await servicesFor(deviceId, name);
      final result = <BleService>[
        for (final s in services) await bleServiceFrom(s, deviceId, name),
      ];

      return Future.value(result);
    } catch (e) {
      return Future.error(BleServiceFetchException(deviceId, name,
          causedBy: e, reason: 'Discovering services'));
    }
  }

  @override
  Future<List<BluetoothCharacteristic>> characteristicsFor(
      BleUUID serviceUuid, String deviceId, String name) async {
    final device = deviceFor(deviceId, name);
    final service = device.servicesList
        ?.where((e) => BleUUID(e.serviceUuid.toString()) == serviceUuid);
    return Future.value(service != null && service.isNotEmpty
        ? service.first.characteristics
        : <BluetoothCharacteristic>[]);
  }

  @override
  BleCharacteristic bleCharacteristicFrom(
      BluetoothCharacteristic nativeCharacteristic,
      String deviceName,
      BleUUID serviceUuid,
      String deviceId) {
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
    );
  }

  @override
  BleDescriptor bleDescriptorFrom(
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
  FutureOr<BleService> bleServiceFrom(
      BluetoothService nativeService, String deviceId, String deviceName) {
    final s = nativeService;
    final deviceId = s.remoteId.str;
    final serviceUuid = BleUUID(s.serviceUuid.toString());
    return BleService(
      deviceId,
      deviceName,
      serviceUuid,
      [
        for (final c in s.characteristics)
          bleCharacteristicFrom(
            c,
            deviceName,
            serviceUuid,
            deviceId,
          )
      ],
    );
  }

  FutureOr<List<BluetoothDescriptor>> descriptorsFor(BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String deviceName) async {
    final nativeCharacteristic = characteristicFor(
        characteristicUuid, serviceUuid, deviceId, deviceName);
    return descriptorsFrom(await nativeCharacteristic);
  }

  @override
  FutureOr<List<BleDescriptor>> bleDescriptorsFor(BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String deviceName) async {
    final nativeDescriptors = await descriptorsFor(
        characteristicUuid, serviceUuid, deviceId, deviceName);
    return nativeDescriptors
        .map((d) => bleDescriptorFrom(d, deviceName))
        .toList();
  }

  FutureOr<BluetoothDescriptor> descriptorFor(
      BleUUID descriptorUuid,
      BleUUID characteristicUuid,
      BleUUID serviceUuid,
      String deviceId,
      String deviceName) async {
    final descriptors = await descriptorsFor(
        characteristicUuid, serviceUuid, deviceId, deviceName);
    final descriptor =
        descriptors.where((d) => BleUUID(d.uuid.toString()) == descriptorUuid);
    if (descriptor.isEmpty) {
      throw UnknownDescriptorException(
          descriptorUuid: descriptorUuid,
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          name: deviceName);
    }

    return descriptor.first;
  }

  @override
  FutureOr<BleDescriptor> bleDescriptorFor(
      BleUUID descriptorUuid,
      BleUUID characteristicUuid,
      BleUUID serviceUuid,
      String deviceId,
      String deviceName) async {
    final descriptor = await descriptorFor(
        descriptorUuid, characteristicUuid, serviceUuid, deviceId, deviceName);

    return Future.value(bleDescriptorFrom(descriptor, deviceName));
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
  @override
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

  @override
  Future<List<int>> readCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  }) async {
    try {
      final characteristic = await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      // return await readDescriptorMutex.protect(() async {
      final values = await characteristic.read();
      return Future.value(values);
      // });
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

  @override
  Future<void> writeCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required List<int> value,
  }) async {
    try {
      final characteristic = await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      characteristic.write(value);
    } catch (e) {
      return Future.error(CharacteristicException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
        causedBy: e,
        reason: "Write characteristic",
      ));
    }
  }

  @override
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
