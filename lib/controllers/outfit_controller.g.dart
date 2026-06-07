// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$outfitsSortedHash() => r'536c3c271b130b09d4800cdc5f5d498d6191fbf0';

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

/// See also [outfitsSorted].
@ProviderFor(outfitsSorted)
const outfitsSortedProvider = OutfitsSortedFamily();

/// See also [outfitsSorted].
class OutfitsSortedFamily extends Family<AsyncValue<List<Outfit>>> {
  /// See also [outfitsSorted].
  const OutfitsSortedFamily();

  /// See also [outfitsSorted].
  OutfitsSortedProvider call(OutfitSortMode mode) {
    return OutfitsSortedProvider(mode);
  }

  @override
  OutfitsSortedProvider getProviderOverride(
    covariant OutfitsSortedProvider provider,
  ) {
    return call(provider.mode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'outfitsSortedProvider';
}

/// See also [outfitsSorted].
class OutfitsSortedProvider extends AutoDisposeStreamProvider<List<Outfit>> {
  /// See also [outfitsSorted].
  OutfitsSortedProvider(OutfitSortMode mode)
    : this._internal(
        (ref) => outfitsSorted(ref as OutfitsSortedRef, mode),
        from: outfitsSortedProvider,
        name: r'outfitsSortedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$outfitsSortedHash,
        dependencies: OutfitsSortedFamily._dependencies,
        allTransitiveDependencies:
            OutfitsSortedFamily._allTransitiveDependencies,
        mode: mode,
      );

  OutfitsSortedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
  }) : super.internal();

  final OutfitSortMode mode;

  @override
  Override overrideWith(
    Stream<List<Outfit>> Function(OutfitsSortedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OutfitsSortedProvider._internal(
        (ref) => create(ref as OutfitsSortedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Outfit>> createElement() {
    return _OutfitsSortedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OutfitsSortedProvider && other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OutfitsSortedRef on AutoDisposeStreamProviderRef<List<Outfit>> {
  /// The parameter `mode` of this provider.
  OutfitSortMode get mode;
}

class _OutfitsSortedProviderElement
    extends AutoDisposeStreamProviderElement<List<Outfit>>
    with OutfitsSortedRef {
  _OutfitsSortedProviderElement(super.provider);

  @override
  OutfitSortMode get mode => (origin as OutfitsSortedProvider).mode;
}

String _$totalClothingItemsHash() =>
    r'97411760634f5fcfdea885dc46991edef12799ba';

/// See also [totalClothingItems].
@ProviderFor(totalClothingItems)
final totalClothingItemsProvider = AutoDisposeStreamProvider<int>.internal(
  totalClothingItems,
  name: r'totalClothingItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalClothingItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalClothingItemsRef = AutoDisposeStreamProviderRef<int>;
String _$totalOutfitsHash() => r'720d991fe6c4f56834eb0ccb69a540caa6f15991';

/// See also [totalOutfits].
@ProviderFor(totalOutfits)
final totalOutfitsProvider = AutoDisposeStreamProvider<int>.internal(
  totalOutfits,
  name: r'totalOutfitsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalOutfitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalOutfitsRef = AutoDisposeStreamProviderRef<int>;
String _$outfitControllerHash() => r'0c18f7242951d83feb04d21057d063490b04618d';

/// See also [OutfitController].
@ProviderFor(OutfitController)
final outfitControllerProvider =
    AutoDisposeAsyncNotifierProvider<OutfitController, void>.internal(
      OutfitController.new,
      name: r'outfitControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$outfitControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OutfitController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
