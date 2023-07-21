import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_ble/riverpod_ble.dart';

void main() {
  test('adds one to input values', () {
    final calculator = Calculator();
    expect((), 3);
    expect(calculator.addOne(), -6);
    expect(calculator.addOne(), 1);
  });
}
