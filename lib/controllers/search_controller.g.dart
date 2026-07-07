// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentSearchesHash() => r'6d4d6a83cf9a384c9eff973f0b3019e9582a71be';

/// Últimas buscas (no máximo 3), persistidas localmente.
///
/// Copied from [RecentSearches].
@ProviderFor(RecentSearches)
final recentSearchesProvider =
    NotifierProvider<RecentSearches, List<String>>.internal(
      RecentSearches.new,
      name: r'recentSearchesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentSearchesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecentSearches = Notifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
