// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_donate_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(upcomingCampaigns)
final upcomingCampaignsProvider = UpcomingCampaignsProvider._();

final class UpcomingCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          FutureOr<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $FutureProvider<List<Campaign>> {
  UpcomingCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingCampaignsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingCampaignsHash();

  @$internal
  @override
  $FutureProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Campaign>> create(Ref ref) {
    return upcomingCampaigns(ref);
  }
}

String _$upcomingCampaignsHash() => r'8ed9b8add62c86c455f7d4bcc95c0424d1b4e7fb';

@ProviderFor(myCampaignRegistrations)
final myCampaignRegistrationsProvider = MyCampaignRegistrationsProvider._();

final class MyCampaignRegistrationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CampaignRegistration>>,
          List<CampaignRegistration>,
          Stream<List<CampaignRegistration>>
        >
    with
        $FutureModifier<List<CampaignRegistration>>,
        $StreamProvider<List<CampaignRegistration>> {
  MyCampaignRegistrationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCampaignRegistrationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCampaignRegistrationsHash();

  @$internal
  @override
  $StreamProviderElement<List<CampaignRegistration>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CampaignRegistration>> create(Ref ref) {
    return myCampaignRegistrations(ref);
  }
}

String _$myCampaignRegistrationsHash() =>
    r'eca4f2b6e3cf3e6bc00d83eaa500ed7b8afb48ae';

@ProviderFor(nearbyBloodCenters)
final nearbyBloodCentersProvider = NearbyBloodCentersProvider._();

final class NearbyBloodCentersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodCenter>>,
          List<BloodCenter>,
          FutureOr<List<BloodCenter>>
        >
    with
        $FutureModifier<List<BloodCenter>>,
        $FutureProvider<List<BloodCenter>> {
  NearbyBloodCentersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyBloodCentersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyBloodCentersHash();

  @$internal
  @override
  $FutureProviderElement<List<BloodCenter>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BloodCenter>> create(Ref ref) {
    return nearbyBloodCenters(ref);
  }
}

String _$nearbyBloodCentersHash() =>
    r'22f20355e56b0e0e93c4ac58710d1063334f7351';
