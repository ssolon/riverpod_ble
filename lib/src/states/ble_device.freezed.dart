// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BleDevice {
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)
        $default, {
    required TResult Function() initial,
    required TResult Function(String id) connecting,
    required TResult Function(String deviceId, String name) scanned,
    required TResult Function(Object error, StackTrace? stack) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult? Function()? initial,
    TResult? Function(String id)? connecting,
    TResult? Function(String deviceId, String name)? scanned,
    TResult? Function(Object error, StackTrace? stack)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult Function()? initial,
    TResult Function(String id)? connecting,
    TResult Function(String deviceId, String name)? scanned,
    TResult Function(Object error, StackTrace? stack)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleDevice value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Connecting value) connecting,
    required TResult Function(Scanned value) scanned,
    required TResult Function(Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleDevice value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Connecting value)? connecting,
    TResult? Function(Scanned value)? scanned,
    TResult? Function(Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleDevice value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Connecting value)? connecting,
    TResult Function(Scanned value)? scanned,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleDeviceCopyWith<$Res> {
  factory $BleDeviceCopyWith(BleDevice value, $Res Function(BleDevice) then) =
      _$BleDeviceCopyWithImpl<$Res, BleDevice>;
}

/// @nodoc
class _$BleDeviceCopyWithImpl<$Res, $Val extends BleDevice>
    implements $BleDeviceCopyWith<$Res> {
  _$BleDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialCopyWith<$Res> {
  factory _$$InitialCopyWith(_$Initial value, $Res Function(_$Initial) then) =
      __$$InitialCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialCopyWithImpl<$Res>
    extends _$BleDeviceCopyWithImpl<$Res, _$Initial>
    implements _$$InitialCopyWith<$Res> {
  __$$InitialCopyWithImpl(_$Initial _value, $Res Function(_$Initial) _then)
      : super(_value, _then);
}

/// @nodoc

class _$Initial implements Initial {
  _$Initial();

  @override
  String toString() {
    return 'BleDevice.initial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)
        $default, {
    required TResult Function() initial,
    required TResult Function(String id) connecting,
    required TResult Function(String deviceId, String name) scanned,
    required TResult Function(Object error, StackTrace? stack) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult? Function()? initial,
    TResult? Function(String id)? connecting,
    TResult? Function(String deviceId, String name)? scanned,
    TResult? Function(Object error, StackTrace? stack)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult Function()? initial,
    TResult Function(String id)? connecting,
    TResult Function(String deviceId, String name)? scanned,
    TResult Function(Object error, StackTrace? stack)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleDevice value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Connecting value) connecting,
    required TResult Function(Scanned value) scanned,
    required TResult Function(Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleDevice value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Connecting value)? connecting,
    TResult? Function(Scanned value)? scanned,
    TResult? Function(Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleDevice value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Connecting value)? connecting,
    TResult Function(Scanned value)? scanned,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class Initial implements BleDevice {
  factory Initial() = _$Initial;
}

/// @nodoc
abstract class _$$ConnectingCopyWith<$Res> {
  factory _$$ConnectingCopyWith(
          _$Connecting value, $Res Function(_$Connecting) then) =
      __$$ConnectingCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$ConnectingCopyWithImpl<$Res>
    extends _$BleDeviceCopyWithImpl<$Res, _$Connecting>
    implements _$$ConnectingCopyWith<$Res> {
  __$$ConnectingCopyWithImpl(
      _$Connecting _value, $Res Function(_$Connecting) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$Connecting(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Connecting implements Connecting {
  _$Connecting({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'BleDevice.connecting(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Connecting &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectingCopyWith<_$Connecting> get copyWith =>
      __$$ConnectingCopyWithImpl<_$Connecting>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)
        $default, {
    required TResult Function() initial,
    required TResult Function(String id) connecting,
    required TResult Function(String deviceId, String name) scanned,
    required TResult Function(Object error, StackTrace? stack) error,
  }) {
    return connecting(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult? Function()? initial,
    TResult? Function(String id)? connecting,
    TResult? Function(String deviceId, String name)? scanned,
    TResult? Function(Object error, StackTrace? stack)? error,
  }) {
    return connecting?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult Function()? initial,
    TResult Function(String id)? connecting,
    TResult Function(String deviceId, String name)? scanned,
    TResult Function(Object error, StackTrace? stack)? error,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleDevice value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Connecting value) connecting,
    required TResult Function(Scanned value) scanned,
    required TResult Function(Error value) error,
  }) {
    return connecting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleDevice value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Connecting value)? connecting,
    TResult? Function(Scanned value)? scanned,
    TResult? Function(Error value)? error,
  }) {
    return connecting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleDevice value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Connecting value)? connecting,
    TResult Function(Scanned value)? scanned,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting(this);
    }
    return orElse();
  }
}

abstract class Connecting implements BleDevice {
  factory Connecting({required final String id}) = _$Connecting;

  String get id;
  @JsonKey(ignore: true)
  _$$ConnectingCopyWith<_$Connecting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ScannedCopyWith<$Res> {
  factory _$$ScannedCopyWith(_$Scanned value, $Res Function(_$Scanned) then) =
      __$$ScannedCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId, String name});
}

/// @nodoc
class __$$ScannedCopyWithImpl<$Res>
    extends _$BleDeviceCopyWithImpl<$Res, _$Scanned>
    implements _$$ScannedCopyWith<$Res> {
  __$$ScannedCopyWithImpl(_$Scanned _value, $Res Function(_$Scanned) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? name = null,
  }) {
    return _then(_$Scanned(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Scanned implements Scanned {
  _$Scanned(this.deviceId, this.name);

  @override
  final String deviceId;
  @override
  final String name;

  @override
  String toString() {
    return 'BleDevice.scanned(deviceId: $deviceId, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Scanned &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScannedCopyWith<_$Scanned> get copyWith =>
      __$$ScannedCopyWithImpl<_$Scanned>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)
        $default, {
    required TResult Function() initial,
    required TResult Function(String id) connecting,
    required TResult Function(String deviceId, String name) scanned,
    required TResult Function(Object error, StackTrace? stack) error,
  }) {
    return scanned(deviceId, name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult? Function()? initial,
    TResult? Function(String id)? connecting,
    TResult? Function(String deviceId, String name)? scanned,
    TResult? Function(Object error, StackTrace? stack)? error,
  }) {
    return scanned?.call(deviceId, name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult Function()? initial,
    TResult Function(String id)? connecting,
    TResult Function(String deviceId, String name)? scanned,
    TResult Function(Object error, StackTrace? stack)? error,
    required TResult orElse(),
  }) {
    if (scanned != null) {
      return scanned(deviceId, name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleDevice value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Connecting value) connecting,
    required TResult Function(Scanned value) scanned,
    required TResult Function(Error value) error,
  }) {
    return scanned(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleDevice value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Connecting value)? connecting,
    TResult? Function(Scanned value)? scanned,
    TResult? Function(Error value)? error,
  }) {
    return scanned?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleDevice value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Connecting value)? connecting,
    TResult Function(Scanned value)? scanned,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (scanned != null) {
      return scanned(this);
    }
    return orElse();
  }
}

abstract class Scanned implements BleDevice {
  factory Scanned(final String deviceId, final String name) = _$Scanned;

  String get deviceId;
  String get name;
  @JsonKey(ignore: true)
  _$$ScannedCopyWith<_$Scanned> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_BleDeviceCopyWith<$Res> {
  factory _$$_BleDeviceCopyWith(
          _$_BleDevice value, $Res Function(_$_BleDevice) then) =
      __$$_BleDeviceCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String deviceId,
      String? name,
      BleConnectionStatus status,
      List<Object> services});

  $BleConnectionStatusCopyWith<$Res> get status;
}

/// @nodoc
class __$$_BleDeviceCopyWithImpl<$Res>
    extends _$BleDeviceCopyWithImpl<$Res, _$_BleDevice>
    implements _$$_BleDeviceCopyWith<$Res> {
  __$$_BleDeviceCopyWithImpl(
      _$_BleDevice _value, $Res Function(_$_BleDevice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? name = freezed,
    Object? status = null,
    Object? services = null,
  }) {
    return _then(_$_BleDevice(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BleConnectionStatus,
      services: null == services
          ? _value._services
          : services // ignore: cast_nullable_to_non_nullable
              as List<Object>,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $BleConnectionStatusCopyWith<$Res> get status {
    return $BleConnectionStatusCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value));
    });
  }
}

/// @nodoc

class _$_BleDevice implements _BleDevice {
  _$_BleDevice(
      {required this.deviceId,
      this.name,
      required this.status,
      final List<Object> services = const []})
      : _services = services;

  @override
  final String deviceId;
  @override
  final String? name;
  @override
  final BleConnectionStatus status;
  final List<Object> _services;
  @override
  @JsonKey()
  List<Object> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  String toString() {
    return 'BleDevice(deviceId: $deviceId, name: $name, status: $status, services: $services)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BleDevice &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._services, _services));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, name, status,
      const DeepCollectionEquality().hash(_services));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BleDeviceCopyWith<_$_BleDevice> get copyWith =>
      __$$_BleDeviceCopyWithImpl<_$_BleDevice>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)
        $default, {
    required TResult Function() initial,
    required TResult Function(String id) connecting,
    required TResult Function(String deviceId, String name) scanned,
    required TResult Function(Object error, StackTrace? stack) error,
  }) {
    return $default(deviceId, name, status, services);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult? Function()? initial,
    TResult? Function(String id)? connecting,
    TResult? Function(String deviceId, String name)? scanned,
    TResult? Function(Object error, StackTrace? stack)? error,
  }) {
    return $default?.call(deviceId, name, status, services);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult Function()? initial,
    TResult Function(String id)? connecting,
    TResult Function(String deviceId, String name)? scanned,
    TResult Function(Object error, StackTrace? stack)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(deviceId, name, status, services);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleDevice value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Connecting value) connecting,
    required TResult Function(Scanned value) scanned,
    required TResult Function(Error value) error,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleDevice value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Connecting value)? connecting,
    TResult? Function(Scanned value)? scanned,
    TResult? Function(Error value)? error,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleDevice value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Connecting value)? connecting,
    TResult Function(Scanned value)? scanned,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _BleDevice implements BleDevice {
  factory _BleDevice(
      {required final String deviceId,
      final String? name,
      required final BleConnectionStatus status,
      final List<Object> services}) = _$_BleDevice;

  String get deviceId;
  String? get name;
  BleConnectionStatus get status;
  List<Object> get services;
  @JsonKey(ignore: true)
  _$$_BleDeviceCopyWith<_$_BleDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorCopyWith<$Res> {
  factory _$$ErrorCopyWith(_$Error value, $Res Function(_$Error) then) =
      __$$ErrorCopyWithImpl<$Res>;
  @useResult
  $Res call({Object error, StackTrace? stack});
}

/// @nodoc
class __$$ErrorCopyWithImpl<$Res> extends _$BleDeviceCopyWithImpl<$Res, _$Error>
    implements _$$ErrorCopyWith<$Res> {
  __$$ErrorCopyWithImpl(_$Error _value, $Res Function(_$Error) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? stack = freezed,
  }) {
    return _then(_$Error(
      error: null == error ? _value.error : error,
      stack: freezed == stack
          ? _value.stack
          : stack // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$Error implements Error {
  _$Error({required this.error, this.stack});

  @override
  final Object error;
  @override
  final StackTrace? stack;

  @override
  String toString() {
    return 'BleDevice.error(error: $error, stack: $stack)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.stack, stack) || other.stack == stack));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(error), stack);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorCopyWith<_$Error> get copyWith =>
      __$$ErrorCopyWithImpl<_$Error>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)
        $default, {
    required TResult Function() initial,
    required TResult Function(String id) connecting,
    required TResult Function(String deviceId, String name) scanned,
    required TResult Function(Object error, StackTrace? stack) error,
  }) {
    return error(this.error, stack);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult? Function()? initial,
    TResult? Function(String id)? connecting,
    TResult? Function(String deviceId, String name)? scanned,
    TResult? Function(Object error, StackTrace? stack)? error,
  }) {
    return error?.call(this.error, stack);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String? name, BleConnectionStatus status,
            List<Object> services)?
        $default, {
    TResult Function()? initial,
    TResult Function(String id)? connecting,
    TResult Function(String deviceId, String name)? scanned,
    TResult Function(Object error, StackTrace? stack)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error, stack);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BleDevice value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Connecting value) connecting,
    required TResult Function(Scanned value) scanned,
    required TResult Function(Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BleDevice value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Connecting value)? connecting,
    TResult? Function(Scanned value)? scanned,
    TResult? Function(Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BleDevice value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Connecting value)? connecting,
    TResult Function(Scanned value)? scanned,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class Error implements BleDevice {
  factory Error({required final Object error, final StackTrace? stack}) =
      _$Error;

  Object get error;
  StackTrace? get stack;
  @JsonKey(ignore: true)
  _$$ErrorCopyWith<_$Error> get copyWith => throw _privateConstructorUsedError;
}
