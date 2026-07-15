// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authApiServiceHash() => r'544c1676d730de3d1cbc7e43f949e66bf7d55896';

/// See also [authApiService].
@ProviderFor(authApiService)
final authApiServiceProvider = Provider<AuthApiService>.internal(
  authApiService,
  name: r'authApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthApiServiceRef = ProviderRef<AuthApiService>;
String _$syncServiceHash() => r'e1e82ef8f13af703103a4ead3e289aed198b5781';

/// See also [syncService].
@ProviderFor(syncService)
final syncServiceProvider = Provider<SyncService>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncServiceRef = ProviderRef<SyncService>;
String _$authControllerHash() => r'd321701b3181be78f508a5811a25823e74e95b15';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AuthSession?>>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = Notifier<AsyncValue<AuthSession?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
