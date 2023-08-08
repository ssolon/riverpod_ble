/// Providers for BLE uuid definitions

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:yaml/yaml.dart';

part 'uuid_providers.g.dart';

final logger = SimpleLogger();

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
      logger.fine("UuidDefinitionsFromYaml: dispose");
    });

    try {
      logger.fine("UuidDefinitionFromYaml: build");
      final yamlString = await rootBundle.loadString(yamlFilePath);
      final yamlMap = loadYaml(yamlString) as Map;

      for (final n in (yamlMap['uuids'] as List)) {
        _defs[n['uuid']] = UuidDef(
            "0x${(n['uuid'] as int).toRadixString(16)}", n['name'], n['id']);
      }

      return Future.value();
    } catch (e) {
      return Future.error(
          "Exception loading uuid definitions from $yamlFilePath: $e");
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
Future<String> nameForService(NameForServiceRef ref, BleUUID bleUUID) async {
  const servicesPath = 'packages/riverpod_ble/files/yaml/service_uuids.yaml';
  String result = bleUUID.str;
  final completer = Completer<String>();

  if (bleUUID.isShort) {
    // Try to lookup
    logger.fine("nameForService: short lookup uuid=$bleUUID");
    ref.listen(
      uuidDefinitionsFromYamlProvider(servicesPath),
      (previous, next) {
        logger.fine("nameForService: previous=$previous next=$next");
        next.map(
          data: (value) {
            final def = ref
                .read(UuidDefinitionsFromYamlProvider(servicesPath).notifier)
                .lookup(bleUUID.shortUUID ?? 0);
            if (def != null) {
              // We found a definition - use it
              result = def.name;
            }
            completer.complete(result);
          },
          error: (error) => completer
              .completeError("Error getting name for $bleUUID: error=$error"),
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
Future<String> nameForService2(NameForService2Ref ref, BleUUID bleUUID) async {
  const servicesPath = 'files/yaml/service_uuids.yaml';
  String result = bleUUID.str;
  final completer = Completer<String>();

  if (bleUUID.isShort) {
    // Try to lookup
    logger.fine("nameForService: short lookup uuid=$bleUUID");
    final defs = ref.watch(uuidDefinitionsFromYamlProvider(servicesPath));
    logger.fine("nameForService2: $defs");
    final def = ref
        .read(uuidDefinitionsFromYamlProvider(servicesPath).notifier)
        .lookup(bleUUID.shortUUID ?? 0);
    if (def != null) {
      // We found a definition - use it
      result = def.name;
    }
    completer.complete(result);
  } else {
    // Return long uuid from str
    completer.complete(result);
  }

  return completer.future;
}
