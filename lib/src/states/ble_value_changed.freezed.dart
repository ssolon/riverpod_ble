// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_value_changed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BleValueChanged {
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String characteristicId, Uint8List value)
        $default, {
    required TResult Function(Object? error, StackTrace? stackTrace) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String deviceId, String characteristicId, Uint8List value)?
        $default, {
    TResult? Function(Object? error, StackTrace? stackTrace)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String characteristicId, Uint8List value)?
        $default, {
    TResult Function(Object? error, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleValueChanged value) $default, {
    required TResult Function(Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleValueChanged value)? $default, {
    TResult? Function(Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleValueChanged value)? $default, {
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleValueChangedCopyWith<$Res> {
  factory $BleValueChangedCopyWith(
          BleValueChanged value, $Res Function(BleValueChanged) then) =
      _$BleValueChangedCopyWithImpl<$Res, BleValueChanged>;
}

/// @nodoc
class _$BleValueChangedCopyWithImpl<$Res, $Val extends BleValueChanged>
    implements $BleValueChangedCopyWith<$Res> {
  _$BleValueChangedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_BleValueChangedCopyWith<$Res> {
  factory _$$_BleValueChangedCopyWith(
          _$_BleValueChanged value, $Res Function(_$_BleValueChanged) then) =
      __$$_BleValueChangedCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId, String characteristicId, Uint8List value});
}

/// @nodoc
class __$$_BleValueChangedCopyWithImpl<$Res>
    extends _$BleValueChangedCopyWithImpl<$Res, _$_BleValueChanged>
    implements _$$_BleValueChangedCopyWith<$Res> {
  __$$_BleValueChangedCopyWithImpl(
      _$_BleValueChanged _value, $Res Function(_$_BleValueChanged) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? characteristicId = null,
    Object? value = null,
  }) {
    return _then(_$_BleValueChanged(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      null == characteristicId
          ? _value.characteristicId
          : characteristicId // ignore: cast_nullable_to_non_nullable
              as String,
      null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _$_BleValueChanged implements _BleValueChanged {
  _$_BleValueChanged(this.deviceId, this.characteristicId, this.value);

  @override
  final String deviceId;
  @override
  final String characteristicId;
  @override
  final Uint8List value;

  @override
  String toString() {
    return 'BleValueChanged(deviceId: $deviceId, characteristicId: $characteristicId, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BleValueChanged &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.characteristicId, characteristicId) ||
                other.characteristicId == characteristicId) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, characteristicId,
      const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BleValueChangedCopyWith<_$_BleValueChanged> get copyWith =>
      __$$_BleValueChangedCopyWithImpl<_$_BleValueChanged>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String characteristicId, Uint8List value)
        $default, {
    required TResult Function(Object? error, StackTrace? stackTrace) error,
  }) {
    return $default(deviceId, characteristicId, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String deviceId, String characteristicId, Uint8List value)?
        $default, {
    TResult? Function(Object? error, StackTrace? stackTrace)? error,
  }) {
    return $default?.call(deviceId, characteristicId, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String characteristicId, Uint8List value)?
        $default, {
    TResult Function(Object? error, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(deviceId, characteristicId, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleValueChanged value) $default, {
    required TResult Function(Error value) error,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleValueChanged value)? $default, {
    TResult? Function(Error value)? error,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleValueChanged value)? $default, {
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _BleValueChanged implements BleValueChanged {
  factory _BleValueChanged(final String deviceId, final String characteristicId,
      final Uint8List value) = _$_BleValueChanged;

  String get deviceId;
  String get characteristicId;
  Uint8List get value;
  @JsonKey(ignore: true)
  _$$_BleValueChangedCopyWith<_$_BleValueChanged> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorCopyWith<$Res> {
  factory _$$ErrorCopyWith(_$Error value, $Res Function(_$Error) then) =
      __$$ErrorCopyWithImpl<$Res>;
  @useResult
  $Res call({Object? error, StackTrace? stackTrace});
}

/// @nodoc
class __$$ErrorCopyWithImpl<$Res>
    extends _$BleValueChangedCopyWithImpl<$Res, _$Error>
    implements _$$ErrorCopyWith<$Res> {
  __$$ErrorCopyWithImpl(_$Error _value, $Res Function(_$Error) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_$Error(
      freezed == error ? _value.error : error,
      freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$Error implements Error {
  _$Error(this.error, this.stackTrace);

  @override
  final Object? error;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'BleValueChanged.error(error: $error, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(error), stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorCopyWith<_$Error> get copyWith =>
      __$$ErrorCopyWithImpl<_$Error>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String characteristicId, Uint8List value)
        $default, {
    required TResult Function(Object? error, StackTrace? stackTrace) error,
  }) {
    return error(this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String deviceId, String characteristicId, Uint8List value)?
        $default, {
    TResult? Function(Object? error, StackTrace? stackTrace)? error,
  }) {
    return error?.call(this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String characteristicId, Uint8List value)?
        $default, {
    TResult Function(Object? error, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleValueChanged value) $default, {
    required TResult Function(Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleValueChanged value)? $default, {
    TResult? Function(Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleValueChanged value)? $default, {
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class Error implements BleValueChanged {
  factory Error(final Object? error, final StackTrace? stackTrace) = _$Error;

  Object? get error;
  StackTrace? get stackTrace;
  @JsonKey(ignore: true)
  _$$ErrorCopyWith<_$Error> get copyWith => throw _privateConstructorUsedError;
}
