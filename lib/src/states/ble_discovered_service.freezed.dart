// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_discovered_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BleDiscoveredServices {
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services) $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Object error, StackTrace? stackTrace) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<BleDiscoveredService> services)? $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Object error, StackTrace? stackTrace)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services)? $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Object error, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleDiscoveredServicesCopyWith<$Res> {
  factory $BleDiscoveredServicesCopyWith(BleDiscoveredServices value,
          $Res Function(BleDiscoveredServices) then) =
      _$BleDiscoveredServicesCopyWithImpl<$Res, BleDiscoveredServices>;
}

/// @nodoc
class _$BleDiscoveredServicesCopyWithImpl<$Res,
        $Val extends BleDiscoveredServices>
    implements $BleDiscoveredServicesCopyWith<$Res> {
  _$BleDiscoveredServicesCopyWithImpl(this._value, this._then);

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
    extends _$BleDiscoveredServicesCopyWithImpl<$Res, _$Initial>
    implements _$$InitialCopyWith<$Res> {
  __$$InitialCopyWithImpl(_$Initial _value, $Res Function(_$Initial) _then)
      : super(_value, _then);
}

/// @nodoc

class _$Initial implements Initial {
  _$Initial();

  @override
  String toString() {
    return 'BleDiscoveredServices.initial()';
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
    TResult Function(List<BleDiscoveredService> services) $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Object error, StackTrace? stackTrace) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<BleDiscoveredService> services)? $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Object error, StackTrace? stackTrace)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services)? $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Object error, StackTrace? stackTrace)? error,
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
    TResult Function(Data value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class Initial implements BleDiscoveredServices {
  factory Initial() = _$Initial;
}

/// @nodoc
abstract class _$$LoadingCopyWith<$Res> {
  factory _$$LoadingCopyWith(_$Loading value, $Res Function(_$Loading) then) =
      __$$LoadingCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingCopyWithImpl<$Res>
    extends _$BleDiscoveredServicesCopyWithImpl<$Res, _$Loading>
    implements _$$LoadingCopyWith<$Res> {
  __$$LoadingCopyWithImpl(_$Loading _value, $Res Function(_$Loading) _then)
      : super(_value, _then);
}

/// @nodoc

class _$Loading implements Loading {
  _$Loading();

  @override
  String toString() {
    return 'BleDiscoveredServices.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$Loading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services) $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Object error, StackTrace? stackTrace) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<BleDiscoveredService> services)? $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Object error, StackTrace? stackTrace)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services)? $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Object error, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class Loading implements BleDiscoveredServices {
  factory Loading() = _$Loading;
}

/// @nodoc
abstract class _$$DataCopyWith<$Res> {
  factory _$$DataCopyWith(_$Data value, $Res Function(_$Data) then) =
      __$$DataCopyWithImpl<$Res>;
  @useResult
  $Res call({List<BleDiscoveredService> services});
}

/// @nodoc
class __$$DataCopyWithImpl<$Res>
    extends _$BleDiscoveredServicesCopyWithImpl<$Res, _$Data>
    implements _$$DataCopyWith<$Res> {
  __$$DataCopyWithImpl(_$Data _value, $Res Function(_$Data) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? services = null,
  }) {
    return _then(_$Data(
      null == services
          ? _value._services
          : services // ignore: cast_nullable_to_non_nullable
              as List<BleDiscoveredService>,
    ));
  }
}

/// @nodoc

class _$Data implements Data {
  _$Data(final List<BleDiscoveredService> services) : _services = services;

  final List<BleDiscoveredService> _services;
  @override
  List<BleDiscoveredService> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  String toString() {
    return 'BleDiscoveredServices(services: $services)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Data &&
            const DeepCollectionEquality().equals(other._services, _services));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_services));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataCopyWith<_$Data> get copyWith =>
      __$$DataCopyWithImpl<_$Data>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services) $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Object error, StackTrace? stackTrace) error,
  }) {
    return $default(services);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<BleDiscoveredService> services)? $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Object error, StackTrace? stackTrace)? error,
  }) {
    return $default?.call(services);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services)? $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Object error, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(services);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Error value) error,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Error value)? error,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class Data implements BleDiscoveredServices {
  factory Data(final List<BleDiscoveredService> services) = _$Data;

  List<BleDiscoveredService> get services;
  @JsonKey(ignore: true)
  _$$DataCopyWith<_$Data> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorCopyWith<$Res> {
  factory _$$ErrorCopyWith(_$Error value, $Res Function(_$Error) then) =
      __$$ErrorCopyWithImpl<$Res>;
  @useResult
  $Res call({Object error, StackTrace? stackTrace});
}

/// @nodoc
class __$$ErrorCopyWithImpl<$Res>
    extends _$BleDiscoveredServicesCopyWithImpl<$Res, _$Error>
    implements _$$ErrorCopyWith<$Res> {
  __$$ErrorCopyWithImpl(_$Error _value, $Res Function(_$Error) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? stackTrace = freezed,
  }) {
    return _then(_$Error(
      null == error ? _value.error : error,
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
  final Object error;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'BleDiscoveredServices.error(error: $error, stackTrace: $stackTrace)';
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
    TResult Function(List<BleDiscoveredService> services) $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Object error, StackTrace? stackTrace) error,
  }) {
    return error(this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<BleDiscoveredService> services)? $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Object error, StackTrace? stackTrace)? error,
  }) {
    return error?.call(this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<BleDiscoveredService> services)? $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Object error, StackTrace? stackTrace)? error,
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
    TResult Function(Data value) $default, {
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data value)? $default, {
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data value)? $default, {
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class Error implements BleDiscoveredServices {
  factory Error(final Object error, final StackTrace? stackTrace) = _$Error;

  Object get error;
  StackTrace? get stackTrace;
  @JsonKey(ignore: true)
  _$$ErrorCopyWith<_$Error> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BleDiscoveredService {
  String get deviceId => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  List<String> get characteristics => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BleDiscoveredServiceCopyWith<BleDiscoveredService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleDiscoveredServiceCopyWith<$Res> {
  factory $BleDiscoveredServiceCopyWith(BleDiscoveredService value,
          $Res Function(BleDiscoveredService) then) =
      _$BleDiscoveredServiceCopyWithImpl<$Res, BleDiscoveredService>;
  @useResult
  $Res call({String deviceId, String serviceId, List<String> characteristics});
}

/// @nodoc
class _$BleDiscoveredServiceCopyWithImpl<$Res,
        $Val extends BleDiscoveredService>
    implements $BleDiscoveredServiceCopyWith<$Res> {
  _$BleDiscoveredServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? serviceId = null,
    Object? characteristics = null,
  }) {
    return _then(_value.copyWith(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceId: null == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String,
      characteristics: null == characteristics
          ? _value.characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BleDiscoveredServiceCopyWith<$Res>
    implements $BleDiscoveredServiceCopyWith<$Res> {
  factory _$$_BleDiscoveredServiceCopyWith(_$_BleDiscoveredService value,
          $Res Function(_$_BleDiscoveredService) then) =
      __$$_BleDiscoveredServiceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String deviceId, String serviceId, List<String> characteristics});
}

/// @nodoc
class __$$_BleDiscoveredServiceCopyWithImpl<$Res>
    extends _$BleDiscoveredServiceCopyWithImpl<$Res, _$_BleDiscoveredService>
    implements _$$_BleDiscoveredServiceCopyWith<$Res> {
  __$$_BleDiscoveredServiceCopyWithImpl(_$_BleDiscoveredService _value,
      $Res Function(_$_BleDiscoveredService) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? serviceId = null,
    Object? characteristics = null,
  }) {
    return _then(_$_BleDiscoveredService(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      null == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String,
      null == characteristics
          ? _value._characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$_BleDiscoveredService implements _BleDiscoveredService {
  _$_BleDiscoveredService(
      this.deviceId, this.serviceId, final List<String> characteristics)
      : _characteristics = characteristics;

  @override
  final String deviceId;
  @override
  final String serviceId;
  final List<String> _characteristics;
  @override
  List<String> get characteristics {
    if (_characteristics is EqualUnmodifiableListView) return _characteristics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_characteristics);
  }

  @override
  String toString() {
    return 'BleDiscoveredService(deviceId: $deviceId, serviceId: $serviceId, characteristics: $characteristics)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BleDiscoveredService &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            const DeepCollectionEquality()
                .equals(other._characteristics, _characteristics));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, serviceId,
      const DeepCollectionEquality().hash(_characteristics));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BleDiscoveredServiceCopyWith<_$_BleDiscoveredService> get copyWith =>
      __$$_BleDiscoveredServiceCopyWithImpl<_$_BleDiscoveredService>(
          this, _$identity);
}

abstract class _BleDiscoveredService implements BleDiscoveredService {
  factory _BleDiscoveredService(final String deviceId, final String serviceId,
      final List<String> characteristics) = _$_BleDiscoveredService;

  @override
  String get deviceId;
  @override
  String get serviceId;
  @override
  List<String> get characteristics;
  @override
  @JsonKey(ignore: true)
  _$$_BleDiscoveredServiceCopyWith<_$_BleDiscoveredService> get copyWith =>
      throw _privateConstructorUsedError;
}
