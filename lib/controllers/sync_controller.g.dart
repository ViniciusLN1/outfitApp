// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncControllerHash() => r'4c0721bfa9db428d2e12752dfde970b267202029';

/// Sobe o bundle da conta logada: com debounce a cada mudança no banco
/// (qualquer tabela) e sob demanda via [syncNow]. Falha só marca
/// [SyncPhase.error] — nunca bloqueia nem crasha o uso do app.
///
/// Copied from [SyncController].
@ProviderFor(SyncController)
final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>.internal(
      SyncController.new,
      name: r'syncControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncController = Notifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
