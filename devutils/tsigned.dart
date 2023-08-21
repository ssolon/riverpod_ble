import 'dart:typed_data';

void main() {
  gen(1, 0);
  gen(0xfe, 0xff);
}

gen(start, add) {
  final lu = <int>[start];
  for (int i = 0; i < 9; i++) {
    final w = lu.length * 8;
    int v = toBigEndian(lu).toSigned(w);

    final bd = ByteData.sublistView(Uint8List.fromList(lu));
    final td = switch (w) {
      8 => bd.getInt8(0).toString(),
      16 => bd.getInt16(0, Endian.little).toString(),
      32 => bd.getInt32(0, Endian.little).toString(),
      64 => bd.getInt64(0, Endian.little).toString(),
      _ => '',
    };

    print("$w = ${dump(lu)} = $v $td");

    lu.insert(0, add);
  }
}

int toBigEndian(List<int> values) =>
    values.reversed.fold(0, (result, i) => result << 8 | i);

dump(List l) =>
    l.map((v) => "0x${(v & 0xff).toRadixString(16).padLeft(2, '0')}").join(',');
