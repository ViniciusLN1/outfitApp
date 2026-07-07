// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$usageEntriesHash() => r'caaeecfaf9f255a129043d67dee2da29dd04c687';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Registros de uso resolvidos com o look (calendário/histórico global).
/// [outfitId] nulo = todos os looks.
///
/// Copied from [usageEntries].
@ProviderFor(usageEntries)
const usageEntriesProvider = UsageEntriesFamily();

/// Registros de uso resolvidos com o look (calendário/histórico global).
/// [outfitId] nulo = todos os looks.
///
/// Copied from [usageEntries].
class UsageEntriesFamily extends Family<AsyncValue<List<UsageEntry>>> {
  /// Registros de uso resolvidos com o look (calendário/histórico global).
  /// [outfitId] nulo = todos os looks.
  ///
  /// Copied from [usageEntries].
  const UsageEntriesFamily();

  /// Registros de uso resolvidos com o look (calendário/histórico global).
  /// [outfitId] nulo = todos os looks.
  ///
  /// Copied from [usageEntries].
  UsageEntriesProvider call(String? outfitId) {
    return UsageEntriesProvider(outfitId);
  }

  @override
  UsageEntriesProvider getProviderOverride(
    covariant UsageEntriesProvider provider,
  ) {
    return call(provider.outfitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'usageEntriesProvider';
}

/// Registros de uso resolvidos com o look (calendário/histórico global).
/// [outfitId] nulo = todos os looks.
///
/// Copied from [usageEntries].
class UsageEntriesProvider extends AutoDisposeStreamProvider<List<UsageEntry>> {
  /// Registros de uso resolvidos com o look (calendário/histórico global).
  /// [outfitId] nulo = todos os looks.
  ///
  /// Copied from [usageEntries].
  UsageEntriesProvider(String? outfitId)
    : this._internal(
        (ref) => usageEntries(ref as UsageEntriesRef, outfitId),
        from: usageEntriesProvider,
        name: r'usageEntriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$usageEntriesHash,
        dependencies: UsageEntriesFamily._dependencies,
        allTransitiveDependencies:
            UsageEntriesFamily._allTransitiveDependencies,
        outfitId: outfitId,
      );

  UsageEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.outfitId,
  }) : super.internal();

  final String? outfitId;

  @override
  Override overrideWith(
    Stream<List<UsageEntry>> Function(UsageEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsageEntriesProvider._internal(
        (ref) => create(ref as UsageEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        outfitId: outfitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UsageEntry>> createElement() {
    return _UsageEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsageEntriesProvider && other.outfitId == outfitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, outfitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UsageEntriesRef on AutoDisposeStreamProviderRef<List<UsageEntry>> {
  /// The parameter `outfitId` of this provider.
  String? get outfitId;
}

class _UsageEntriesProviderElement
    extends AutoDisposeStreamProviderElement<List<UsageEntry>>
    with UsageEntriesRef {
  _UsageEntriesProviderElement(super.provider);

  @override
  String? get outfitId => (origin as UsageEntriesProvider).outfitId;
}

String _$outfitUsageHistoryHash() =>
    r'8567f58944ca1be7b2c8af35764faa65486e85d8';

/// See also [outfitUsageHistory].
@ProviderFor(outfitUsageHistory)
const outfitUsageHistoryProvider = OutfitUsageHistoryFamily();

/// See also [outfitUsageHistory].
class OutfitUsageHistoryFamily extends Family<AsyncValue<List<OutfitUsage>>> {
  /// See also [outfitUsageHistory].
  const OutfitUsageHistoryFamily();

  /// See also [outfitUsageHistory].
  OutfitUsageHistoryProvider call(String outfitId) {
    return OutfitUsageHistoryProvider(outfitId);
  }

  @override
  OutfitUsageHistoryProvider getProviderOverride(
    covariant OutfitUsageHistoryProvider provider,
  ) {
    return call(provider.outfitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'outfitUsageHistoryProvider';
}

/// See also [outfitUsageHistory].
class OutfitUsageHistoryProvider
    extends AutoDisposeStreamProvider<List<OutfitUsage>> {
  /// See also [outfitUsageHistory].
  OutfitUsageHistoryProvider(String outfitId)
    : this._internal(
        (ref) => outfitUsageHistory(ref as OutfitUsageHistoryRef, outfitId),
        from: outfitUsageHistoryProvider,
        name: r'outfitUsageHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$outfitUsageHistoryHash,
        dependencies: OutfitUsageHistoryFamily._dependencies,
        allTransitiveDependencies:
            OutfitUsageHistoryFamily._allTransitiveDependencies,
        outfitId: outfitId,
      );

  OutfitUsageHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.outfitId,
  }) : super.internal();

  final String outfitId;

  @override
  Override overrideWith(
    Stream<List<OutfitUsage>> Function(OutfitUsageHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OutfitUsageHistoryProvider._internal(
        (ref) => create(ref as OutfitUsageHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        outfitId: outfitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<OutfitUsage>> createElement() {
    return _OutfitUsageHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OutfitUsageHistoryProvider && other.outfitId == outfitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, outfitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OutfitUsageHistoryRef on AutoDisposeStreamProviderRef<List<OutfitUsage>> {
  /// The parameter `outfitId` of this provider.
  String get outfitId;
}

class _OutfitUsageHistoryProviderElement
    extends AutoDisposeStreamProviderElement<List<OutfitUsage>>
    with OutfitUsageHistoryRef {
  _OutfitUsageHistoryProviderElement(super.provider);

  @override
  String get outfitId => (origin as OutfitUsageHistoryProvider).outfitId;
}

String _$outfitUsageTotalHash() => r'7d4d2e4ad6963bdd9325b3cc0eed4ccbbd39c053';

/// See also [outfitUsageTotal].
@ProviderFor(outfitUsageTotal)
const outfitUsageTotalProvider = OutfitUsageTotalFamily();

/// See also [outfitUsageTotal].
class OutfitUsageTotalFamily extends Family<AsyncValue<int>> {
  /// See also [outfitUsageTotal].
  const OutfitUsageTotalFamily();

  /// See also [outfitUsageTotal].
  OutfitUsageTotalProvider call(String outfitId) {
    return OutfitUsageTotalProvider(outfitId);
  }

  @override
  OutfitUsageTotalProvider getProviderOverride(
    covariant OutfitUsageTotalProvider provider,
  ) {
    return call(provider.outfitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'outfitUsageTotalProvider';
}

/// See also [outfitUsageTotal].
class OutfitUsageTotalProvider extends AutoDisposeStreamProvider<int> {
  /// See also [outfitUsageTotal].
  OutfitUsageTotalProvider(String outfitId)
    : this._internal(
        (ref) => outfitUsageTotal(ref as OutfitUsageTotalRef, outfitId),
        from: outfitUsageTotalProvider,
        name: r'outfitUsageTotalProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$outfitUsageTotalHash,
        dependencies: OutfitUsageTotalFamily._dependencies,
        allTransitiveDependencies:
            OutfitUsageTotalFamily._allTransitiveDependencies,
        outfitId: outfitId,
      );

  OutfitUsageTotalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.outfitId,
  }) : super.internal();

  final String outfitId;

  @override
  Override overrideWith(
    Stream<int> Function(OutfitUsageTotalRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OutfitUsageTotalProvider._internal(
        (ref) => create(ref as OutfitUsageTotalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        outfitId: outfitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _OutfitUsageTotalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OutfitUsageTotalProvider && other.outfitId == outfitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, outfitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OutfitUsageTotalRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `outfitId` of this provider.
  String get outfitId;
}

class _OutfitUsageTotalProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with OutfitUsageTotalRef {
  _OutfitUsageTotalProviderElement(super.provider);

  @override
  String get outfitId => (origin as OutfitUsageTotalProvider).outfitId;
}

String _$outfitLastUsageHash() => r'baf71b6fdbbc5ea6255354a8b83045cb0929ba3a';

/// See also [outfitLastUsage].
@ProviderFor(outfitLastUsage)
const outfitLastUsageProvider = OutfitLastUsageFamily();

/// See also [outfitLastUsage].
class OutfitLastUsageFamily extends Family<AsyncValue<int?>> {
  /// See also [outfitLastUsage].
  const OutfitLastUsageFamily();

  /// See also [outfitLastUsage].
  OutfitLastUsageProvider call(String outfitId) {
    return OutfitLastUsageProvider(outfitId);
  }

  @override
  OutfitLastUsageProvider getProviderOverride(
    covariant OutfitLastUsageProvider provider,
  ) {
    return call(provider.outfitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'outfitLastUsageProvider';
}

/// See also [outfitLastUsage].
class OutfitLastUsageProvider extends AutoDisposeStreamProvider<int?> {
  /// See also [outfitLastUsage].
  OutfitLastUsageProvider(String outfitId)
    : this._internal(
        (ref) => outfitLastUsage(ref as OutfitLastUsageRef, outfitId),
        from: outfitLastUsageProvider,
        name: r'outfitLastUsageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$outfitLastUsageHash,
        dependencies: OutfitLastUsageFamily._dependencies,
        allTransitiveDependencies:
            OutfitLastUsageFamily._allTransitiveDependencies,
        outfitId: outfitId,
      );

  OutfitLastUsageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.outfitId,
  }) : super.internal();

  final String outfitId;

  @override
  Override overrideWith(
    Stream<int?> Function(OutfitLastUsageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OutfitLastUsageProvider._internal(
        (ref) => create(ref as OutfitLastUsageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        outfitId: outfitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int?> createElement() {
    return _OutfitLastUsageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OutfitLastUsageProvider && other.outfitId == outfitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, outfitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OutfitLastUsageRef on AutoDisposeStreamProviderRef<int?> {
  /// The parameter `outfitId` of this provider.
  String get outfitId;
}

class _OutfitLastUsageProviderElement
    extends AutoDisposeStreamProviderElement<int?>
    with OutfitLastUsageRef {
  _OutfitLastUsageProviderElement(super.provider);

  @override
  String get outfitId => (origin as OutfitLastUsageProvider).outfitId;
}

String _$usageControllerHash() => r'2eec9bd220e064cac4bdcceb0f7017b3d97dbb3c';

/// See also [UsageController].
@ProviderFor(UsageController)
final usageControllerProvider =
    AutoDisposeAsyncNotifierProvider<UsageController, void>.internal(
      UsageController.new,
      name: r'usageControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$usageControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UsageController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
