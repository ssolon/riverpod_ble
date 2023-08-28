import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

class TBase with CausedBy {
  @override
  final Object? causedBy;
  final String message;
  TBase(this.message, {this.causedBy});

  @override
  String toString() => exceptionMessage(message, [], []);
}

class T1Var extends TBase {
  final Object? v1;
  T1Var(super.message, {this.v1, super.causedBy});

  @override
  String toString() => exceptionMessage(message, [(n: 'v1', v: v1)], []);
}

class T1VarOverride extends T1Var {
  final String overrideMessage;
  T1VarOverride(super.message, this.overrideMessage);

  @override
  String formatBase(String s) => super.formatBase(overrideMessage);
}

class T2Var extends T1Var {
  final Object? v2;
  T2Var(super.message, {this.v2, required super.v1, super.causedBy});

  @override
  String toString() =>
      exceptionMessage(message, [(n: 'v1', v: v1), (n: 'v2', v: v2)], []);
}

class T2VarFunctionValue extends T2Var {
  T2VarFunctionValue(super.message, {super.v1, super.v2, super.causedBy});

  @override
  String toString() => exceptionMessage(
        super.message,
        [],
        [
          (n: 'v1', v: (name) => "$name-$v1"),
          (n: 'v2', v: v2),
        ],
      );
}

class T1Opt extends TBase {
  final Object? o1;
  T1Opt(super.message, {this.o1, super.causedBy});

  @override
  String toString() => exceptionMessage(message, [], [(n: 'o1', v: o1)]);
}

class T2Opt extends T1Opt {
  final Object? o2;
  T2Opt(super.message, {super.o1, required this.o2, super.causedBy});

  @override
  String toString() =>
      exceptionMessage(message, [], [(n: 'o1', v: o1), (n: 'o2', v: o2)]);
}

class T2OptFunctionValue extends T2Opt {
  T2OptFunctionValue(super.message, {super.o1, super.o2, super.causedBy});

  @override
  String toString() => exceptionMessage(
        super.message,
        [],
        [
          (n: 'o1', v: o1),
          (n: 'o2', v: (name) => "$name-$o2"),
        ],
      );
}

class T3 extends TBase {
  final Object? v1;
  final Object? v2;
  final Object? v3;
  final Object? o1;
  final Object? o2;
  final Object? o3;
  T3(super.message,
      {this.v1, this.v2, this.v3, this.o1, this.o2, this.o3, super.causedBy});

  T3.init(super.message, {super.causedBy})
      : v1 = 'v1',
        v2 = 'v2',
        v3 = 'v3',
        o1 = 'o1',
        o2 = 'o2',
        o3 = 'o3';

  @override
  String toString() => exceptionMessage(message, [
        (n: 'v1', v: v1),
        (n: 'v2', v: v2),
        (n: 'v3', v: v3),
      ], [
        (n: 'o1', v: o1),
        (n: 'o2', v: o2),
        (n: 'o3', v: o3)
      ]);
}

class T3x extends T3 {
  T3x(String message) : super.init(message);
}

void main() {
  group('No vars', () {
    test('Only base', () {
      final tb = TBase('Only Base');
      expect(tb.toString(), 'Only Base:');
    });

    test('One level causedBy', () {
      final tb1 = TBase('Tb1');
      final tb2 = TBase('Tb2', causedBy: tb1);

      expect(tb2.toString(), 'Tb2: causedBy: Tb1:');
    });

    test('Two level causedBy', () {
      final tb1 = TBase('Tb1');
      final tb2 = TBase('Tb2', causedBy: tb1);
      final tb3 = TBase('Tb3', causedBy: tb2);
      expect(tb3.toString(), 'Tb3: causedBy: Tb2: causedBy: Tb1:');
    });
  });

  group('Vars', () {
    test('One var no spaces no causedBy', () {
      final tb1 = T1Var('OneVar', v1: 'Nospace');
      expect(tb1.toString(), 'OneVar: v1=Nospace');
    });

    test('One var some spaces no causedBy', () {
      final tb1 = T1Var('OneVar', v1: 'Some space');
      expect(tb1.toString(), 'OneVar: v1=\'Some space\'');
    });

    test('Two vars mixed spaces no causedBy', () {
      final tb2 = T2Var('TwoVar', v1: 'With\u2003emspace', v2: 'Nospace');
      expect(tb2.toString(), "TwoVar: v1='With\u2003emspace' v2=Nospace");
    });

    test('Two vars no values', () {
      final tb2 = T2Var('TwoVar', v1: '', v2: '');
      expect(tb2.toString(), "TwoVar: v1='' v2=''");
    });

    test('Two vars whitespace', () {
      final tb2 = T2Var('TwoVar', v1: '\t', v2: '    ');
      expect(tb2.toString(), "TwoVar: v1='\t' v2='    '");
    });

    test('CausedBy three levels', () {
      final tb = TBase('TBase');
      final tb1 = T1Var('T1Var', v1: 'Some stuff', causedBy: tb);
      final tb2 = T2Var('T2Var',
          v1: '  leading/trailing space ', v2: 'v2', causedBy: tb1);
      expect(
          tb2.toString(),
          "T2Var: v1='  leading/trailing space ' v2=v2"
          " causedBy: T1Var: v1='Some stuff'"
          " causedBy: TBase:");
    });
  });

  group('Opts', () {
    test('One opt', () {
      final to1 = T1Opt('T1Opt', o1: 'o1');
      expect(to1.toString(), "T1Opt: o1=o1");
    });
    test('Two opts', () {
      final to2 = T2Opt('T2Opt', o1: 'Nospace', o2: 'Some spaces here');
      expect(to2.toString(), "T2Opt: o1=Nospace o2='Some spaces here'");
    });

    test('Two opts, one empty', () {
      final to2 = T2Opt("T2Opt", o1: 'Something', o2: '');
      expect(to2.toString(), "T2Opt: o1=Something");
    });

    test('Mixture of opts and causedBy', () {
      final to1 = T1Opt('T1Opt', o1: '');
      final to2 = T2Opt('T2Opt', o1: '', o2: 'Something else', causedBy: to1);
      expect("$to2", "T2Opt: o2='Something else' causedBy: T1Opt:");
    });
  });

  group('Nullable values for vars and opts', () {
    test('Nullable vars', () {
      final t = T3('t');
      expect(t.toString(), "t: v1=<null> v2=<null> v3=<null>");
    });
  });
  group('Vars and Opts', () {
    test('Full House', () {
      final t3 =
          T3('T3', v1: 'v1', v2: 'v2', v3: 'v3', o1: 'o1', o2: 'o2', o3: 'o3');
      expect("$t3", "T3: v1=v1 v2=v2 v3=v3 o1=o1 o2=o2 o3=o3");
    });
  });

  group('isCaused tests', () {
    final root = Exception('Non-isCaused');
    final tb = TBase('tb', causedBy: root);
    final t0 = T2Var('t0', v1: 'v1', v2: 'v2', causedBy: tb);
    final t1 = T2Opt('t1', o1: 'o1', o2: 'o2', causedBy: t0);
    final t2 = T3.init('t2', causedBy: t1);
    final t3 = T2Var('t3', v1: 'v1', v2: 'v2', causedBy: t2);

    test('Find nothing returns null', () {
      final result = t3.isCaused((o) => false);
      expect(result, null);
    });

    test('Should find self', () {
      final result = t3.isCaused((o) => true);
      expect(result, isNotNull);
      expect(result, t3);
    });

    test('Should find by super base class', () {
      final result = t3.isCaused((o) => o is TBase);
      expect(result, t3, reason: 'All are base class');
    });
    test('Should find by super class', () {
      final result = t3.isCaused((o) => o is T1Opt);
      expect(result, t1, reason: 'T2Opt is first subclass of T1Opt');
    });
    test('Should find by exact class', () {
      final result = t3.isCaused((o) => o is T2Opt);
      expect(result, t1);
    });
  });

  group('Override tests', () {
    test('Override base string', () {
      final result = T1VarOverride('Original message', 'Override message');
      expect(result.toString(), 'Override message: v1=<null>');
    });

    test('Var value as function ', () {
      final result = T2VarFunctionValue('T2VarFunction', v1: 'One 1', v2: 'v2');
      expect("$result", "T2VarFunction: v1='v1-One 1' v2=v2");
    });

    test('Opt value as function ', () {
      final result =
          T2OptFunctionValue('T2OptFunction', o1: 'One', o2: 'Two 2');
      expect("$result", "T2OptFunction: o1=One o2='o2-Two 2'");
    });
  });
}
