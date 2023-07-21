// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bleScannerHash() => r'9c791dcf4e61aec9c8b6bc775b59e8fe6680a986';

/// See also [BleScanner].
@ProviderFor(BleScanner)
final bleScannerProvider =
    AutoDisposeNotifierProvider<BleScanner, List<BleDevice>>.internal(
  BleScanner.new,
  name: r'bleScannerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bleScannerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleScanner = AutoDisposeNotifier<List<BleDevice>>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
