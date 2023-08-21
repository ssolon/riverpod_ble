import 'dart:typed_data';

import 'tsigned.dart';

/// Generate some float values to create tests for converters
void main() {
  final u4list = Uint8List(4);
  final bd4 = ByteData.sublistView(u4list);

  final u8list = Uint8List(8);
  final bd8 = ByteData.sublistView(u8list);

  const sol = 2.99792458e8;
  const avo = 6.02214076e23;
  const tf = avo;

  bd4.setFloat32(0, tf, Endian.little);
  bd8.setFloat64(0, tf, Endian.little);

  print(tf);
  print("${dump(u4list)} = ${bd4.getFloat32(0, Endian.little)}");
  print("${dump(u8list)} = ${bd8.getFloat64(0, Endian.little)}");
}

dump(List l) =>
    l.map((v) => "0x${(v & 0xff).toRadixString(16).padLeft(2, '0')}").join(',');
