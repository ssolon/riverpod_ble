// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_connection_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BleConnectionEvent {
  String get deviceId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  BleConnectionStatus get status => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BleConnectionEventCopyWith<BleConnectionEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleConnectionEventCopyWith<$Res> {
  factory $BleConnectionEventCopyWith(
          BleConnectionEvent value, $Res Function(BleConnectionEvent) then) =
      _$BleConnectionEventCopyWithImpl<$Res, BleConnectionEvent>;
  @useResult
  $Res call({String deviceId, String? name, BleConnectionStatus status});

  $BleConnectionStatusCopyWith<$Res> get status;
}

/// @nodoc
class _$BleConnectionEventCopyWithImpl<$Res, $Val extends BleConnectionEvent>
    implements $BleConnectionEventCopyWith<$Res> {
  _$BleConnectionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? name = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BleConnectionStatusCopyWith<$Res> get status {
    return $BleConnectionStatusCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_BleConnectionEventCopyWith<$Res>
    implements $BleConnectionEventCopyWith<$Res> {
  factory _$$_BleConnectionEventCopyWith(_$_BleConnectionEvent value,
          $Res Function(_$_BleConnectionEvent) then) =
      __$$_BleConnectionEventCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String deviceId, String? name, BleConnectionStatus status});

  @override
  $BleConnectionStatusCopyWith<$Res> get status;
}

/// @nodoc
class __$$_BleConnectionEventCopyWithImpl<$Res>
    extends _$BleConnectionEventCopyWithImpl<$Res, _$_BleConnectionEvent>
    implements _$$_BleConnectionEventCopyWith<$Res> {
  __$$_BleConnectionEventCopyWithImpl(
      _$_BleConnectionEvent _value, $Res Function(_$_BleConnectionEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? name = freezed,
    Object? status = null,
  }) {
    return _then(_$_BleConnectionEvent(
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
    ));
  }
}

/// @nodoc

class _$_BleConnectionEvent implements _BleConnectionEvent {
  _$_BleConnectionEvent(
      {required this.deviceId, this.name, required this.status});

  @override
  final String deviceId;
  @override
  final String? name;
  @override
  final BleConnectionStatus status;

  @override
  String toString() {
    return 'BleConnectionEvent(deviceId: $deviceId, name: $name, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BleConnectionEvent &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, name, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BleConnectionEventCopyWith<_$_BleConnectionEvent> get copyWith =>
      __$$_BleConnectionEventCopyWithImpl<_$_BleConnectionEvent>(
          this, _$identity);
}

abstract class _BleConnectionEvent implements BleConnectionEvent {
  factory _BleConnectionEvent(
      {required final String deviceId,
      final String? name,
      required final BleConnectionStatus status}) = _$_BleConnectionEvent;

  @override
  String get deviceId;
  @override
  String? get name;
  @override
  BleConnectionStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$_BleConnectionEventCopyWith<_$_BleConnectionEvent> get copyWith =>
      throw _privateConstructorUsedError;
}
