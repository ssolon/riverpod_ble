import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:bluez/bluez.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'states/ble_scan_result.dart';
import '../riverpod_ble.dart';

final _log = Logger('BleLinux');

class LinuxBle extends Ble<BlueZDevice, BlueZGattService,
    BlueZGattCharacteristic, BlueZGattDescriptor> {
  /// Should we allow exit?
  bool exitWhenRequested = true;

  LinuxBle(this.exitWhenRequested);

  AppLifecycleListener? _lifecycleListener;

  BlueZClient? _client;
  BlueZAdapter? _adapter;

  /// Connection to BlueZ streams
  StreamSubscription? _deviceAddedSubscription;
  StreamSubscription? _deviceRemovedSubscription;
  StreamSubscription? _propertiesChangedSubscription;

  /// Keep track of devices that are currently instantiated as objects known
  /// to the client. Apparently only thosse devices can be connected to.
  ///
  /// Devices are removed from this list when they are removed from BlueZ.

  final Set<BleScannedDevice> _discoveredDevices = HashSet<BleScannedDevice>(
      equals: (a, b) => scannedDeviceIdOf(a) == scannedDeviceIdOf(b),
      hashCode: (o) => scannedDeviceIdOf(o).hashCode);

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

      _lifecycleListener = AppLifecycleListener(
        onExitRequested: () {
          _log.finer("onExitRequested");
          return _exitRequested();
        },
        onStateChange: (AppLifecycleState state) =>
            _log.finer("onStateChange: $state"),
      );
    }

    final adapters = _client?.adapters ?? [];
    if (adapters.isEmpty) {
      // FIXME: Proper exception definition
      return Future.error(const BleBluetoothNoAdapter(
          reason: 'No bluetooth adapters available'));
    }

    _adapter = adapters[0];

    bluetoothAdapterStateStreamController.add(BleBluetoothState.on);

    // Track properties and dispatch events

    _propertiesChangedSubscription = _adapter?.propertiesChanged.listen(
      (events) {
        for (final event in events) {
          _log.finer("Adapter Property changed=$event");
          switch (event) {
            case 'Discovering':
              final discovering = _adapter?.discovering ?? false;
              _log.finer('Adaptper property Discovering=$discovering');
              _scannerStatusStreamController.add(discovering);
              _isScanning = discovering;
              break;

            // TODO: Handle other properties

            case 'Powered':
              break;

            default:
              _log.warning('Unhandled adapter property changed event: $event');
          }
        }
      },
    );

    // Subscribe to device added/removed events

    _deviceAddedSubscription = _client?.deviceAdded.listen((device) {
      _log.finer('Device added: $device/${device.address}}');

      _discoveredDevices.add(_scannedDeviceFrom(device));

      _scannerResultsStreamController.add(_discoveredDevices.toList());
    });

    _deviceRemovedSubscription = _client?.deviceRemoved.listen((device) {
      _log.finer('Device removed: $device/${device.address}}');

      _discoveredDevices.removeWhere(
          (element) => scannedDeviceIdOf(element) == device.address);

      _scannerResultsStreamController.add(_discoveredDevices.toList());
    });

    // Preload currently known devices

    for (final device in _client?.devices ?? []) {
      _discoveredDevices.add(_scannedDeviceFrom(device));
    }
  }

  /// Exit the app if requested after shutting everything down
  /// since Linux or at least BlueZ doesn't do it for us.
  Future<AppExitResponse> _exitRequested() async {
    _log.finer("Exit requested");

    if (exitWhenRequested) {
      await dispose();
      return Future.value(AppExitResponse.exit);
    }

    return Future.value(AppExitResponse.cancel);
  }

  @override
  Future<void> dispose() async {
    _deviceAddedSubscription?.cancel();
    _deviceAddedSubscription = null;

    _deviceRemovedSubscription?.cancel();
    _deviceRemovedSubscription = null;

    _propertiesChangedSubscription?.cancel();
    _propertiesChangedSubscription = null;

    // Disconnect any connected devices

    for (final connectedDevice in devices.values.where((d) => d.connected)) {
      connectedDevice.disconnect();
    }

    _client?.close();
    _client = null;

    return Future.value();
  }

  @override
  void startScan(
      {Duration timeout = const Duration(seconds: 30),
      List<BleUUID>? withServices}) {
    if (timeout.inSeconds > 0) {
      _scanTimeoutTimer = Timer(timeout, () {
        _log.finer('Scan timeout');
        _adapter?.stopDiscovery();
      });
    }

    // TODO: Support more filters?

    _adapter?.setDiscoveryFilter(
        uuids: withServices?.map((e) => e.toString()).toList());

    // Start with everything currently known

    _scannerResultsStreamController.add(_discoveredDevices.toList());

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
        deviceId: BleDeviceId(device.address, device.name),
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
  Future<BleDevice> connectTo(String deviceId, String deviceName,
      {List<String> services = const <String>[],
      int timeoutSeconds = 30}) async {
    final completer = Completer<BleDevice>();

    // Set timer to cancel connection attempt if it takes too long

    final timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      _log.finer("Connection attempt to $deviceId/$deviceName timed out");
      completer.completeError(BleConnectionException(deviceId, deviceName,
          "Connection attempt timed out after $timeoutSeconds seconds"));
    });

    // Check if device is available

    try {
      final available =
          await _deviceAvailable(deviceId, deviceName, Completer<void>());

      if (!available) {
        throw BleConnectionException(
            deviceId, deviceName, "Device not available");
      }
    } catch (e) {
      return Future.error(e);
    }

    final nativeDevice = device(deviceId);
    if (nativeDevice == null) {
      throw BleUnexpectedError(
          reason:
              "Native device not found after being discovered: $deviceId/$deviceName");
    }

    try {
      await nativeDevice.connect();
      return bleDeviceFor(nativeDevice, deviceName);
    } catch (e) {
      throw BleConnectionException(deviceId, deviceName, "Could not connect",
          causedBy: e);
    } finally {
      timeoutTimer.cancel();
    }
  }

  /// Check to if [deviceId] is available
  ///
  /// With the current version of BlueZ we can only connect to devices that
  /// have been discovered so if we haven't discovered the device yet we'll
  /// have to scan for it first.
  ///
  /// [timeout] will end with an error for the device if it is not discovered
  /// within the given time so this method either returns true or throws an
  /// exception.
  FutureOr<bool> _deviceAvailable(
      String deviceId, String deviceName, Completer timeoutCompleter) async {
    bool available = false;

    // Listen for signals from BlueZ about devices being added

    final addedSubscription = _client?.deviceAdded.listen((device) {
      if (device.address == deviceId) {
        _log.finer("_deviceAvailable: Device $deviceId added");
        timeoutCompleter.complete();
      }
    });

    try {
      available = _discoveredDevices
          .where((element) => scannedDeviceIdOf(element) == deviceId)
          .isNotEmpty;

      if (!available) {
        _log.finer("Device $deviceId not discovered yet, starting scan");

        // TODO: Add filter for device address
        startScan();
        await timeoutCompleter.future;

        //  No error means we found it
        available = true;
      }
    } catch (e) {
      throw BleConnectionException(deviceId, deviceName, "Device not found",
          causedBy: e);
    } finally {
      if (_isScanning) {
        stopScan();
      }
      addedSubscription?.cancel();
    }

    return available;
  }

  @override
  Future<List<BleDevice>> connectedDevices() async {
    return Future.wait(
      devices.values
          .where((element) => element.connected)
          .map((e) => bleDeviceFor(e))
          .toList(),
    );
  }

  @override
  FutureOr<bool> isConnected(String deviceId, String deviceName) {
    final nativeDevice = device(deviceId);
    return nativeDevice?.connected ?? false;
  }

  @override
  FutureOr<BleConnectionState> connectionStatusOf(native) {
    return native.connected
        ? BleConnectionState.connected()
        : BleConnectionState.disconnected();
  }

  @override
  Stream<BleConnectionState> connectionStreamFor(
      String deviceId, String deviceName) {
    final nativeDevice = device(deviceId);
    if (nativeDevice != null) {
      return nativeDevice.propertiesChanged.expand((properties) {
        List<BleConnectionState> states = [];

        for (final property in properties) {
          _log.finer(
              "connectionStreamFor $deviceId property changed: $property");
          if (property == "Connected") {
            final connected = nativeDevice.connected;
            _log.finer("connectionStreamFor $deviceId connected=$connected");
            states.add(connected
                ? BleConnectionState.connected()
                : BleConnectionState.disconnected());
          }
        }

        return states;
      });
    } else {
      _log.finer("connectionStreamFor: Device $deviceId not found");
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
  BleUUID descriptorUuidFrom(nativeDescriptor) {
    return BleUUID(nativeDescriptor.uuid.toString());
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
  nativeFrom({required String deviceId, required String name}) {
    // TODO: implement nativeFrom
    throw UnimplementedError("nativeFrom");
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
  Future<List<BlueZGattService>> servicesFrom(native) async {
    final completer = Completer<List<BlueZGattService>>();
    StreamSubscription? subscription;

    if (!native.servicesResolved) {
      subscription = native.propertiesChanged.listen((properties) {
        final resolvedCompleter = completer;
        for (final property in properties) {
          if (property == "ServicesResolved") {
            resolvedCompleter.complete(native.gattServices);
            subscription?.cancel();
          }
        }
      });
    } else {
      completer.complete(native.gattServices);
    }

    return completer.future;
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
  BleUUID characteristicUuidFrom(nativeCharacteristic) {
    return BleUUID(nativeCharacteristic.uuid.toString());
  }

  @override
  Future<List<BlueZGattCharacteristic>> characteristicsFor(
      BleUUID serviceUuid, String deviceId, String name) async {
    final service = await serviceFor(serviceUuid, deviceId, name);
    return Future.value(service.characteristics);
  }

  @override
  BleCharacteristic bleCharacteristicFrom(nativeCharacteristic,
      String deviceName, BleUUID serviceUuid, String deviceId) {
    final flags = nativeCharacteristic.flags;

    return BleCharacteristic(
      deviceId: deviceId,
      deviceName: deviceName,
      serviceUuid: serviceUuid,
      characteristicUuid: characteristicUuidFrom(nativeCharacteristic),
      properties: BleCharacteristicProperties(
        // TODO: Support all flags?
        broadcast: flags.contains(BlueZGattCharacteristicFlag.broadcast),
        read: flags.contains(BlueZGattCharacteristicFlag.read),
        writeWithoutResponse:
            flags.contains(BlueZGattCharacteristicFlag.writeWithoutResponse),
        write: flags.contains(BlueZGattCharacteristicFlag.write),
        notify: flags.contains(BlueZGattCharacteristicFlag.notify),
        indicate: flags.contains(BlueZGattCharacteristicFlag.indicate),
        authenticatedSignedWrites: flags
            .contains(BlueZGattCharacteristicFlag.authenticatedSignedWrites),
        extendedProperties:
            flags.contains(BlueZGattCharacteristicFlag.extendedProperties),
        notifyEncryptionRequired:
            false, //flags.contains(BlueZGattCharacteristicFlag.notifyEncryptionRequired),
        indicateEncryptionRequired:
            false, //flags.contains(BlueZGattCharacteristicFlag.indicateEncryptionRequired),
      ),
    );
  }

/*  BlueZGattCharacteristicFlag
  *broadcast,
  *read,
  *writeWithoutResponse,
  *write,
  *notify,
  *indicate,
  *authenticatedSignedWrites,
  *extendedProperties,
  reliableWrite,
  writableAuxiliaries,
  encryptRead,
  encryptWrite,
  encryptAuthenticatedRead,
  encryptAuthenticatedWrite,
  secureRead,
  secureWrite,
  authorize,
*/
  @override
  Future<Stream<List<int>>> setNotifyCharacteristic(
      {required bool notify,
      required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) async {
    final nativeCharacteristic = await characteristicFor(
        characteristicUuid, serviceUuid, deviceId, deviceName);

    if (notify) {
      try {
        final notifyStream =
            nativeCharacteristic.propertiesChanged.expand((element) {
          _log.finer("characteristic propertiesChanged: $element");

          return element.fold(List<List<int>>.empty(growable: true),
              (results, element) {
            if (element == "Value") {
              results.add(nativeCharacteristic.value);
            }

            return results;
          });
        });

        nativeCharacteristic.startNotify();
        return Future.value(notifyStream);
      } catch (e) {
        return Future.error(FailedToEnableNotification(
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          deviceName: deviceName,
          causedBy: e,
        ));
      }
    } else {
      try {
        nativeCharacteristic.stopNotify();
        return Future.value(const Stream.empty());
      } catch (e) {
        return Future.error(FailedToDisableNotification(
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          deviceName: deviceName,
          causedBy: e,
        ));
      }
    }
  }

  @override
  Future<List<int>> readCharacteristic(
      {required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid}) async {
    try {
      final nativeCharacteristic = characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      return Future.value((await nativeCharacteristic).readValue());
    } catch (e) {
      return Future.error(ReadingCharacteristicException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
        causedBy: e,
      ));
    }
  }

  @override
  Future<void> writeCharacteristic(
      {required String deviceId,
      required String deviceName,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid,
      required List<int> value}) async {
    try {
      final nativeCharacteristic = await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);
      await nativeCharacteristic.writeValue(value);
    } catch (e) {
      return Future.error(WritingCharacteristicException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
        causedBy: e,
      ));
    }
  }

  BleDescriptor bleDescriptorFrom(
      BlueZGattDescriptor nativeDescriptor,
      String deviceName,
      BleUUID serviceUuid,
      BleUUID characteristicUuid,
      String deviceId) {
    return BleDescriptor(
      deviceId: deviceId,
      deviceName: deviceName,
      serviceUuid: serviceUuid,
      characteristicUuid: characteristicUuid,
      descriptorUuid: BleUUID(nativeDescriptor.uuid.toString()),
    );
  }

  FutureOr<BlueZGattDescriptor> descriptorFor(
      BleUUID descriptorUuid,
      BleUUID characteristicUuid,
      BleUUID serviceUuid,
      String deviceId,
      String deviceName) async {
    final descriptors = await descriptorsFor(
        characteristicUuid, serviceUuid, deviceId, deviceName);

    try {
      return descriptors
          .firstWhere((e) => BleUUID(e.uuid.toString()) == descriptorUuid);
    } catch (e) {
      return Future.error(UnknownDescriptorException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        descriptorUuid: descriptorUuid,
        deviceId: deviceId,
        name: deviceName,
        causedBy: e,
      ));
    }
  }

  @override
  FutureOr<BleDescriptor> bleDescriptorFor(
      BleUUID descriptorUuid,
      BleUUID characteristicUuid,
      BleUUID serviceUuid,
      String deviceId,
      String deviceName) async {
    final nativeDescriptor = await descriptorFor(
        descriptorUuid, characteristicUuid, serviceUuid, deviceId, deviceName);

    return bleDescriptorFrom(nativeDescriptor, deviceName, serviceUuid,
        characteristicUuid, deviceId);
  }

  FutureOr<List<BlueZGattDescriptor>> descriptorsFor(BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String deviceName) async {
    try {
      final nativeCharacteristic = await characteristicFor(
          characteristicUuid, serviceUuid, deviceId, deviceName);

      return nativeCharacteristic.descriptors;
    } catch (e) {
      return Future.error(GetDescriptorsException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        name: deviceName,
        reason: "Could not get descriptors",
        causedBy: e,
      ));
    }
  }

  @override
  FutureOr<List<BleDescriptor>> bleDescriptorsFor(BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String deviceName) async {
    final nativeDescriptors = await descriptorsFor(
        characteristicUuid, serviceUuid, deviceId, deviceName);

    return nativeDescriptors
        .map((e) => bleDescriptorFrom(
            e, deviceName, serviceUuid, characteristicUuid, deviceId))
        .toList();
  }

  @override
  Future<List<int>> readDescriptor(
      {required String deviceId,
      required String name,
      required BleUUID serviceUuid,
      required BleUUID characteristicUuid,
      required BleUUID descriptorUuid}) async {
    try {
      final descriptor = descriptorFor(
        descriptorUuid,
        characteristicUuid,
        serviceUuid,
        deviceId,
        name,
      );
      return (await descriptor).readValue();
    } catch (e) {
      return Future.error(DescriptorException(
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        descriptorUuid: descriptorUuid,
        deviceId: deviceId,
        name: name,
        reason: "Could not read descriptor",
        causedBy: e,
      ));
    }
  }

  @override
  String exceptionDisplayMessage(Object o) {
    return (o is BlueZException) ? o.message : o.toString();
  }
}
