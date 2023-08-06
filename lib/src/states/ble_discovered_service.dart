import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_ble/riverpod_ble.dart';

part 'ble_discovered_service.freezed.dart';

@freezed
class BleDiscoveredServices with _$BleDiscoveredServices {
  factory BleDiscoveredServices.initial() = Initial;
  factory BleDiscoveredServices.loading() = Loading;
  factory BleDiscoveredServices(List<BleDiscoveredService> services) = Data;
  factory BleDiscoveredServices.error(Object error, StackTrace? stackTrace) =
      Error;
}

@freezed
class BleDiscoveredService with _$BleDiscoveredService {
  factory BleDiscoveredService(
          String deviceId, BleUUID serviceId, List<String> characteristics) =
      _BleDiscoveredService;
}
