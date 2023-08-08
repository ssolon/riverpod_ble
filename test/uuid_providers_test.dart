import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_ble/riverpod_ble.dart';
import 'package:simple_logger/simple_logger.dart';

const servicesYamlPath = 'packages/riverpod_ble/files/yaml/service_uuids.yaml';

void main() {
  SimpleLogger().setLevel(Level.ALL);

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Test base provider', () {
    test('Lookup value which should be there', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final defs = await container
          .read(UuidDefinitionsFromYamlProvider(servicesYamlPath).future);

      final def = container
          .read(UuidDefinitionsFromYamlProvider(servicesYamlPath).notifier)
          .lookup(0x1800);
      expect(def?.uuid, '0x1800', reason: 'Should be there');
    });

    test('Lookup value which should not be there', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final defs = await container
          .read(UuidDefinitionsFromYamlProvider(servicesYamlPath).future);

      final def = container
          .read(UuidDefinitionsFromYamlProvider(servicesYamlPath).notifier)
          .lookup(0x0000);
      expect(def, isNull, reason: 'Should not be there');
    });

    test('Should fail with error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      bool errorReported = false;

      // Apparently this isn't useful since w're using await
      // TODO Add a test to make sure AsyncValueError works properly.
      container.listen(
        UuidDefinitionsFromYamlProvider(servicesYamlPath),
        (previous, next) {
          print("previous=$previous next=$next");
        },
        onError: (error, stackTrace) {
          print("onError: $error");
        },
      );

      try {
        final defs = await container.read(
            UuidDefinitionsFromYamlProvider("foo$servicesYamlPath").future);
      } catch (e) {
        // It looks like by using await we get the error thrown?
        errorReported = true;
        print("Caught:$e");
      }

      expect(errorReported, true);
    });
  });

  group('Test service name provider', () {
    test('Custom uuid lookup', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final u = BleUUID('1a56b5ed-8c11-44de-b933-5580c9c053d9');
      final name = await container.read(NameForServiceProvider(u).future);
      expect(name, u.str, reason: 'Custom uuid name is full uuid');
    });

    test('Known short uuid lookup', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final u = BleUUID.fromInt(0x180f);
      final name = await container.read(nameForServiceProvider(u).future);
      expect(name, 'Battery', reason: 'Return definition');
    });

    test('Unknown short returns full uuid', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final u = BleUUID.fromInt(0x1234);
      final name = await container.read(nameForServiceProvider(u).future);
      expect(name, u.str, reason: 'Unknown short returns full uuid');
    });

    test('Two lookups in a row', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final u1 = BleUUID.fromInt(0x180d);
      final completer1 = Completer<String>();

      final p1 = container.listen(
        nameForServiceProvider(u1),
        (previous, next) {
          next.map(
              data: (data) => completer1.complete(data.value),
              error: (error) => completer1.completeError(error),
              loading: (_) {});
        },
      );
      final name1 = await completer1.future;
      expect(name1, 'Heart Rate');
      print(name1);

      final u2 = BleUUID.fromInt(0x180f);
      final completer2 = Completer<String>();

      final p2 = container.listen(
        nameForServiceProvider(u2),
        (previous, next) {
          next.map(
              data: (data) => completer2.complete(data.value),
              error: (error) => completer2.completeError(error),
              loading: (_) {});
        },
      );
      final name2 = await completer2.future;
      // final name2 = await container.read(nameForServiceProvider(u2).future);
      expect(name2, 'Battery');
      print(name2);
    });
  });
  // TODO Add test nameForServiceProvider when yaml can't be loaded
}
