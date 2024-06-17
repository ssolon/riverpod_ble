import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ble/src/ble_bitstring.dart';

void main() {
  group("Test stringToBits", () {
    test("convert 1 byte", () {
      const input = "10101000";
      final output = stringToBits(input);
      expect(output, [0xa8]);
    });

    test("convert 2 bytes", () {
      const input = "10101000 11111101";
      final output = stringToBits(input);
      expect(output, [0xa8, 0xfd]);
    });

    test("convert 3 bytes", () {
      const input = "10101000 11111101 00001111";
      final output = stringToBits(input);
      expect(output, [0xa8, 0xfd, 0x0f]);
    });
  });

  group("Test extractBits", () {
    test("zero offset returns same input", () {
      final input = [0x01, 0x02, 0x03, 0x04];
      final output = extractBits(input, 0, 32);
      expect(output, input);
    });

    test("extract 1 bit from 1 byte offset 0", () {
      final input = [0x01];
      final output = extractBits(input, 0, 1);
      expect(output, [0x01]);
    });

    test("extract 1 bit from 1 byte offset 3", () {
      final input = [0xF8];
      final output = extractBits(input, 3, 1);
      expect(output, [0x01]);
    });

    test("extract 2 bits from 1 byte offset 3", () {
      final input = [0xF8];
      final output = extractBits(input, 3, 2);
      expect(output, [0x03]);
    });

    test("extract 5 bits from 1 byte offset 3", () {
      final input = [0xa8];
      final output = extractBits(input, 3, 5);
      expect(output, [0x15]);
    });

    test("extract 5 bits from 2 byte offset 3", () {
      final input = [0xa8, 0xff];
      final output = extractBits(input, 3, 5);
      expect(output, [0x15]);
    });

    test("extract 8 bits from 2 bytes offset 3", () {
      final input = stringToBits("10101000 11111101");
      final output = extractBits(input, 3, 8);
      expect(output, [0xb5]);
    });

    test("extract 16 bits from 3 bytes offset 3", () {
      final input = stringToBits("10101000 11111101 00000000");
      final output = extractBits(input, 3, 16);
      expect(output, [0xb5, 0x1f]);
    });
  });

  test("extract 16 bits from 3 bytes offset 3", () {
    final input = stringToBits("10101000 11111101 00000010");
    final output = extractBits(input, 3, 16);
    expect(output, [0xb5, 0x5f]);
  });

  test("extract 16 bits from 3 bytes offset 4", () {
    final input = stringToBits("1010 1000 1111 1101 0000 0010");
    final output = extractBits(input, 4, 16);
    expect(output, [0xda, 0x2f]);
  });

  test("extract 16 bits from 3 bytes offset 5", () {
    final input = stringToBits("10101000 11111101 00000010");
    final output = extractBits(input, 5, 16);
    expect(output, [0xed, 0x17]);
  });

  test("extract 16 bits from 3 bytes offset 6", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 6, 16);
    expect(output, [0xf6, 0x6b]);
  });

  test("extract 16 bits from 3 bytes offset 7", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 7, 16);
    expect(output, [0xfb, 0x35]);
  });

  test("extract 16 bits from 3 bytes offset 8", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 8, 16);
    expect(output, [0xfd, 0x9a]);
  });

  test("extract 16 bits from 3 bytes offset 9", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 9, 16);
    expect(output, [0x7e, 0x4d]);
  });

  test("extract 16 bits from 3 bytes offset 22", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 22, 16);
    expect(output, [0x2, 0x0]);
  });

  test("extract 16 bits from 3 bytes offset 37", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 37, 16);
    expect(output, [0x0, 0x0]);
  });

  test("extract 1 bits from 3 bytes offset 17", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 17, 1);
    expect(output, [0x1]);
  });

  test("extract 1 bits from 3 bytes offset 18", () {
    final input = stringToBits("10101000 11111101 10011010");
    final output = extractBits(input, 18, 1);
    expect(output, [0x0]);
  });
}

/// Convert a string with 0s and 1s to a list of integers
/// with each integer holding eight bits.
List<int> stringToBits(String bitString) {
  List<int> bits = [];
  int byte = 0;
  int bitIndex = 7;

  for (int i = 0; i < bitString.length; i++) {
    if (bitString[i] != '0' && bitString[i] != '1') {
      continue;
    }

    if (bitString[i] == '1') {
      byte |= (1 << bitIndex);
    }

    bitIndex--;

    if (bitIndex < 0) {
      bits.add(byte);
      byte = 0;
      bitIndex = 7;
    }
  }

  if (bitIndex < 0) {
    bits.add(byte);
  }

  return bits;
}
