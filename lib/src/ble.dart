import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_ble/src/states/ble_connection_status.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:riverpod_ble/riverpod_ble.dart';
import 'states/ble_scan_result.dart';

part 'ble.g.dart';

/// Riverpod access to Bluetooth LE
/// flutter_blue_plus variation

final _ble = _FlutterBluePlusBle();

final _logger = SimpleLogger();

/// Internal state for the Ble module
/// Should be a singleton since it holds device states.
abstract class _Ble<T, S, C, D> {
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
  Future<List<S>> servicesFrom(T native);

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
        nativeDevice: native,
        status: await connectionStatusOf(native),
      );

  /// Connected devices
  Future<List<BleDevice>> connectedDevices();

  /// Connect to a device [deviceId]
  Future<void> connectTo(String deviceId);

  /// Return the services for [deviceId]
  Future<List<BleService>> servicesFor(String deviceId, String name);

  /// Disconnect from device
  Future<void> disconnectFrom(String deviceId, String name);

  BleService bleServiceFor(S nativeService, String? deviceName);
  BleUUID serviceUuidFrom(S nativeService);

  Future<S> serviceFor(
      BleUUID serviceUuid, String deviceId, String? name) async {
    _logger.fine("serviceFor");
    final nativeDevice = nativeFrom(deviceId: deviceId, name: name ?? '');
    final services = await servicesFrom(nativeDevice);
    final nativeService =
        services.where((e) => serviceUuidFrom(e) == serviceUuid);
    if (nativeService.isEmpty) {
      throw UnknownService(serviceUuid, deviceId, name);
    }

    return Future.value(nativeService.toList().first);
  }

  List<C> characteristicsFrom(S nativeService);
  BleUUID characteristicUuidFrom(C nativeCharacteristic);
  BleCharacteristic bleCharacteristicFor(
      C nativeCharacteristic, String? deviceName);

  Future<C> characteristicFor(BleUUID characteristicUuid, BleUUID serviceUuid,
      String deviceId, String? name) async {
    _logger.fine("characteristicFor");
    final nativeService = serviceFor(serviceUuid, deviceId, name);
    final characteristics = characteristicsFrom(await nativeService);
    final nativeCharacteristic = characteristics.where(
      (element) => characteristicUuidFrom(element) == characteristicUuid,
    );
    if (nativeCharacteristic.isEmpty) {
      throw UnknownCharacteristic(
          characteristicUuid, serviceUuid, deviceId, name);
    }

    return Future.value(nativeCharacteristic.first);
  }

  List<D> descriptorsFrom(C nativeCharacteristic);
  BleUUID descriptorUuidFrom(D nativeDescriptor);
  BleDescriptor bleDescriptorFor(D nativeDescriptor);

  Future<D> descriptorFor(BleUUID descriptorUuid, BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String? name) async {
    final nativeCharacteristic =
        characteristicFor(characteristicUuid, serviceUuid, deviceId, name);
    final descriptors = descriptorsFrom(await nativeCharacteristic);

    final nativeDescriptor = descriptors.where(
      (element) => descriptorUuidFrom(element) == descriptorUuid,
    );

    if (nativeDescriptor.isEmpty) {
      throw UnknownDescriptor(
          descriptorUuid, characteristicUuid, serviceUuid, deviceId, name);
    }

    return Future.value(nativeDescriptor.first);
  }
}

/// FlutterBluePlus variation
class _FlutterBluePlusBle extends _Ble<BluetoothDevice, BluetoothService,
    BluetoothCharacteristic, BluetoothDescriptor> {
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
  Future<List<BluetoothService>> servicesFrom(BluetoothDevice device) async {
    _logger.fine("servicesFrom");
    // return Future.value((await device.servicesStream.toList()).first);
    return Future.value(device.servicesList);
  }

  @override
  FutureOr<BleConnectionStatus> connectionStatusOf(
          BluetoothDevice native) async =>
      Future.value(switch (await native.connectionState.first) {
        BluetoothConnectionState.connected => BleConnectionStatus.connected(),
        BluetoothConnectionState.disconnected =>
          BleConnectionStatus.disconnected(),
        _ => throw "Unknown native connect state",
      });

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

  @override
  Future<List<BleService>> servicesFor(String deviceId, String name) async {
    final native = deviceFor(deviceId, name);

    try {
      final services = await native.discoverServices();
      final result = <BleService>[
        for (final s in services) bleServiceFor(s, name),
      ];

      return Future.value(result);
    } catch (e) {
      return Future.error("Error discovering services for $name/$deviceId=$e");
    }
  }

  @override
  BleCharacteristic bleCharacteristicFor(
      BluetoothCharacteristic c, String? deviceName) {
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
        for (final d in c.descriptors) bleDescriptorFor(d),
      ],
    );
  }

  @override
  BleDescriptor bleDescriptorFor(BluetoothDescriptor d) {
    final deviceId = d.remoteId.str;
    return BleDescriptor(
      deviceId: deviceId,
      serviceUuid: BleUUID(d.serviceUuid.toString()),
      characteristicUuid: BleUUID(d.characteristicUuid.toString()),
      descriptorUuid: BleUUID(d.descriptorUuid.toString()),
    );
  }

  @override
  BleService bleServiceFor(BluetoothService s, String? deviceName) {
    final deviceId = s.remoteId.str;
    return BleService(
      deviceId,
      deviceName,
      BleUUID(s.serviceUuid.toString()),
      [for (final c in s.characteristics) bleCharacteristicFor(c, deviceName)],
    );
  }

  /// Getting errors with multiple descriptor reads from different services
  /// so use a Mutex to restrict access to a single call at a time
  /// TODO Find out if this is a bug or a "feature" of the underlying library
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

    _logger.fine('_ble: readDescriptor start');
    final descriptor = await descriptorFor(
        descriptorUuid, characteristicUuid, serviceUuid, deviceId, name);

    try {
      return await readDescriptorMutex.protect(() async {
        _logger.fine('_ble: readDescriptor read start');
        final values = await descriptor.read();
        _logger.fine('_ble: readDescriptor done');
        return Future.value(values);
      });
    } catch (e) {
      return Future.error("Exception reading descriptor $descriptorUuid"
          " for device=$deviceId/$name"
          " service=$serviceUuid"
          " characteristic=$characteristicUuid = $e");
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
              services: r.advertisementData.serviceUuids
                  .map((e) => BleUUID(e))
                  .toList(),
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

/// Returns the connected devices from the native implemention
@riverpod
class BleConnectedDevices extends _$BleConnectedDevices {
  @override
  FutureOr<List<BleDevice>> build() async {
    return await _ble.connectedDevices();
  }
}

/// Creates and handle a connection
@riverpod
class BleConnection extends _$BleConnection {
  @override
  Future<BleDevice> build(String deviceId, String name) async {
    _logger.fine('BleConnection: build');
    ref.onDispose(() {
      _logger.fine("BleConnection: dispose");
      _ble.disconnectFrom(deviceId, name);
    });

    //!!!! Debugging
    ref.onAddListener(() {
      _logger.fine('BleConnection: addListener');
    });
    ref.onRemoveListener(() {
      _logger.fine('BleConnection: removeListener');
    });
    ref.onCancel(() {
      _logger.fine('BleConnection: cancel');
    });
    ref.onResume(() {
      _logger.fine('BleConnection: resume');
    });
    //!!!! Debugging

    state = const AsyncValue<BleDevice>.loading();

    try {
      final device = await _ble.connectTo(deviceId);
      _logger.finest('BleConnection: connected');
      return device;
    } catch (e) {
      return Future.error("Error connecting to $deviceId/$name = $e");
    }
  }
}

/*!!!!
@riverpod
Future<List<BleService>> bleServicesFor(
    BleServicesForRef ref, String deviceId, String name) async {
  final connection = ref.watch(bleConnectionProvider(deviceId, name));
  return connection.map(
    loading: ,
    data: (data) => Future.value(data),
   
   Future.error(
      "bleServicesFor deviceId=$deviceId is not implemented yet");
}
!!!!*/

@riverpod
class BleServicesFor extends _$BleServicesFor {
  final _completer = Completer<List<BleService>>();

  @override
  FutureOr<List<BleService>> build(
    String deviceId,
    String? name,
  ) async {
    _logger.finest('bleServicesFor: start');
    ref.listen(bleConnectionProvider(deviceId, name ?? ''), (previous, next) {
      next.when(
        loading: () {
          _logger.finest('bleServicesFor: loading');
          // state = const AsyncLoading();
        },
        data: (data) async {
          _logger.finest('bleServicesFor: got connection');

          // Connected, discover services
          try {
            final result = await _ble.servicesFor(deviceId, name ?? '');
            _logger.finest('bleServciesFor: got services');
            _completer.complete(result);
          } catch (e) {
            _logger.finest("bleServicesFor: error=$e");
            _completer.completeError(e);
          }
        },
        // Error on connection
        error: (error, stackTrace) =>
            _completer.completeError(error, stackTrace),
      );
    });

    ref.onAddListener(
      () {
        _logger.finest('bleServicesFor: onAddListener');
      },
    );
    ref.onRemoveListener(
      () {
        _logger.finest('bleServicesFor: onRemoveListener');
      },
    );
    ref.onCancel(
      () {
        _logger.finest('bleServicesFor: onCancel');
      },
    );
    ref.onDispose(
      () {
        _logger.finest('bleServicesFor: onDispose');
      },
    );

    _logger.finest("bleServicesFor: done=${_completer.isCompleted}");
    return _completer.future;
  }
}

/// Return the value of a descriptor
@riverpod
class BleDescriptorValue extends _$BleDescriptorValue {
  @override
  Future<List<int>> build(
    String deviceId,
    String? name,
    BleUUID serviceUuid,
    BleUUID characteristicUuid,
    BleUUID descriptorUuid,
  ) async {
    final completer = Completer<List<int>>();

    try {
      _logger.fine("bleDescriptorValue: start");

      ref.listen(
        bleServicesForProvider(deviceId, name),
        (previous, next) {
          next.when(
            data: (services) async {
              _logger.finest('bleDescriptorValue: got services?');
              final s = services.where((e) => e.serviceUuid == serviceUuid);

              if (s.isEmpty) {
                throw UnknownService(serviceUuid, deviceId, name,
                    "Reading descriptor $descriptorUuid");
              }
              final value = Future.value(await _ble.readDescriptor(
                  deviceId: deviceId,
                  name: name ?? '',
                  serviceUuid: serviceUuid,
                  characteristicUuid: characteristicUuid,
                  descriptorUuid: descriptorUuid));
              completer.complete(value);
            },
            error: (error, stackTrace) => throw error,
            loading: () {
              // ignore
            },
          );
        },
      );
    } catch (e) {
      return Future.error(e);
    }

    return completer.future;
  }
}

////////////////////////////////////////////////////////////////////////////
/// Exceptions
////////////////////////////////////////////////////////////////////////////

/// Marker class for one our exceptions
abstract class RiverpodBleException implements Exception {
  const RiverpodBleException();
}

@immutable
class UnknownService extends RiverpodBleException {
  final BleUUID serviceUuid;
  final String deviceId;
  final String? name;
  final String? reason;

  const UnknownService(this.serviceUuid, this.deviceId, this.name,
      [this.reason]);

  @override
  String toString() =>
      "Unknown service=$serviceUuid for device=$deviceId/$name $reason";
}

@immutable
class UnknownCharacteristic extends RiverpodBleException {
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  final String deviceId;
  final String? name;

  const UnknownCharacteristic(
    this.characteristicUuid,
    this.serviceUuid,
    this.deviceId,
    this.name,
  );

  @override
  String toString() => "Unknown characteristic=$characteristicUuid"
      " service=$serviceUuid for device=$deviceId/$name";
}

@immutable
class UnknownDescriptor extends RiverpodBleException {
  final BleUUID descriptorUuid;
  final BleUUID characteristicUuid;
  final BleUUID serviceUuid;
  final String deviceId;
  final String? name;

  const UnknownDescriptor(
    this.descriptorUuid,
    this.characteristicUuid,
    this.serviceUuid,
    this.deviceId,
    this.name,
  );

  @override
  String toString() => "Unknown descriptor=$descriptorUuid"
      " characteristic=$characteristicUuid"
      " service=$serviceUuid for device=$deviceId/$name";
}
