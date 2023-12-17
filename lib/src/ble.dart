import 'dart:async';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../riverpod_ble.dart';
import 'states/ble_scan_result.dart';

// Can't build web with other backends so use conditional import to choose
import 'non_web_backend.dart' if (dart.library.html) 'web_backend.dart';

part 'ble.g.dart';

/// Riverpod access to Bluetooth LE

enum Backend {
  flutterBluePlus,
  winBle,
  webBle,
  linuxBle,
}

/// States that Bluetooth controller can be in
enum BleBluetoothState {
  on,
  off,
  unknown,
  disabled,
  unsupported,
}

/// Stream with bluetooth adapter state information
final bluetoothAdapterStateStreamController =
    StreamController<BleBluetoothState>.broadcast();

logItem(n, o) => o == null ? "" : " $n={$o}";

defaultLogRecord(LogRecord record) =>
    // ignore: avoid_print
    print("${record.time}: ${record.level.name}:"
        " ${record.loggerName}"
        " ${record.message}"
        "${logItem('error', record.error)}"
        "${logItem('stackTrace', record.stackTrace)}");

Future<void> riverpodBleInit({
  Backend? backend,
  void Function(LogRecord) logRecord = defaultLogRecord,
  Level rootLoggingLevel = Level.ALL,
}) async {
  Logger.root.onRecord.listen(logRecord);
  Logger.root.level = rootLoggingLevel;

  _ble = setupBackend();
}

late Ble _ble; // = FlutterBluePlusBle();

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
  /// Call before doing anything else
  Future<void> initialize();

  /// Call when you're done
  Future<void> dispose();

  /// Scanner

  bool get scannerNeedsServiceUuids => false;

  /// Does a connection request require service uuids?
  ///
  /// Similar to [scannerNeedsServiceUuids] some backends (e.g. web) for
  /// security reasons, require that the uuids of the service that will be
  /// accessed be provided when connecting to a device.
  bool get connectionRequiresServiceUuids => false;

  /// Stream of scanner status (true = scanning)
  Stream<bool> get scannerStatusStream;

  /// Current state of scanner
  bool get isScanningNow;

  /// Stream of [BleScannedDevice] from scanner
  Stream<List<BleScannedDevice>> get scannerResults;

  /// Start the scanner with [timeout] default of 30 seconds
  /// and filtering by [withServices] which may be required if
  /// [scannerNeedsServiceUuids] is true.
  void startScan(
      {Duration timeout = const Duration(seconds: 30),
      List<BleUUID>? withServices});

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

  /// Get the services (if present) from a native device
  Future<List<S>?> servicesFrom(T native);

  /// Return the device for [deviceId] or [null]
  /// FIXME Why is this here when we have [device(deviceId)]
  T? maybeDeviceFor(String deviceId) => device(deviceId);

  /// Return the device for [deviceId] or create a new one
  T deviceFor(String deviceId, String name) {
    return switch (maybeDeviceFor(deviceId)) {
      T d => d,
      _ => register(nativeFrom(deviceId: deviceId, name: name)),
    };
  }

  /// Create a [BleDevice] for the native device [native]
  // TODO This should be deviceFrom to be consistent with other names
  Future<BleDevice> bleDeviceFor(T native) async => BleDevice(
        deviceId: deviceIdOf(native),
        name: nameOf(native),
        nativeDevice: native,
        status: await connectionStatusOf(native),
      );

  /// Connected devices
  Future<List<BleDevice>> connectedDevices();

  /// Connect to a device [deviceId]
  ///
  /// Some platforms (e.g. web) will require the services that will be accessed
  /// to be defined as [services].
  Future<BleDevice> connectTo(String deviceId, String deviceName,
      [List<String> services = const <String>[]]);

  /// Return the native services for [deviceId]
  Future<List<S>> servicesFor(String deviceId, String name);

  /// Return the services for [deviceId]
  /// FIXME Default definition using servicesFor?
  Future<List<BleService>> bleServicesFor(String deviceId, String name);

  /// Disconnect from device
  Future<void> disconnectFrom(String deviceId, String deviceName);

  FutureOr<BleService> bleServiceFrom(
      S nativeService, String deviceId, String deviceName);
  BleUUID serviceUuidFrom(S nativeService);

  Future<S> serviceFor(
      BleUUID serviceUuid, String deviceId, String name) async {
    _logger.fine("serviceFor");
    final services = await servicesFor(deviceId, name);
    final nativeService =
        services.where((e) => serviceUuidFrom(e) == serviceUuid);
    if (nativeService.isEmpty) {
      throw UnknownService(serviceUuid, deviceId, name);
    }

    final service = nativeService.first;

    return Future.value(service);
  }

  Future<List<C>> characteristicsFor(
      BleUUID serviceUuid, String deviceId, String name);

  BleUUID characteristicUuidFrom(C nativeCharacteristic);

  BleCharacteristic bleCharacteristicFrom(C nativeCharacteristic,
      String deviceName, BleUUID serviceUuid, String deviceId);

  Future<C> characteristicFor(BleUUID characteristicUuid, BleUUID serviceUuid,
      String deviceId, String name) async {
    _logger.fine("characteristicFor");
    final characteristics =
        await characteristicsFor(serviceUuid, deviceId, name);
    final characteristic = characteristics.where(
      (element) => characteristicUuidFrom(element) == characteristicUuid,
    );
    if (characteristic.isEmpty) {
      throw UnknownCharacteristic(
          characteristicUuid: characteristicUuid,
          serviceUuid: serviceUuid,
          deviceId: deviceId,
          deviceName: name);
    }

    return Future.value(characteristic.first);
  }

  Future<List<int>> readCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  });

  Future<void> writeCharacteristic({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required List<int> value,
  });

  Future<Stream<List<int>>> setNotifyCharacteristic({
    required bool notify,
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  });

  BleUUID descriptorUuidFrom(D nativeDescriptor);

  // TODO Do we need these here anymore?
  // BleDescriptor bleDescriptorFrom(D nativeDescriptor, String deviceName);

  FutureOr<List<BleDescriptor>> bleDescriptorsFor(BleUUID characteristicUuid,
      BleUUID serviceUuid, String deviceId, String deviceName);

  FutureOr<BleDescriptor> bleDescriptorFor(
      BleUUID descriptorUuid,
      BleUUID characteristicUuid,
      BleUUID serviceUuid,
      String deviceId,
      String deviceName);

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

/// Does the scanner require service uuids?
///
/// Some backends require that the services they will access be specified and
/// the resulting be limited to only those devices which advertise the
/// services specified and/or will only allow access to those services that
/// were defined.

@riverpod
bool scannerNeedsServiceUuids(ScannerNeedsServiceUuidsRef ref) =>
    _ble.scannerNeedsServiceUuids;

/// Similar to [scannerNeedsServiceUuids] some backends (e.g. web) for
/// security reasons, require that the uuids of the service that will be
/// accessed be provided when connecting to a device.
/// TODO Enforce this in connection?
@riverpod
bool connectionRequiresServiceUuids(ConnectionRequiresServiceUuidsRef ref) =>
    _ble.connectionRequiresServiceUuids;

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
    ref.listen(
      initializationProvider,
      (previous, next) {
        _logger.fine("BleScanner.build next=$next");
        next.maybeWhen(
          data: (data) {
            _statusSubscription = _ble.scannerStatusStream.listen(
              (event) {
                _logger.info("BleScanner: scanning=$event");
                _isScanning = event;
                state = _isScanning
                    ? BleScanResults.scanStarted()
                    : BleScanResults.scanDone();
              },
            );

            // TODO Handle bluetooth state changes/errors
            // if (data == BleBluetoothState.on) {
            // start();
            // }
          },
          error: (error, stackTrace) {
            throw BleInitializationError(
                reason: "Scanner initialization", causedBy: error);
          },
          orElse: () {},
        );
      },
      fireImmediately: true,
    );

    // Cleanup
    ref.onDispose(() {
      stop();
      _statusSubscription?.cancel();
    });

    // start(); moved above

    return BleScanResults.initial();
  }

  /// (Re)start scanning
  void start(List<BleUUID>? withServices) {
    _logger.info("Start scanning...");
    stop();

    _resultsSubscription = _ble.scannerResults.listen((results) {
      state = BleScanResults(results);
    }, onDone: () {
      _logger.info("BleScanner: done");
    }, onError: (error) {
      _logger.severe("BleScanner: Error=$error");
    });

    _ble.startScan(withServices: withServices);
  }

  /// Stop scanning
  void stop() {
    _logger.info("Stop scanning");
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

/// Initialization to synchronize everything else until backend is ready
@Riverpod(keepAlive: true)
class Initialization extends _$Initialization {
  final _completer = Completer<BleBluetoothState>();
  late final StreamSubscription _bluetoothStateSubscription;

  @override
  FutureOr<BleBluetoothState> build() async {
    _logger.info("BleInitialize");

    _bluetoothStateSubscription =
        bluetoothAdapterStateStreamController.stream.listen(
      (event) {
        _logger.fine("BleBluetoothState=$event");
        state = AsyncData(event);
      },
    );

    ref.onDispose(() {
      _bluetoothStateSubscription.cancel();
    });

    await _ble.initialize();

    return _completer.future;
  }
}

/// Creates and handle a connection
@riverpod
class BleConnection extends _$BleConnection {
  final _completer = Completer<BleDevice>();
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

    try {
      ref.listen(
        initializationProvider,
        (previous, next) async {
          next.when(
            data: (data) async {
              try {
                // TODO Handle state change
                if (data == BleBluetoothState.on) {
                  _logger.fine("BleConnection: state=$data");
                  state = AsyncData(await connect());
                }
              } catch (error, t) {
                state = AsyncError(
                    error is BleConnectionException
                        ? error
                        : BleConnectionException(
                            deviceId, deviceName, "Connecting",
                            causedBy: error),
                    t);
              }
            },
            error: (error, stackTrace) => throw ("BluetoothError: $error"),
            loading: () {},
          );
        },
        fireImmediately: true,
      );
    } catch (error, t) {
      state = AsyncError(
          BleConnectionException(deviceId, deviceName, "Intialization",
              causedBy: error),
          t);
    }

    return _completer.future;
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
          // Connected?

          // Initialize to the connection state so we don't miss the first entry
          data.maybeMap((value) {
            state = AsyncData(value.status);
          }, orElse: () {});

          // Listen to status stream for changes if we haven't already set this
          // up

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
            final result = await _ble.bleServicesFor(deviceId, deviceName);
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

/// Return the characteristics
@riverpod
class BleCharacteristicsFor extends _$BleCharacteristicsFor {
  @override
  Future<List<BleCharacteristic>> build(
      {required BleUUID serviceUuid,
      required String deviceId,
      required String deviceName}) async {
    final completer = Completer<List<BleCharacteristic>>();

    try {
      ref.listen(bleServicesForProvider(deviceId, deviceName),
          (previous, next) {
        next.when(
          loading: () {},
          data: (data) async {
            _logger.finest("bleCharacteristicsForProvider: got services");
            final service = data.where((s) => s.serviceUuid == serviceUuid);
            if (service.isNotEmpty) {
              try {
                final nativeResults = await _ble.characteristicsFor(
                    serviceUuid, deviceId, deviceName);
                final results = nativeResults
                    .map(
                      (e) => _ble.bleCharacteristicFrom(
                          e, deviceName, serviceUuid, deviceId),
                    )
                    .toList();
                _logger
                    .finest("bleCharacteristicsForProvider: results=$results");
                state = AsyncData(results);
              } catch (e, t) {
                _fail(e, t);
              }
            } else {
              throw UnknownService(serviceUuid, deviceId, deviceName,
                  reason: "Getting characteristics");
            }
          },
          error: (error, stackTrace) => _fail(error, stackTrace),
        );
      }, fireImmediately: true);
    } catch (e, t) {
      _fail(e, t);
    }

    return completer.future;
  }

  _fail(e, t) {
    state = AsyncError(
        CharacteristicsDiscoverException(
            deviceId: deviceId,
            deviceName: deviceName,
            serviceUuid: serviceUuid,
            causedBy: e),
        t);
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
                state = AsyncData(_ble.bleCharacteristicFrom(
                    c, deviceName, serviceUuid, deviceId));
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
      }, fireImmediately: true);
    } catch (e, t) {
      state = AsyncError(_fail(e), t);
    }
    return completer.future;
  }

  Future<void> write(List<int> value) {
    return _ble.writeCharacteristic(
        deviceId: deviceId,
        deviceName: deviceName,
        serviceUuid: serviceUuid,
        characteristicUuid: characteristicUuid,
        value: value);
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
          bleCharacteristicForProvider(
              characteristicUuid: characteristicUuid,
              serviceUuid: serviceUuid,
              deviceId: deviceId,
              deviceName: deviceName), (previous, next) {
        next.maybeWhen(
          data: (characteristic) async {
            try {
              final value = await _ble.readCharacteristic(
                deviceId: deviceId,
                deviceName: deviceName,
                serviceUuid: serviceUuid,
                characteristicUuid: characteristicUuid,
              );
              state = AsyncData(BleRawValue(values: value));
            } catch (e, t) {
              _fail(e, t);
            }
          },
          error: _fail,
          orElse: () {},
        );
      }, fireImmediately: true);
    } catch (e, t) {
      _fail(e, t);
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
        fireImmediately: true,
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

/// Return descriptors for a characteristic
@riverpod
class BleDescriptorsFor extends _$BleDescriptorsFor {
  @override
  Future<List<BleDescriptor>> build({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
  }) async {
    final completer = Completer<List<BleDescriptor>>();

    try {
      ref.listen(
        bleCharacteristicForProvider(
          deviceId: deviceId,
          deviceName: deviceName,
          serviceUuid: serviceUuid,
          characteristicUuid: characteristicUuid,
        ),
        (prev, next) {
          next.maybeWhen(
              data: (characteristic) async {
                try {
                  state = AsyncData(await _ble.bleDescriptorsFor(
                      characteristicUuid, serviceUuid, deviceId, deviceName));
                } catch (e, t) {
                  _fail(e, t);
                }
              },
              error: _fail,
              orElse: () {});
        },
        fireImmediately: true,
      );
    } catch (e, t) {
      _fail(e, t);
    }

    return completer.future;
  }

  _fail(error, t) {
    state = AsyncError(
        GetDescriptorsException(
          deviceId: deviceId,
          name: deviceName,
          serviceUuid: serviceUuid,
          characteristicUuid: characteristicUuid,
          causedBy: error,
        ),
        t);
  }
}

/// Return a descriptor
@riverpod
class BleDescriptorFor extends _$BleDescriptorFor {
  @override
  Future<BleDescriptor> build({
    required String deviceId,
    required String deviceName,
    required BleUUID serviceUuid,
    required BleUUID characteristicUuid,
    required BleUUID descriptorUuid,
  }) async {
    return Future.value(_ble.bleDescriptorFor(
        descriptorUuid, characteristicUuid, serviceUuid, deviceId, deviceName));
  }
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

                // Some platforms may require explicit access to characteristics
                // to make sure they're loaded
                try {
                  ref.listen(
                      bleCharacteristicForProvider(
                        characteristicUuid: characteristicUuid,
                        serviceUuid: serviceUuid,
                        deviceId: deviceId,
                        deviceName: deviceName,
                      ), (previous, next) {
                    next.maybeWhen(
                      data: (characteristic) async {
                        try {
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
                      error: (e, t) {
                        state = _fail(e, t);
                      },
                      orElse: () {},
                    );
                  }, fireImmediately: true);
                } catch (e, t) {
                  state = _fail(e, t);
                }
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

/// Return a message suitable for display for [e]
///
/// Try to do better:
/// We want to display what we were doing and what caused the problems which
/// should be the [e] itself and if [e] is a [RiverpodBleException] used
/// the [causedBy] to find the root should be the underlying cause for
/// the top exception to have failed.
///
Future<String> bleExceptionDisplayMessage(Object e) async {
  if (e is Exception) {
    final root = CausedBy.rootCause(e);
    if (e is RiverpodBleException) {
      // If we're not connected -- nothing else matters so check that first
      final maybeConnected = await bleIsConnectedFromException(e);
      if (maybeConnected != null && !maybeConnected) {
        return "Device is not connected";
      }

      // Show cause if it's different using platform specfic code if it's
      // not one of our exceptions.

      String cause = "";
      if (e != root && e.causedBy != root) {
        final message = (root is RiverpodBleException)
            ? e.toString()
            : _ble.exceptionDisplayMessage(root);
        cause = " causedBy=$message";
      }

      return "${e.toString()}$cause";
    } else {
      // Maybe process as native exception
      return _ble.exceptionDisplayMessage(e);
    }
  }

  // Can't figure anything else just use toString()
  return e.toString();
}
