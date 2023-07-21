import 'package:simple_logger/simple_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calculator.g.dart';

final logger = SimpleLogger();

/// A Calculator.
@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  int build() {
    return 0;
  }

  void addOne() {
    logger.info("addOne to $state");
    state = state + 1;
  }
}
