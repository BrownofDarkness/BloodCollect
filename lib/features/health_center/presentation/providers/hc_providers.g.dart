// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hc_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bloodRequestRepository)
final bloodRequestRepositoryProvider = BloodRequestRepositoryProvider._();

final class BloodRequestRepositoryProvider
    extends
        $FunctionalProvider<
          BloodRequestRepository,
          BloodRequestRepository,
          BloodRequestRepository
        >
    with $Provider<BloodRequestRepository> {
  BloodRequestRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bloodRequestRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bloodRequestRepositoryHash();

  @$internal
  @override
  $ProviderElement<BloodRequestRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BloodRequestRepository create(Ref ref) {
    return bloodRequestRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BloodRequestRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BloodRequestRepository>(value),
    );
  }
}

String _$bloodRequestRepositoryHash() =>
    r'c790e44a06fd04ea1f1333007097a8805f8213a1';

@ProviderFor(currentHealthCenter)
final currentHealthCenterProvider = CurrentHealthCenterProvider._();

final class CurrentHealthCenterProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthCenter?>,
          HealthCenter?,
          Stream<HealthCenter?>
        >
    with $FutureModifier<HealthCenter?>, $StreamProvider<HealthCenter?> {
  CurrentHealthCenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentHealthCenterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentHealthCenterHash();

  @$internal
  @override
  $StreamProviderElement<HealthCenter?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<HealthCenter?> create(Ref ref) {
    return currentHealthCenter(ref);
  }
}

String _$currentHealthCenterHash() =>
    r'9fbc82f46ae9d8110f1a6e677542dea8f12b8554';

@ProviderFor(healthCenterRequests)
final healthCenterRequestsProvider = HealthCenterRequestsProvider._();

final class HealthCenterRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodRequest>>,
          List<BloodRequest>,
          Stream<List<BloodRequest>>
        >
    with
        $FutureModifier<List<BloodRequest>>,
        $StreamProvider<List<BloodRequest>> {
  HealthCenterRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthCenterRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthCenterRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<BloodRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BloodRequest>> create(Ref ref) {
    return healthCenterRequests(ref);
  }
}

String _$healthCenterRequestsHash() =>
    r'4aae58329af2b66e80b73a8db3fecd3023462ce8';
