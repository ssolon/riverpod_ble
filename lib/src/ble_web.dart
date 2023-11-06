import 'dart:async';

import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart' as web;
import 'package:logging/logging.dart';
import 'package:riverpod_ble/riverpod_ble.dart';
import 'package:riverpod_ble/src/states/ble_scan_result.dart';

final _logger = Logger("BleWeb");

// TODO Create a wrapper for web.BluetoothDevice so we can listen to the
// connection stream and maintain the current connection state.
class BleWebDevice {
  final web.BluetoothDevice nativeDevice;
  final _connectionStreamController =
      StreamController<BleConnectionState>.broadcast();

  /// Our current connection state
  BleConnectionState connectionState = BleConnectionState.disconnected();

  BleWebDevice(this.nativeDevice) {
    nativeDevice.connected.listen((connected) {
      connectionState = connected
          ? BleConnectionState.connected()
          : BleConnectionState.disconnected();
      _connectionStreamController.add(connectionState);
    });
  }

  String get id => nativeDevice.id;

  String? get name => nativeDevice.name;

  Stream<BleConnectionState> get connectionStream =>
      _connectionStreamController.stream;
}

class BleWeb extends Ble<BleWebDevice, web.BluetoothService,
    web.BluetoothCharacteristic, web.BluetoothDescriptor> {
  final _webBluetooth = web.FlutterWebBluetooth.instance;

  final _scannerResultsStreamController =
      StreamController<List<BleScannedDevice>>.broadcast();

  final _scannerStatusStreamController = StreamController<bool>.broadcast();
  bool _isScanningNow = false;

  // TODO Turn this into a stream to support adding/removing adapters?
  @override
  Future<void> initialize() async {
    if (!await (_webBluetooth.isAvailable.first)) {
      return Future.error(const BleInitializationError(
          reason: "Web Bluetooth is not available"));
    }

    // Let's print out some stuff to see what's available
    _logger.info("initial: hasScan=${_webBluetooth.hasRequestLEScan}");

    // Let everyone know initialization is complete and bluetooth is available
    // TODO Handle bluetooth state change?
    bluetoothAdapterStateStreamController.add(BleBluetoothState.on);
  }

  @override
  Future<void> dispose() {
    return Future.value();
  }

  @override
  bool get scannerNeedsServiceUuids => true;

  @override
  void startScan(
      {Duration timeout = const Duration(seconds: 30),
      List<String>? withServices}) async {
    _logger.fine("web startScan withServices=$withServices");
    if (_webBluetooth.hasRequestLEScan) {
      // We can do a real scan!
      _logger.info("startScan: can do an LEScan");
    } else {
      _logger.info("startScan: LEScan is not available using requestDevice");

      final services = withServices ?? <String>[];

      _setScanning(true);

      final options = services.isEmpty
          ? web.RequestOptionsBuilder.acceptAllDevices()
          : web.RequestOptionsBuilder(
              [web.RequestFilterBuilder(services: services)]);

      final device = await _webBluetooth.requestDevice(options);

      // Now that we've got it remember it to avoid requestDevice again
      // Will still need to do it the first time

      register(BleWebDevice(device));

      _logger.fine("BleWeb scanner got device=$device");
      _scannerResultsStreamController.add(
        [
          BleScannedDevice(
            BleDevice.scanned(
              deviceId: device.id,
              name: device.name ?? '',
              services: [],
            ),
            0,
            DateTime.now(),
            device,
          ),
        ],
      );

      _setScanning(false);
    }
  }

  void _setScanning(bool isScanning) {
    _isScanningNow = isScanning;
    _scannerStatusStreamController.add(_isScanningNow);
  }

  @override
  void stopScan() {
    // For now since we only implement requestDevice and wait until it's done
    // we don't need to do anything here.
  }

  @override
  Stream<List<BleScannedDevice>> get scannerResults =>
      _scannerResultsStreamController.stream;

  @override
  Stream<bool> get scannerStatusStream => _scannerStatusStreamController.stream;

  @override
  BleCharacteristic bleCharacteristicFrom(
      web.BluetoothCharacteristic nativeCharacteristic,
      String deviceName,
      BleUUID serviceUuid,
      String deviceId) {
    return BleCharacteristic(
        deviceId: deviceId,
        deviceName: deviceName,
        serviceUuid: serviceUuid,
        characteristicUuid: BleUUID(nativeCharacteristic.uuid),
        properties: _blePropertiesFromNative(nativeCharacteristic.properties),
        descriptors: []);
  }

  @override
  BleDescriptor bleDescriptorFor(
      web.BluetoothDescriptor nativeDescriptor, String deviceName) {
    // TODO: implement bleDescriptorFor
    throw UnimplementedError();
  }

  @override
  BleUUID serviceUuidFrom(web.BluetoothService nativeService) =>
      BleUUID(nativeService.uuid);

  @override
  Future<List<web.BluetoothService>> servicesFor(
      String deviceId, String name) async {
    final native = device(deviceId);
    if (native != null) {
      return Future.value(await servicesFrom(native));
    } else {
      return <web.BluetoothService>[];
    }
  }

  @override
  Future<List<web.BluetoothService>?> servicesFrom(BleWebDevice native) async {
    return (await native.nativeDevice.services.first);
  }

  @override
  FutureOr<BleService> bleServiceFrom(web.BluetoothService nativeService,
      String deviceId, String deviceName) async {
    final serviceUuid = serviceUuidFrom(nativeService);

    final bleCharacteristics = (await characteristicsFrom(nativeService))
        .map((s) => bleCharacteristicFrom(s, deviceName, serviceUuid, deviceId))
        .toList(growable: false);

    return BleService(
      deviceId,
      deviceName,
      serviceUuid,
      bleCharacteristics,
      isPrimary: nativeService.isPrimary,
    );
  }

  BleCharacteristicProperties _blePropertiesFromNative(
          web.BluetoothCharacteristicProperties p) =>
      BleCharacteristicProperties(
        broadcast: p.broadcast,
        read: p.read,
        writeWithoutResponse: p.writeWithoutResponse,
        write: p.write,
        notify: p.notify,
        indicate: p.indicate,
        authenticatedSignedWrites: p.authenticatedSignedWrites,
        extendedProperties: false,
        notifyEncryptionRequired: false,
        indicateEncryptionRequired: false,
      );

  @override
  Future<List<BleService>> bleServicesFor(String deviceId, String name) async {
    final services = await servicesFor(deviceId, name);
    return Future.wait(
        services.map((s) async => (bleServiceFrom(s, deviceId, name))));
  }

  @override
  BleUUID characteristicUuidFrom(
          web.BluetoothCharacteristic nativeCharacteristic) =>
      BleUUID(nativeCharacteristic.uuid.toString());

  @override
  Future<List<web.BluetoothCharacteristic>> characteristicsFor(
      BleUUID serviceUuid, String deviceId, String name) async {
    final nativeDevice = device(deviceId);
    // FIXME Throw if no device?
    if (nativeDevice != null) {
      final nativeServices = await servicesFrom(nativeDevice);
      if (nativeServices != null) {
        final nativeService = nativeServices
            .where((e) => BleUUID(e.uuid.toString()) == serviceUuid);
        if (nativeService.isNotEmpty) {
          return characteristicsFrom(nativeService.first);
        }
      }
    }

    return Future.value([]);
  }

  Future<List<web.BluetoothCharacteristic>> characteristicsFrom(
          web.BluetoothService nativeService) async =>
      await nativeService.getCharacteristics();

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName,
      [List<String> services = const <String>[]]) async {
    // We have to do a connectDevice (prompting) unless we've already done that
    var native = device(deviceId);
    if (native == null) {
      if (services.isEmpty) {
        throw BleConnectionRequiresServices(deviceId, deviceName);
      }

      final device =
          await _webBluetooth.requestDevice(web.RequestOptionsBuilder(
        [web.RequestFilterBuilder(name: deviceName, services: services)],
      ));

      native = register(BleWebDevice(device));
    } else {
      await native.nativeDevice.connect();
    }

    return Future.value(bleDeviceFor(native));
  }

  @override
  Future<List<BleDevice>> connectedDevices() {
    // TODO: implement connectedDevices
    throw UnimplementedError();
  }

  @override
  FutureOr<BleConnectionState> connectionStatusOf(BleWebDevice native) =>
      native.connectionState;

  @override
  Stream<BleConnectionState> connectionStreamFor(
      String deviceId, String deviceName) {
    final native = device(deviceId);
    if (native == null) {
      throw BleConnectionException(deviceId, deviceName,
          "Can't get connection stream for unaccessed device");
    }

    return native.connectionStream;
  }

  @override
  BleUUID descriptorUuidFrom(web.BluetoothDescriptor nativeDescriptor) {
    // TODO: implement descriptorUuidFrom
    throw UnimplementedError();
  }

  @override
  List<web.BluetoothDescriptor> descriptorsFrom(
      web.BluetoothCharacteristic nativeCharacteristic) {
    // TODO: implement descriptorsFrom
    throw UnimplementedError();
  }

  @override
  String deviceIdOf(BleWebDevice native) => native.id;

  @override
  Future<void> disconnectFrom(String deviceId, String deviceName) {
    final webDevice = device(deviceId);
    if (webDevice != null) {
      webDevice.nativeDevice.disconnect();
    }

    return Future.value();
  }

  @override
  String exceptionDisplayMessage(Object o) {
    return o.toString();
  }

  @override
  FutureOr<bool> isConnected(String deviceId, String deviceName) {
    final connectionState = device(deviceId)?.connectionState;
    return connectionState == BleConnectionState.connected();
  }

  @override
  // TODO: implement isScanningNow
  bool get isScanningNow => _isScanningNow;

  @override
  String nameOf(BleWebDevice native) => native.name ?? '';

  @override
  BleWebDevice nativeFrom({required String deviceId, required String name}) {
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
  Future<Stream<List<int>>> setNotifyCharacteristic(
      {required bool notify,
      required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) {
    // TODO: implement setNotifyCharacteristic
    throw UnimplementedError();
  }
}
