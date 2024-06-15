import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ble/src/states/ble_uuid.dart';

void main() {
  test('String in equals string out', () {
    const uString = '154383d3-195d-448e-b2cb-8854c87a27a5';
    final u1 = BleUUID(uString);
    expect(u1.str, uString, reason: 'Same string returned by str');
  });

  group('validateUUID tests', () {
    test('Good UUID String', () {
      const uString = '154383d3-195d-448e-b2cb-8854c87a27a5';
      expect(BleUUID.validateUUID(uString), true);
    });

    test('Short UUID String', () {
      const uString = '154383d3-195d-448e-b2cb-8854c87';
      expect(BleUUID.validateUUID(uString), false);
    });

    test('Invalid characters in UUID String', () {
      const uString = '154383d3-fred-448e-b2cb-8854c87a27a5';
      expect(BleUUID.validateUUID(uString), false);
    });

    test('Missing separator', () {
      const uString = '154383d34195d-448e-b2cb-8854c87a27a5';
      expect(BleUUID.validateUUID(uString), false);
    });
  });

  group('CTOR tests', () {
    test('Malformed UUID string', () {
      const uString = '154383d3-195d448e-b2cb-8854c87a27a5';
      try {
        BleUUID(uString);
        fail("Should have thrown FormatException");
      } catch (e) {
        expect(e, isFormatException);
      }
    });

    test('Malformed short UUID string', () {
      const uString = 'ZEBR';
      try {
        BleUUID(uString);
        fail("Should have thrown FormatException");
      } catch (e) {
        expect(e, isFormatException);
      }
    });

    test('Short UUID Test', () {
      const u = '00001826-0000-1000-8000-00805f9b34fb';
      final b = BleUUID.fromInt(0x1826);
      expect(b.str, u);
    });
  });

  group('Equality tests', () {
    test('Equal BleUUIDs', () {
      const uString = '154383d3-195d-448e-b2cb-8854c87a27a5';
      expect(BleUUID(uString) == BleUUID(uString), true);
    });

    test('Case insensitive', () {
      const uString1 = '154383D3-195D-448e-B2CB-8854C87A27A5';
      const uString2 = '154383d3-195d-448e-b2cb-8854c87a27a5';
      expect(BleUUID(uString1) == BleUUID(uString2), true);
    });

    test('Not Equal BleUUIDs', () {
      const uString1 = '154383d3-195d-448e-b2cb-8854c87a27a5';
      const uString2 = '000083d3-195d-448e-b2cb-8854c87a27a5';
      expect(BleUUID(uString1) == BleUUID(uString2), false);
    });
  });

  group('Short UUID tests', () {
    test('Short UUID Equality Test', () {
      const u = '00001826-0000-1000-8000-00805f9b34fb';
      final uuid = BleUUID(u);
      final shortUUID = BleUUID.fromInt(0x1826);
      expect(uuid == shortUUID, true, reason: 'Compare regular to short');
      expect(shortUUID == uuid, true, reason: 'Compare short to regular');
    });

    test('Short UUID string Equality Test', () {
      const u = '00001826-0000-1000-8000-00805f9b34fb';
      final uuid = BleUUID(u);
      final shortUUID = BleUUID('1826');
      expect(uuid == shortUUID, true, reason: 'Compare regular to short');
      expect(shortUUID == uuid, true, reason: 'Compare short to regular');
    });

    test('Short UUID explicit hex string Equality Test', () {
      const u = '00001826-0000-1000-8000-00805f9b34fb';
      final uuid = BleUUID(u);
      final shortUUID = BleUUID('0x1826');
      expect(uuid == shortUUID, true, reason: 'Compare regular to short');
      expect(shortUUID == uuid, true, reason: 'Compare short to regular');
    });

    test('Short UUID Inequality test', () {
      const u = '154383D3-195D-448e-B2CB-8854C87A27A5';
      const ushort = '00001826-0000-1000-8000-00805f9b34fb';

      final uuid = BleUUID(u);
      final shortUUID = BleUUID(ushort);

      expect(uuid.isShort, false);
      expect(shortUUID.isShort, true);
    });

    test('Short UUID extraction', () {
      expect(BleUUID.fromInt(0x1826).shortUUID, 0x1826);
    });

    test('Nonshort UUID extraction', () {
      const u = '154383D3-195D-448e-B2CB-8854C87A27A5';
      final uuid = BleUUID(u);
      expect(uuid.isShort, false);
      expect(uuid.shortUUID, null);
    });
  });

  group('toString override test', () {
    test("Regular uuid in full", () {
      const u = '154383d3-195d-448e-b2cb-8854c87a27a5';
      expect(BleUUID(u).toString(), u);
    });

    test("Short UUID as hex constant", () {
      expect(BleUUID.fromInt(0x1826).toString(), '0x1826');
    });
  });

  group('Json conversion', () {
    test('Custom uuid', () {
      const u = '807309dd-7ccf-418e-bfdc-b7fda39e75c5';
      final o = BleUUID(u);
      final j = jsonEncode(o);

      final c = BleUUID.fromJson(jsonDecode(j));

      expect(c.str, u, reason: 'Converted uuid should be equal');
      expect(c.str, o.str, reason: "Uuids should be equal");
      expect(c, o, reason: 'BleUUIDs should be equal');
    });

    test('Short int uuid', () {
      const u = '00001826-0000-1000-8000-00805f9b34fb';
      final o = BleUUID.fromInt(0x1826);
      final j = jsonEncode(o);
      final c = BleUUID.fromJson(jsonDecode(j));

      expect(c.str, o.str, reason: 'Full uuid should match');
      expect(c.isShort, true, reason: 'Should be short');
      expect(c, o, reason: 'BleUUID objects should be equal');
      expect(c.shortUUID, 0x1826, reason: 'Short should be equal');
    });

    test('Short text uuid', () {
      const u = '00001826-0000-1000-8000-00805f9b34fb';
      final o = BleUUID('1826');
      final j = jsonEncode(o);
      final c = BleUUID.fromJson(jsonDecode(j));

      expect(c.str, o.str, reason: 'Full uuid should match');
      expect(c.isShort, true, reason: 'Should be short');
      expect(c, o, reason: 'BleUUID objects should be equal');
      expect(c.shortUUID, 0x1826, reason: 'Short should be equal');
    });
  });
}
