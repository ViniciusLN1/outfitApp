// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'92a246abcb363d93aa5a028712241f464abc4efe';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$clothingItemsHash() => r'5a53a47a2e91c783331be103c1b4f4d045150d07';

/// See also [clothingItems].
@ProviderFor(clothingItems)
final clothingItemsProvider =
    AutoDisposeStreamProvider<List<ClothingItem>>.internal(
      clothingItems,
      name: r'clothingItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clothingItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClothingItemsRef = AutoDisposeStreamProviderRef<List<ClothingItem>>;
String _$clothingByCategoryHash() =>
    r'e52bda737a80f9c2a0875649862ce5797ed7500d';

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

/// See also [clothingByCategory].
@ProviderFor(clothingByCategory)
const clothingByCategoryProvider = ClothingByCategoryFamily();

/// See also [clothingByCategory].
class ClothingByCategoryFamily extends Family<AsyncValue<List<ClothingItem>>> {
  /// See also [clothingByCategory].
  const ClothingByCategoryFamily();

  /// See also [clothingByCategory].
  ClothingByCategoryProvider call(String category) {
    return ClothingByCategoryProvider(category);
  }

  @override
  ClothingByCategoryProvider getProviderOverride(
    covariant ClothingByCategoryProvider provider,
  ) {
    return call(provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'clothingByCategoryProvider';
}

/// See also [clothingByCategory].
class ClothingByCategoryProvider
    extends AutoDisposeStreamProvider<List<ClothingItem>> {
  /// See also [clothingByCategory].
  ClothingByCategoryProvider(String category)
    : this._internal(
        (ref) => clothingByCategory(ref as ClothingByCategoryRef, category),
        from: clothingByCategoryProvider,
        name: r'clothingByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$clothingByCategoryHash,
        dependencies: ClothingByCategoryFamily._dependencies,
        allTransitiveDependencies:
            ClothingByCategoryFamily._allTransitiveDependencies,
        category: category,
      );

  ClothingByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    Stream<List<ClothingItem>> Function(ClothingByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClothingByCategoryProvider._internal(
        (ref) => create(ref as ClothingByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ClothingItem>> createElement() {
    return _ClothingByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClothingByCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClothingByCategoryRef
    on AutoDisposeStreamProviderRef<List<ClothingItem>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _ClothingByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<ClothingItem>>
    with ClothingByCategoryRef {
  _ClothingByCategoryProviderElement(super.provider);

  @override
  String get category => (origin as ClothingByCategoryProvider).category;
}

String _$clothingControllerHash() =>
    r'c6b68228c66c5ee97e24d0d2176814cecec7aa58';

/// See also [ClothingController].
@ProviderFor(ClothingController)
final clothingControllerProvider =
    AutoDisposeAsyncNotifierProvider<ClothingController, void>.internal(
      ClothingController.new,
      name: r'clothingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clothingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ClothingController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
