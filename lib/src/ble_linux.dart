import 'dart:async';
import 'dart:collection';

import 'package:bluez/bluez.dart';
import 'package:logging/logging.dart';

import 'states/ble_scan_result.dart';
import '../riverpod_ble.dart';

final _log = Logger('BleLinux');

class LinuxBle extends Ble<BlueZDevice, BlueZGattService,
    BlueZGattCharacteristic, BlueZGattDescriptor> {
  BlueZClient? _client;
  BlueZAdapter? _adapter;

  /// Connection to BlueZ streams
  StreamSubscription? _deviceAddedSubscription;
  StreamSubscription? _propertiesChangedSubscription;

  ///////////////////////////////
  /// Scanner
  ///////////////////////////////

  /// Our scanner streams

  final _scannerStatusStreamController = StreamController<bool>.broadcast();
  final _scannerResultsStreamController =
      StreamController<List<BleScannedDevice>>.broadcast();

  // Scanner status variables

  // Dont use _adapter?.discovering as it is not updated until the next event
  bool _isScanning = false;

  Timer? _scanTimeoutTimer;

  @override
  Future<void> initialize() async {
    if (_client == null) {
      _client = BlueZClient();
      await _client?.connect();

      if (_client == null) {
        // FIXME: Proper exception definition
        return Future.error(
            const BleInitializationError(reason: 'Could not connect to BlueZ'));
      }
    }

    final adapters = _client?.adapters ?? [];
    if (adapters.isEmpty) {
      // FIXME: Proper exception definition
      return Future.error(const BleBluetoothNoAdapter(
          reason: 'No bluetooth adapters available'));
    }

    _adapter = adapters[0];

    bluetoothAdapterStateStreamController.add(BleBluetoothState.on);

    _propertiesChangedSubscription = _adapter?.propertiesChanged.listen(
      (events) {
        for (final event in events) {
          _log.finer("Property changed=$event");
          switch (event) {
            case 'Discovering':
              final discovering = _adapter?.discovering ?? false;
              _log.finer('Discovering=$discovering');
              _scannerStatusStreamController.add(discovering);
              _isScanning = discovering;
              break;

            case 'Powered':
              break;

            default:
              _log.warning('Unhandled property changed event: $event');
          }
        }
      },
    );
  }

  @override
  Future<void> dispose() {
    _deviceAddedSubscription?.cancel();
    _propertiesChangedSubscription?.cancel();

    return Future.value();
  }

  @override
  void startScan(
      {Duration timeout = const Duration(seconds: 30),
      List<BleUUID>? withServices}) {
    final Set devices = HashSet<BleScannedDevice>(
        equals: (a, b) => scannedDeviceIdOf(a) == scannedDeviceIdOf(b),
        hashCode: (o) => scannedDeviceIdOf(o).hashCode);

    void addDevice(BleScannedDevice device) {
      if (devices.contains(device)) {
        devices.remove(device);
      }

      devices.add(device);
    }

    // Prevously discovered devices don't show up in scan so add first
    // TODO: Identify those we've connected to and add them as "connected"
    //       devices
    for (final device in _client?.devices ?? []) {
      addDevice(_scannedDeviceFrom(device));
    }

    // Add devices as we discover them

    _deviceAddedSubscription = _client?.deviceAdded.listen((device) {
      _log.finer('Device added: $device/${device.address}}');

      addDevice(_scannedDeviceFrom(device));

      _scannerResultsStreamController
          .add(devices.toList() as List<BleScannedDevice>);
    });

    if (timeout.inSeconds > 0) {
      _scanTimeoutTimer = Timer(timeout, () {
        _log.finer('Scan timeout');
        _adapter?.stopDiscovery();
      });
    }

    _adapter?.setDiscoveryFilter(
        uuids: withServices?.map((e) => e.toString()).toList());

    _adapter?.startDiscovery();
  }

  BleScannedDevice _scannedDeviceFrom(BlueZDevice device) {
    // Create native device entry since we'll want to use it later
    // to connect.

    register(device);

    _log.finest("Scanned device ${device.name}"
        " address=${device.address}"
        " alias=${device.alias}");

    device.manufacturerData.forEach((key, value) {
      _log.finest("  manufacturerData: ${key.id.toRadixString(16)}"
          "=${value.map((e) => e.toRadixString(16)).join(" ")}");
    });

    device.serviceData.forEach((key, value) {
      _log.finest("  serviceData: $key"
          "=${value.map((e) => e.toRadixString(16)).join(" ")}");
    });

    return BleScannedDevice(
      BleDevice.scanned(
        deviceId: device.address,
        name: device.name,
        manufacturerData: device.manufacturerData
            .map((key, value) => MapEntry(key.id, value)),
        serviceData: device.serviceData
            .map((key, value) => MapEntry(BleUUID(key.toString()), value)),
        services: device.uuids.map((e) => BleUUID(e.toString())).toList(),
      ),
      device.rssi,
      DateTime.now(),
      device,
    );
  }

  @override
  void stopScan() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;

    _adapter?.stopDiscovery();
  }

  @override
  Stream<bool> get scannerStatusStream => _scannerStatusStreamController.stream;

  @override
  bool get isScanningNow => _isScanning;

  @override
  Stream<List<BleScannedDevice>> get scannerResults =>
      _scannerResultsStreamController.stream;

  @override
  BleCharacteristic bleCharacteristicFrom(nativeCharacteristic,
      String deviceName, BleUUID serviceUuid, String deviceId) {
    // TODO: implement bleCharacteristicFrom
    throw UnimplementedError("bleCharacteristicFrom");
  }

  @override
  Future<BleDevice> connectTo(String deviceId, String deviceName,
      [List<String> services = const <String>[]]) async {
    final nativeDevice = device(deviceId);
    if (nativeDevice == null) {
      throw UnimplementedError(
          "Connecting to unscanned device not supported yet");
    }

    try {
      await nativeDevice.connect();

      return BleDevice(
        deviceId: deviceId,
        name: deviceName,
        nativeDevice: nativeDevice,
        services: nativeDevice.gattServices
            .map((e) => BleUUID(e.uuid.toString()))
            .toList(),
        status: BleConnectionState.connected(),
      );
    } catch (e) {
      throw BleConnectionException(deviceId, deviceName, "Could not connect",
          causedBy: e);
    }
  }

  @override
  Future<List<BleDevice>> connectedDevices() {
    // TODO: implement connectedDevices
    throw UnimplementedError("connectedDevices");
  }

  @override
  FutureOr<bool> isConnected(String deviceId, String deviceName) {
    final nativeDevice = device(deviceId);
    return nativeDevice?.connected ?? false;
  }

  @override
  FutureOr<BleConnectionState> connectionStatusOf(native) {
    // TODO: implement connectionStatusOf
    throw UnimplementedError("connectionStatusOf");
  }

  @override
  Stream<BleConnectionState> connectionStreamFor(
      String deviceId, String deviceName) {
    final nativeDevice = device(deviceId);
    if (nativeDevice != null) {
      return nativeDevice.propertiesChanged.expand((properties) {
        List<BleConnectionState> states = [];

        for (final property in properties) {
          if (property == "Connected") {
            states.add(nativeDevice.connected
                ? BleConnectionState.connected()
                : BleConnectionState.disconnected());
          }
        }

        return states;
      });
    } else {
      return const Stream<BleConnectionState>.empty();
    }
  }

  @override
  Future<void> disconnectFrom(String deviceId, String deviceName) async {
    final nativeDevice = device(deviceId);

    try {
      await nativeDevice?.disconnect();
    } catch (e) {
      return Future.error(BleConnectionException(
          deviceId, deviceName, "Could not disconnect",
          causedBy: e));
    }
  }

  @override
  FutureOr<BleDescriptor> bleDescriptorFor(
      BleUUID descriptorUuid,
      BleUUID characteristicUuid,
      BleUUID serviceUuid,
      String deviceId,
      String deviceName) {
    // TODO: implement bleDescriptorFor
    throw UnimplementedError("bleDescriptorFor");
  }

  @override
  FutureOr<List<BleDescriptor>> bleDescriptorsFor(BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String deviceName) {
    // TODO: implement bleDescriptorsFor
    throw UnimplementedError("bleDescriptorsFor");
  }

  @override
  BleUUID characteristicUuidFrom(nativeCharacteristic) {
    // TODO: implement characteristicUuidFrom
    throw UnimplementedError("characteristicUuidFrom");
  }

  @override
  Future<List<BlueZGattCharacteristic>> characteristicsFor(
      BleUUID serviceUuid, String deviceId, String name) {
    // TODO: implement characteristicsFor
    throw UnimplementedError("characteristicsFor");
  }

  @override
  BleUUID descriptorUuidFrom(nativeDescriptor) {
    // TODO: implement descriptorUuidFrom
    throw UnimplementedError("descriptorUuidFrom");
  }

  @override
  String deviceIdOf(native) {
    return native.address;
  }

  @override
  String nameOf(native) {
    return native.name;
  }

  @override
  String exceptionDisplayMessage(Object o) {
    return (o is BlueZException) ? o.message : o.toString();
  }

  @override
  nativeFrom({required String deviceId, required String name}) {
    // TODO: implement nativeFrom
    throw UnimplementedError("nativeFrom");
  }

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
    return BleUUID(nativeService.uuid.toString());
  }

  @override
  Future<List<BlueZGattService>> servicesFor(String deviceId, String name) {
    final nativeDevice = device(deviceId);
    if (nativeDevice != null) {
      return servicesFrom(nativeDevice);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<List<BlueZGattService>> servicesFrom(native) {
    return Future.value(native.gattServices);
  }

  @override
  FutureOr<BleService> bleServiceFrom(
      nativeService, String deviceId, String deviceName) {
    return BleService(
      deviceId,
      deviceName,
      BleUUID(nativeService.uuid.toString()),
      [],
      isPrimary: nativeService.primary,
    );
  }

  @override
  Future<List<BleService>> bleServicesFor(String deviceId, String name) async {
    try {
      final nativeServices = await servicesFor(deviceId, name);

      final result = <BleService>[
        for (final s in nativeServices) await bleServiceFrom(s, deviceId, name)
      ];

      return Future.value(result);
    } catch (e) {
      return Future.error(BleConnectionException(
          deviceId, name, "Could not get services",
          causedBy: e));
    }
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
  Future<void> writeCharacteristic(
      {required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid,
      required List<int> value}) {
    // TODO: implement writeCharacteristic
    throw UnimplementedError("writeCharacteristic");
  }
}
