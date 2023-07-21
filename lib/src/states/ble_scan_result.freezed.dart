// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_scan_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BleScanResult {
  BleDevice get device => throw _privateConstructorUsedError;
  int get rssi => throw _privateConstructorUsedError;
  DateTime get timeStamp => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BleScanResultCopyWith<BleScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleScanResultCopyWith<$Res> {
  factory $BleScanResultCopyWith(
          BleScanResult value, $Res Function(BleScanResult) then) =
      _$BleScanResultCopyWithImpl<$Res, BleScanResult>;
  @useResult
  $Res call({BleDevice device, int rssi, DateTime timeStamp});

  $BleDeviceCopyWith<$Res> get device;
}

/// @nodoc
class _$BleScanResultCopyWithImpl<$Res, $Val extends BleScanResult>
    implements $BleScanResultCopyWith<$Res> {
  _$BleScanResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = null,
    Object? rssi = null,
    Object? timeStamp = null,
  }) {
    return _then(_value.copyWith(
      device: null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as BleDevice,
      rssi: null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BleDeviceCopyWith<$Res> get device {
    return $BleDeviceCopyWith<$Res>(_value.device, (value) {
      return _then(_value.copyWith(device: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_BleScanResultCopyWith<$Res>
    implements $BleScanResultCopyWith<$Res> {
  factory _$$_BleScanResultCopyWith(
          _$_BleScanResult value, $Res Function(_$_BleScanResult) then) =
      __$$_BleScanResultCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BleDevice device, int rssi, DateTime timeStamp});

  @override
  $BleDeviceCopyWith<$Res> get device;
}

/// @nodoc
class __$$_BleScanResultCopyWithImpl<$Res>
    extends _$BleScanResultCopyWithImpl<$Res, _$_BleScanResult>
    implements _$$_BleScanResultCopyWith<$Res> {
  __$$_BleScanResultCopyWithImpl(
      _$_BleScanResult _value, $Res Function(_$_BleScanResult) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = null,
    Object? rssi = null,
    Object? timeStamp = null,
  }) {
    return _then(_$_BleScanResult(
      null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as BleDevice,
      null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int,
      null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$_BleScanResult implements _BleScanResult {
  _$_BleScanResult(this.device, this.rssi, this.timeStamp);

  @override
  final BleDevice device;
  @override
  final int rssi;
  @override
  final DateTime timeStamp;

  @override
  String toString() {
    return 'BleScanResult(device: $device, rssi: $rssi, timeStamp: $timeStamp)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BleScanResult &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.rssi, rssi) || other.rssi == rssi) &&
            (identical(other.timeStamp, timeStamp) ||
                other.timeStamp == timeStamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device, rssi, timeStamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BleScanResultCopyWith<_$_BleScanResult> get copyWith =>
      __$$_BleScanResultCopyWithImpl<_$_BleScanResult>(this, _$identity);
}

abstract class _BleScanResult implements BleScanResult {
  factory _BleScanResult(
          final BleDevice device, final int rssi, final DateTime timeStamp) =
      _$_BleScanResult;

  @override
  BleDevice get device;
  @override
  int get rssi;
  @override
  DateTime get timeStamp;
  @override
  @JsonKey(ignore: true)
  _$$_BleScanResultCopyWith<_$_BleScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}
