import 'dart:async';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../riverpod_ble.dart';
import 'ble_flutter_blue_plus.dart';
import 'states/ble_scan_result.dart';

part 'ble.g.dart';

/// Riverpod access to Bluetooth LE

final _ble = FlutterBluePlusBle();

final _logger = Logger("RiverpodBLE");

/// Internal state for the Ble module
/// Should be a singleton since it holds device states.
///
/// Types:
///   T = native device type
///   S = native service type
///   C = native characteristic type
///   D = native descriptor type
abstract class Ble<T, S, C, D> {
  /// Scanner

  /// Stream of scanner status (true = scanning)
  Stream<bool> get scannerStatusStream;

  /// Current state of scanner
  bool get isScanningNow;

  /// Stream of [BleScannedDevice] from scanner
  Stream<List<BleScannedDevice>> get scannerResults;

  /// Start the scanner with [timeout] default of 30 seconds
  void startScan({Duration timeout = const Duration(seconds: 30)});

  /// Stop the scanner
  void stopScan();

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
  FutureOr<BleConnectionState> connectionStatusOf(T native);

  /// Get the connection state by deviceId
  FutureOr<bool> isConnected(String deviceId, String deviceName);

  /// Get a stream of connection state
  Stream<BleConnectionState> connectionStreamFor(
      String deviceId, String deviceName);

  /// Get the service (if present) from a native device
  Future<List<S>> servicesFrom(T native);

  /// Return the device for [deviceId] or create a new one
  T deviceFor(String deviceId, String name) {
    return switch (device(deviceId)) {
      T d => d,
      _ => register(nativeFrom(deviceId: deviceId, name: name)),
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
  Future<BleDevice> connectTo(String deviceId, String deviceName);

  /// Return the services for [deviceId]
  Future<List<BleService>> servicesFor(String deviceId, String name);

  /// Disconnect from device
  Future<void> disconnectFrom(String deviceId, String deviceName);

  BleService bleServiceFor(S nativeService, String deviceName);
  BleUUID serviceUuidFrom(S nativeService);

  Future<S> serviceFor(
      BleUUID serviceUuid, String deviceId, String name) async {
    _logger.fine("serviceFor");
    final nativeDevice = nativeFrom(deviceId: deviceId, name: name);
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
      C nativeCharacteristic, String deviceName);

  Future<C> characteristicFor(BleUUID characteristicUuid, BleUUID serviceUuid,
      String deviceId, String name) async {
    _logger.fine("characteristicFor");
    final nativeService = serviceFor(serviceUuid, deviceId, name);
    final characteristics = characteristicsFrom(await nativeService);
    final nativeCharacteristic = characteristics.where(
      (element) => characteristicUuidFrom(element) == characteristicUuid,
    );
    if (nativeCharacteristic.isEmpty) {
      throw UnknownCharacteristic(
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          deviceName: name);
    }

    return Future.value(nativeCharacteristic.first);
  }

  Future<List<int>> readCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  });

  Future<Stream<List<int>>> setNotifyCharacteristic({
    required bool notify,
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  });

  List<D> descriptorsFrom(C nativeCharacteristic);
  BleUUID descriptorUuidFrom(D nativeDescriptor);
  BleDescriptor bleDescriptorFor(D nativeDescriptor, String deviceName);

  Future<D> descriptorFor(BleUUID descriptorUuid, BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String name) async {
    final nativeCharacteristic =
        characteristicFor(characteristicUuid, serviceUuid, deviceId, name);
    final descriptors = descriptorsFrom(await nativeCharacteristic);

    final nativeDescriptor = descriptors.where(
      (element) => descriptorUuidFrom(element) == descriptorUuid,
    );

    if (nativeDescriptor.isEmpty) {
      throw UnknownDescriptorException(
          descriptorUuid: descriptorUuid,
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          name: name);
    }

    return Future.value(nativeDescriptor.first);
  }

  Future<List<int>> readDescriptor({
    required String deviceId,
    required String name,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleUUID descriptorUuid,
  });

  /// Return a user-friendly message for the non RiverpodBleException [e].
  String exceptionDisplayMessage(Object o);
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
    _statusSubscription = _ble.scannerStatusStream.listen(
      (event) {
        _logger.info("BleScanner: scanning=$event");
        _isScanning = event;
        state = _isScanning
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

  /// (Re)start scanning
  void start() {
    _logger.info("Start scanning...");
    stop();

    _resultsSubscription = _ble.scannerResults.listen((results) {
      state = BleScanResults(results);
    }, onDone: () {
      _logger.info("BleScanner: done");
    }, onError: (error) {
      _logger.severe("BleScanner: Error=$error");
    });

    _ble.startScan();
  }

  /// Stop scanning
  void stop() {
    if (_ble.isScanningNow) {
      _ble.stopScan();
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
  Future<BleDevice> build(String deviceId, String deviceName) async {
    _logger.fine('BleConnection: build');
    ref.onDispose(() {
      _logger.fine("BleConnection: dispose");
      disconnect();
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

    return await connect();
  }

  FutureOr<BleDevice> connect() async {
    try {
      final device = await _ble.connectTo(deviceId, deviceName);
      _logger.finest('BleConnection: connected');
      return device;
    } catch (e) {
      return Future.error(BleConnectionException(
          deviceId, deviceName, 'Connecting',
          causedBy: e));
    }
  }

  disconnect() {
    _logger.fine("BleConnection: disconnect from $deviceName/$deviceId");
    _ble.disconnectFrom(deviceId, deviceName);
  }
}

/// Monitor changes in the connection status of [deviceId]
///
/// Recommended usage is to use watch [bleConnectionMonitor] which will create
/// a connection and monitor it to control access to the device.
@riverpod
class BleConnectionMonitor extends _$BleConnectionMonitor {
  @override
  FutureOr<BleConnectionState> build(
    String deviceId,
    String deviceName,
  ) async {
    Stream<BleConnectionState>? states;

    ref.onDispose(() => _logger.fine("BleConnectionMonitor.onDispose"));

    _logger.fine("BleConnectionMonitor.build $deviceId/$deviceName");

    ref.listen(bleConnectionProvider(deviceId, deviceName), (previous, next) {
      next.when(
        data: (data) async {
          // Connected -- listen to status stream for changes if we haven't
          // already set this up

          if (states == null) {
            states = _ble.connectionStreamFor(deviceId, deviceName);

            await for (final s in states!) {
              _logger.fine("BleConnectionMonitor: stream $s");
              state = AsyncData(s);
            }
          }
        },
        loading: () => state = const AsyncLoading(),
        error: (error, stackTrace) {
          state = AsyncError(
              BleConnectionException(deviceId, deviceName, '', causedBy: error),
              stackTrace);
        },
      );
    }, fireImmediately: true);

    return BleConnectionState.unknownState();
  }
}

@riverpod
class BleServicesFor extends _$BleServicesFor {
  final _completer = Completer<List<BleService>>();

  @override
  FutureOr<List<BleService>> build(
    String deviceId,
    String deviceName,
  ) async {
    _logger.finest('bleServicesFor: start');
    ref.listen(bleConnectionProvider(deviceId, deviceName), (previous, next) {
      next.when(
        loading: () {
          _logger.finest('bleServicesFor: loading');
          // state = const AsyncLoading();
        },
        data: (data) async {
          _logger.finest('bleServicesFor: got connection');

          // Connected, discover services
          try {
            final result = await _ble.servicesFor(deviceId, deviceName);
            _logger.finest('bleServicesFor: got services');
            state = AsyncData(result);
          } catch (e, stack) {
            _logger.finest("bleServicesFor: error=$e");
            _fail(e, stack);
          }
        },
        // Error on connection
        error: _fail,
      );
    }, fireImmediately: true);

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

  void _fail(e, t) {
    state = AsyncError(
        BleServiceFetchException(deviceId, deviceName, causedBy: e), t);
  }
}

/// Return a characteristic
@riverpod
class BleCharacteristicFor extends _$BleCharacteristicFor {
  @override
  Future<BleCharacteristic> build({
    required BleUUID characteristicUuid,
    required BleUUID serviceUuid,
    required String deviceId,
    required String deviceName,
  }) async {
    final completer = Completer<BleCharacteristic>();

    try {
      ref.listen(bleServicesForProvider(deviceId, deviceName),
          (previous, next) {
        next.when(
          data: (services) async {
            final s = services.where((e) => e.serviceUuid == serviceUuid);

            if (s.isEmpty) {
              state = AsyncError(
                UnknownService(serviceUuid, deviceId, deviceName),
                StackTrace.current,
              );
            } else {
              try {
                final c = await _ble.characteristicFor(
                  characteristicUuid,
                  serviceUuid,
                  deviceId,
                  deviceName,
                );
                state = AsyncData(_ble.bleCharacteristicFor(c, deviceName));
              } catch (e, t) {
                state = AsyncError(_fail(e), t);
              }
            }
          },
          error: (error, stackTrace) {
            state = AsyncError(_fail(error), stackTrace);
          },
          loading: () {},
        );
      });
    } catch (e, t) {
      state = AsyncError(_fail(e), t);
    }
    return completer.future;
  }

  _fail(e) => CharacteristicException(
      reason: "Exception accessing characteristic",
      causedBy: e,
      characteristicUuid: characteristicUuid,
      serviceUuid: serviceUuid,
      deviceId: deviceId,
      deviceName: deviceName);
}

/// Return the value of a characteristic
@riverpod
class BleCharacteristicValue extends _$BleCharacteristicValue {
  @override
  Future<BleRawValue> build({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required characteristicUuid,
  }) async {
    final completer = Completer<BleRawValue>();

    try {
      ref.listen(
        bleServicesForProvider(deviceId, deviceName),
        (previous, next) {
          next.when(
            data: (services) async {
              _logger.finest('bleCharacteristicValue: got services?');
              final s = services.where((e) => e.serviceUuid == serviceUuid);

              if (s.isEmpty) {
                throw UnknownService(
                  serviceUuid,
                  deviceId,
                  deviceName,
                  reason: "Reading characteristic $characteristicUuid",
                );
              }
              final value = await _ble.readCharacteristic(
                deviceId: deviceId,
                deviceName: deviceName,
                serviceUuid: serviceUuid,
                characteristicUuid: characteristicUuid,
              );
              state = AsyncData(BleRawValue(values: value));
            },
            error: _fail,
            loading: () {
              // ignore
            },
          );
        },
        fireImmediately: true,
      );
    } catch (e, t) {
      state = _fail(e, t);
    }
    return completer.future;
  }

  _fail(e, t) {
    state = AsyncError(
        ReadCharacteristicException(
          causedBy: e,
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          deviceName: deviceName,
        ),
        t);
  }
}

/// Notification for a characteristic
@riverpod
class BleCharacteristicNotification extends _$BleCharacteristicNotification {
  Stream<List<int>>? _notifications;

  @override
  Future<BleRawValue> build({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  }) async {
    final completer = Completer<BleRawValue>();

    ref.onDispose(
      () async {
        _logger.fine(
            "bleCharacteristicNotificationProvider: dispose $characteristicUuid");
        if (_notifications != null) {
          await _ble.setNotifyCharacteristic(
            notify: false,
            characteristicUuid: characteristicUuid,
            serviceUuid: serviceUuid,
            deviceId: deviceId,
            deviceName: deviceName,
          );
        }
      },
    );

    try {
      ref.listen(
        bleCharacteristicForProvider(
            characteristicUuid: characteristicUuid,
            serviceUuid: serviceUuid,
            deviceId: deviceId,
            deviceName: deviceName),
        (previous, next) {
          next.when(
            data: (c) async {
              try {
                _notifications = await _ble.setNotifyCharacteristic(
                  notify: true,
                  characteristicUuid: characteristicUuid,
                  serviceUuid: serviceUuid,
                  deviceId: deviceId,
                  deviceName: deviceName,
                );

                final s = _notifications;
                if (s != null) {
                  await for (final v in s) {
                    state = AsyncData(BleRawValue(values: v));
                  }
                }
              } catch (e, t) {
                state = AsyncError(_fail(e), t);
              }
            },
            error: (e, t) => state = AsyncError(_fail(e), t),
            loading: () {},
          );
        },
      );
    } catch (e, t) {
      state = AsyncError(_fail(e), t);
    }
    return completer.future;
  }

  _fail(e) => FailedToEnableNotification(
        causedBy: e,
        characteristicUuid: characteristicUuid,
        serviceUuid: serviceUuid,
        deviceId: deviceId,
        deviceName: deviceName,
        reason: e.toString(),
      );
}

/// Convert raw value if possible.
///
/// If [f] is provided be used for the conversion otherwise the
/// [PresentationFormat] in [raw] will be used and if that is not present
/// the returned value will be a [BleValue.unsupported].
BleValue convertBleRawValue(BleRawValue raw, [BlePresentationFormat? f]) {
  return BleValue.unsupported(
      raw.values, raw.format?.gattFormat ?? FormatTypes.unknown);
}

/// Return the value of a descriptor
@riverpod
class BleDescriptorValue extends _$BleDescriptorValue {
  @override
  Future<List<int>> build(
    String deviceId,
    String deviceName,
    BleUUID serviceUuid,
    BleUUID characteristicUuid,
    BleUUID descriptorUuid,
  ) async {
    final completer = Completer<List<int>>();

    try {
      _logger.fine("bleDescriptorValue: start $descriptorUuid");

      ref.listen(
        bleServicesForProvider(deviceId, deviceName),
        (previous, next) {
          next.when(
            data: (services) async {
              try {
                _logger
                    .finest('bleDescriptorValue: got services $descriptorUuid');
                final s = services.where((e) => e.serviceUuid == serviceUuid);

                if (s.isEmpty) {
                  throw UnknownService(serviceUuid, deviceId, deviceName,
                      reason: "Reading descriptor $descriptorUuid");
                }
                final value = await _ble.readDescriptor(
                    deviceId: deviceId,
                    name: deviceName,
                    serviceUuid: serviceUuid,
                    characteristicUuid: characteristicUuid,
                    descriptorUuid: descriptorUuid);
                state = AsyncData(value);
              } catch (e, t) {
                state = _fail(e, t);
              }
            },
            error: _fail,
            loading: () => const AsyncLoading(),
          );
        },
        fireImmediately: true,
      );
    } catch (e) {
      state = _fail(e, StackTrace.current);
    }

    return completer.future;
  }

  AsyncValue<List<int>> _fail(e, t) => AsyncError<List<int>>(
      CharacteristicException(
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          deviceName: deviceName,
          reason: 'Reading descriptor value',
          causedBy: e),
      t);
}

/// See if we're connected based on the device information (if any) from [e]
///
/// Return true for connected, false for disconnected or null to don't know.
FutureOr<bool?> bleIsConnectedFromException(Exception e) async {
  BleDeviceInfo? deviceInfo = switch (e) {
    CausedBy c => c.isCaused((o) => o is BleDeviceInfo) as BleDeviceInfo?,
    BleDeviceInfo i => i,
    _ => null,
  };

  if (deviceInfo == null) {
    return null; // don't know
  }

  return await _ble.isConnected(deviceInfo.deviceId, deviceInfo.deviceName);
}

/// Return
Future<String> bleExceptionDisplayMessage(Object e) async {
  if (e is Exception) {
    // Let's start out by just displaying the rootCause

    final root = CausedBy.rootCause(e);
    if (root is RiverpodBleException) {
      // If we're not connected -- nothing else matters so check that first
      final maybeConnected = await bleIsConnectedFromException(e);
      if (maybeConnected != null && !maybeConnected) {
        return "Device is not connected";
      }

      // Connected -- return message from our exception
      // TODO Add "displayMessage" method to RiverpodBleException?
      return root.toString();
    } else {
      // Maybe process as native exception
      return _ble.exceptionDisplayMessage(root);
    }
  }

  // Can't figure anything else just use toString()
  return e.toString();
}
