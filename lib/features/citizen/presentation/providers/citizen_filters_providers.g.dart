// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_filters_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filtres de l'onglet « Sang ».
///
/// Amorçage sur la ville du profil : la première consultation doit porter sur
/// les centres proches du citoyen, pas sur tout le pays.

@ProviderFor(BloodAvailabilityFilterNotifier)
final bloodAvailabilityFilterProvider =
    BloodAvailabilityFilterNotifierProvider._();

/// Filtres de l'onglet « Sang ».
///
/// Amorçage sur la ville du profil : la première consultation doit porter sur
/// les centres proches du citoyen, pas sur tout le pays.
final class BloodAvailabilityFilterNotifierProvider
    extends
        $AsyncNotifierProvider<
          BloodAvailabilityFilterNotifier,
          BloodAvailabilityFilter
        > {
  /// Filtres de l'onglet « Sang ».
  ///
  /// Amorçage sur la ville du profil : la première consultation doit porter sur
  /// les centres proches du citoyen, pas sur tout le pays.
  BloodAvailabilityFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bloodAvailabilityFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bloodAvailabilityFilterNotifierHash();

  @$internal
  @override
  BloodAvailabilityFilterNotifier create() => BloodAvailabilityFilterNotifier();
}

String _$bloodAvailabilityFilterNotifierHash() =>
    r'b6d4373d3df50377b7e8fd1452859ed4a4f0456b';

/// Filtres de l'onglet « Sang ».
///
/// Amorçage sur la ville du profil : la première consultation doit porter sur
/// les centres proches du citoyen, pas sur tout le pays.

abstract class _$BloodAvailabilityFilterNotifier
    extends $AsyncNotifier<BloodAvailabilityFilter> {
  FutureOr<BloodAvailabilityFilter> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BloodAvailabilityFilter>,
              BloodAvailabilityFilter
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BloodAvailabilityFilter>,
                BloodAvailabilityFilter
              >,
              AsyncValue<BloodAvailabilityFilter>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
