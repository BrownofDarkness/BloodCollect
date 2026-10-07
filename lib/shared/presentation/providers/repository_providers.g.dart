// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bloodStockRepository)
final bloodStockRepositoryProvider = BloodStockRepositoryProvider._();

final class BloodStockRepositoryProvider
    extends
        $FunctionalProvider<
          BloodStockRepository,
          BloodStockRepository,
          BloodStockRepository
        >
    with $Provider<BloodStockRepository> {
  BloodStockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bloodStockRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bloodStockRepositoryHash();

  @$internal
  @override
  $ProviderElement<BloodStockRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BloodStockRepository create(Ref ref) {
    return bloodStockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BloodStockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BloodStockRepository>(value),
    );
  }
}

String _$bloodStockRepositoryHash() =>
    r'ddb54fb87e5339ca5e46f2a31ea0ff4e0d115ddc';

@ProviderFor(campaignRepository)
final campaignRepositoryProvider = CampaignRepositoryProvider._();

final class CampaignRepositoryProvider
    extends
        $FunctionalProvider<
          CampaignRepository,
          CampaignRepository,
          CampaignRepository
        >
    with $Provider<CampaignRepository> {
  CampaignRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignRepositoryHash();

  @$internal
  @override
  $ProviderElement<CampaignRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CampaignRepository create(Ref ref) {
    return campaignRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CampaignRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CampaignRepository>(value),
    );
  }
}

String _$campaignRepositoryHash() =>
    r'f3c3f4624b53849a3988f6972fbecbe10e887d07';

@ProviderFor(campaignRegistrationRepository)
final campaignRegistrationRepositoryProvider =
    CampaignRegistrationRepositoryProvider._();

final class CampaignRegistrationRepositoryProvider
    extends
        $FunctionalProvider<
          CampaignRegistrationRepository,
          CampaignRegistrationRepository,
          CampaignRegistrationRepository
        >
    with $Provider<CampaignRegistrationRepository> {
  CampaignRegistrationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campaignRegistrationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campaignRegistrationRepositoryHash();

  @$internal
  @override
  $ProviderElement<CampaignRegistrationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CampaignRegistrationRepository create(Ref ref) {
    return campaignRegistrationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CampaignRegistrationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CampaignRegistrationRepository>(
        value,
      ),
    );
  }
}

String _$campaignRegistrationRepositoryHash() =>
    r'8ebcf674e65245f0548ce6b7710bf4eba5d913a0';

@ProviderFor(donorRepository)
final donorRepositoryProvider = DonorRepositoryProvider._();

final class DonorRepositoryProvider
    extends
        $FunctionalProvider<DonorRepository, DonorRepository, DonorRepository>
    with $Provider<DonorRepository> {
  DonorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorRepositoryHash();

  @$internal
  @override
  $ProviderElement<DonorRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DonorRepository create(Ref ref) {
    return donorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorRepository>(value),
    );
  }
}

String _$donorRepositoryHash() => r'3d8bac1902de858efb676cc5adeaa58d8364c100';

@ProviderFor(donorMatchRepository)
final donorMatchRepositoryProvider = DonorMatchRepositoryProvider._();

final class DonorMatchRepositoryProvider
    extends
        $FunctionalProvider<
          DonorMatchRepository,
          DonorMatchRepository,
          DonorMatchRepository
        >
    with $Provider<DonorMatchRepository> {
  DonorMatchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorMatchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorMatchRepositoryHash();

  @$internal
  @override
  $ProviderElement<DonorMatchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DonorMatchRepository create(Ref ref) {
    return donorMatchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorMatchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorMatchRepository>(value),
    );
  }
}

String _$donorMatchRepositoryHash() =>
    r'1ed3932660e6e75eed890fee554109657276b0f8';
