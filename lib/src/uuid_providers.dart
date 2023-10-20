/// Providers for BLE uuid definitions

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

part 'uuid_providers.g.dart';

final _logger = Logger("UUidProviders");

@immutable
class UuidDef {
  final String uuid;
  final String name;
  final String id;

  const UuidDef(this.uuid, this.name, this.id);
}

@riverpod
class UuidDefinitionsFromYaml extends _$UuidDefinitionsFromYaml {
  final Map<int, UuidDef> _defs = {};

  @override
  Future<void> build(String yamlFilePath) async {
    ref.onDispose(() {
      _logger.fine("UuidDefinitionsFromYaml: dispose");
    });

    try {
      _logger.fine("UuidDefinitionFromYaml: build");
      final yamlString = await rootBundle.loadString(yamlFilePath);
      final yamlMap = loadYaml(yamlString) as Map;

      for (final n in (yamlMap['uuids'] as List)) {
        _defs[n['uuid']] = UuidDef(
            "0x${(n['uuid'] as int).toRadixString(16)}", n['name'], n['id']);
      }

      return Future.value();
    } catch (e) {
      return Future.error(UuidDefinitionException(yamlFilePath, causedBy: e));
    }
  }

  /// Lookup a definition by [uuid]
  UuidDef? lookup(int uuid) {
    return _defs[uuid];
  }
}

/// Return a nice "name" for [bleUUID].
///
/// Either the name from a UUID definition for a short uuid that is known
/// or the string version of the UUID.
@riverpod
Future<String> nameFor(NameForRef ref, BleUUID bleUUID, String yamlPath) async {
  String result = bleUUID.str;
  final completer = Completer<String>();

  if (bleUUID.isShort) {
    // Try to lookup
    _logger.fine("nameFor: short lookup uuid=$bleUUID");
    ref.listen(
      uuidDefinitionsFromYamlProvider(yamlPath),
      (previous, next) {
        _logger.fine("nameFor: previous=$previous next=$next");
        next.map(
          data: (value) {
            final def = ref
                .read(UuidDefinitionsFromYamlProvider(yamlPath).notifier)
                .lookup(bleUUID.shortUUID ?? 0);
            if (def != null) {
              // We found a definition - use it
              result = def.name;
            }
            completer.complete(result);
          },
          error: (error) => completer.completeError(
              BleUuidNameException(bleUUID, yamlPath, causedBy: error)),
          loading: (loading) {},
        );
      },
      onError: (error, stack) => completer.completeError(error),
      fireImmediately: true,
    );
  } else {
    // Return long uuid from str
    completer.complete(result);
  }

  return completer.future;
}

@riverpod
FutureOr<String> nameForService(NameForServiceRef ref, BleUUID bleUUID) async {
  const servicesPath = 'packages/riverpod_ble/files/yaml/service_uuids.yaml';
  final completer = Completer<String>();

  ref.listen(
    nameForProvider(bleUUID, servicesPath),
    (prev, next) => next.when(
      data: (data) => completer.complete(data),
      error: (error, stack) => completer.completeError(error, stack),
      loading: () => completer.future,
    ),
    fireImmediately: true,
  );

  return completer.future;
}

@riverpod
class NameForCharacteristic extends _$NameForCharacteristic {
  @override
  Future<String> build(BleCharacteristic characteristic) async {
    const servicesPath =
        'packages/riverpod_ble/files/yaml/characteristic_uuids.yaml';
    final completer = Completer<String>();
    final uuid = characteristic.characteristicUuid;

    ref.listen(
      nameForProvider(uuid, servicesPath),
      (prev, next) => next.when(
        data: (data) async {
          var n = data;
          // If no name, try for a descriptor name
          if (data == uuid.str) {
            final ds = characteristic.descriptors.where(isUserDescriptor);
            if (ds.isNotEmpty) {
              final d = ds.first;
              try {
                ref.listen(
                  bleDescriptorValueProvider(
                    d.deviceId,
                    characteristic.deviceName,
                    d.serviceUuid,
                    d.characteristicUuid,
                    d.descriptorUuid,
                  ),
                  (previous, next) {
                    next.when(
                      data: (values) {
                        n = String.fromCharCodes(values);
                        state = AsyncData(n);
                      },
                      error: _fail,
                      loading: () => state = const AsyncLoading(),
                    );
                  },
                );
              } catch (e, t) {
                _fail(e, t);
              }
            }
          }
          state = AsyncData(n);
        },
        error: (error, stack) => state = AsyncError(error, stack),
        loading: () => state = const AsyncLoading(),
      ),
      fireImmediately: true,
    );

    return completer.future;
  }

  _fail(e, t) => state = AsyncError(
      BleNameForCharacteristicException(
        characteristicUuid: characteristic.characteristicUuid,
        serviceUuid: characteristic.serviceUuid,
        deviceId: characteristic.deviceId,
        deviceName: characteristic.deviceName,
        causedBy: e,
      ),
      t);
}

bool isUserDescriptor(BleDescriptor d) => d.descriptorUuid.shortUUID == 0x2901;

@riverpod
Future<String> nameForDescriptor(NameForDescriptorRef ref, BleUUID uuid) async {
  const servicesPath = 'packages/riverpod_ble/files/yaml/descriptors.yaml';
  final completer = Completer<String>();

  ref.listen(
    nameForProvider(uuid, servicesPath),
    (prev, next) => next.when(
      data: (data) => completer.complete(data),
      error: (error, stack) => completer.completeError(error, stack),
      loading: () => completer.future,
    ),
    fireImmediately: true,
  );

  return completer.future;
}
