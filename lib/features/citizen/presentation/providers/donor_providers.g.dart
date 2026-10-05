// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositories du parcours donneurs.

@ProviderFor(citizenReadRemoteDataSource)
final citizenReadRemoteDataSourceProvider =
    CitizenReadRemoteDataSourceProvider._();

/// Repositories du parcours donneurs.

final class CitizenReadRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CitizenReadRemoteDataSource,
          CitizenReadRemoteDataSource,
          CitizenReadRemoteDataSource
        >
    with $Provider<CitizenReadRemoteDataSource> {
  /// Repositories du parcours donneurs.
  CitizenReadRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenReadRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenReadRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CitizenReadRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CitizenReadRemoteDataSource create(Ref ref) {
    return citizenReadRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CitizenReadRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CitizenReadRemoteDataSource>(value),
    );
  }
}

String _$citizenReadRemoteDataSourceHash() =>
    r'de4cd8f9acf1628d819ba612849b75db6afd7e5d';

@ProviderFor(donorSearchRemoteDataSource)
final donorSearchRemoteDataSourceProvider =
    DonorSearchRemoteDataSourceProvider._();

final class DonorSearchRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          DonorSearchRemoteDataSource,
          DonorSearchRemoteDataSource,
          DonorSearchRemoteDataSource
        >
    with $Provider<DonorSearchRemoteDataSource> {
  DonorSearchRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorSearchRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorSearchRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<DonorSearchRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DonorSearchRemoteDataSource create(Ref ref) {
    return donorSearchRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorSearchRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorSearchRemoteDataSource>(value),
    );
  }
}

String _$donorSearchRemoteDataSourceHash() =>
    r'b4be5545d36ae73c8cadd2c6e2ec4aa635845de6';

@ProviderFor(donorSearchRepository)
final donorSearchRepositoryProvider = DonorSearchRepositoryProvider._();

final class DonorSearchRepositoryProvider
    extends
        $FunctionalProvider<DonorRepository, DonorRepository, DonorRepository>
    with $Provider<DonorRepository> {
  DonorSearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorSearchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorSearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<DonorRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DonorRepository create(Ref ref) {
    return donorSearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorRepository>(value),
    );
  }
}

String _$donorSearchRepositoryHash() =>
    r'324804ac6d4988beb18f3db36a54e612f4cdba0f';

@ProviderFor(centerRepository)
final centerRepositoryProvider = CenterRepositoryProvider._();

final class CenterRepositoryProvider
    extends
        $FunctionalProvider<
          CenterRepository,
          CenterRepository,
          CenterRepository
        >
    with $Provider<CenterRepository> {
  CenterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'centerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$centerRepositoryHash();

  @$internal
  @override
  $ProviderElement<CenterRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CenterRepository create(Ref ref) {
    return centerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CenterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CenterRepository>(value),
    );
  }
}

String _$centerRepositoryHash() => r'f4b72ed77c7a13fce701ee83582ab0925a417f7b';

@ProviderFor(upcomingCampaignRepository)
final upcomingCampaignRepositoryProvider =
    UpcomingCampaignRepositoryProvider._();

final class UpcomingCampaignRepositoryProvider
    extends
        $FunctionalProvider<
          CampaignRepository,
          CampaignRepository,
          CampaignRepository
        >
    with $Provider<CampaignRepository> {
  UpcomingCampaignRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingCampaignRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingCampaignRepositoryHash();

  @$internal
  @override
  $ProviderElement<CampaignRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CampaignRepository create(Ref ref) {
    return upcomingCampaignRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CampaignRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CampaignRepository>(value),
    );
  }
}

String _$upcomingCampaignRepositoryHash() =>
    r'3eac8018c1bf03a6ea4af808eb84ccd9571c4f26';

@ProviderFor(citizenAccountRepository)
final citizenAccountRepositoryProvider = CitizenAccountRepositoryProvider._();

final class CitizenAccountRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  CitizenAccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenAccountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenAccountRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return citizenAccountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$citizenAccountRepositoryHash() =>
    r'772d75099aa754126febb03a74ce73a129678bc4';

@ProviderFor(citizenAccount)
final citizenAccountProvider = CitizenAccountProvider._();

final class CitizenAccountProvider
    extends $FunctionalProvider<AsyncValue<AppUser>, AppUser, FutureOr<AppUser>>
    with $FutureModifier<AppUser>, $FutureProvider<AppUser> {
  CitizenAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenAccountHash();

  @$internal
  @override
  $FutureProviderElement<AppUser> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppUser> create(Ref ref) {
    return citizenAccount(ref);
  }
}

String _$citizenAccountHash() => r'ae786cb6398d4d6bd9b87a1368a161136375e467';

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

String _$upcomingCampaignsHash() => r'12482c46e5270fa25a71c0afde22df2353bbfefb';

@ProviderFor(DonorSearchFiltersNotifier)
final donorSearchFiltersProvider = DonorSearchFiltersNotifierProvider._();

final class DonorSearchFiltersNotifierProvider
    extends $NotifierProvider<DonorSearchFiltersNotifier, DonorSearchFilters> {
  DonorSearchFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorSearchFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorSearchFiltersNotifierHash();

  @$internal
  @override
  DonorSearchFiltersNotifier create() => DonorSearchFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorSearchFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorSearchFilters>(value),
    );
  }
}

String _$donorSearchFiltersNotifierHash() =>
    r'7c0ef7bd91feae4c06d1bdd0b147497feb816e56';

abstract class _$DonorSearchFiltersNotifier
    extends $Notifier<DonorSearchFilters> {
  DonorSearchFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DonorSearchFilters, DonorSearchFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DonorSearchFilters, DonorSearchFilters>,
              DonorSearchFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Écrans Donneurs potentiels.

@ProviderFor(donorSearchResults)
final donorSearchResultsProvider = DonorSearchResultsFamily._();

/// Écrans Donneurs potentiels.

final class DonorSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DonorSearchCandidate>>,
          List<DonorSearchCandidate>,
          FutureOr<List<DonorSearchCandidate>>
        >
    with
        $FutureModifier<List<DonorSearchCandidate>>,
        $FutureProvider<List<DonorSearchCandidate>> {
  /// Écrans Donneurs potentiels.
  DonorSearchResultsProvider._({
    required DonorSearchResultsFamily super.from,
    required DonorSearchFilters super.argument,
  }) : super(
         retry: null,
         name: r'donorSearchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$donorSearchResultsHash();

  @override
  String toString() {
    return r'donorSearchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DonorSearchCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DonorSearchCandidate>> create(Ref ref) {
    final argument = this.argument as DonorSearchFilters;
    return donorSearchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DonorSearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$donorSearchResultsHash() =>
    r'9e014d717c37397776ca6e810a5ffc2efe0a83ff';

/// Écrans Donneurs potentiels.

final class DonorSearchResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DonorSearchCandidate>>,
          DonorSearchFilters
        > {
  DonorSearchResultsFamily._()
    : super(
        retry: null,
        name: r'donorSearchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Écrans Donneurs potentiels.

  DonorSearchResultsProvider call(DonorSearchFilters filters) =>
      DonorSearchResultsProvider._(argument: filters, from: this);

  @override
  String toString() => r'donorSearchResultsProvider';
}

/// Donneurs déjà contactés dans cette session : permet de basculer la carte en
/// « En attente » sans relancer la recherche.

@ProviderFor(ContactedDonorIds)
final contactedDonorIdsProvider = ContactedDonorIdsProvider._();

/// Donneurs déjà contactés dans cette session : permet de basculer la carte en
/// « En attente » sans relancer la recherche.
final class ContactedDonorIdsProvider
    extends $NotifierProvider<ContactedDonorIds, Set<String>> {
  /// Donneurs déjà contactés dans cette session : permet de basculer la carte en
  /// « En attente » sans relancer la recherche.
  ContactedDonorIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactedDonorIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactedDonorIdsHash();

  @$internal
  @override
  ContactedDonorIds create() => ContactedDonorIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$contactedDonorIdsHash() => r'9f834121e579e306b569d333ad2b2f5ec281a7b2';

/// Donneurs déjà contactés dans cette session : permet de basculer la carte en
/// « En attente » sans relancer la recherche.

abstract class _$ContactedDonorIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MatchRequestForm)
final matchRequestFormProvider = MatchRequestFormFamily._();

final class MatchRequestFormProvider
    extends $NotifierProvider<MatchRequestForm, MatchRequestFormState> {
  MatchRequestFormProvider._({
    required MatchRequestFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'matchRequestFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchRequestFormHash();

  @override
  String toString() {
    return r'matchRequestFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MatchRequestForm create() => MatchRequestForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchRequestFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchRequestFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MatchRequestFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchRequestFormHash() => r'bff1f6956f478250a67b85c69968c9290cb9fc6b';

final class MatchRequestFormFamily extends $Family
    with
        $ClassFamilyOverride<
          MatchRequestForm,
          MatchRequestFormState,
          MatchRequestFormState,
          MatchRequestFormState,
          String
        > {
  MatchRequestFormFamily._()
    : super(
        retry: null,
        name: r'matchRequestFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchRequestFormProvider call(String donorId) =>
      MatchRequestFormProvider._(argument: donorId, from: this);

  @override
  String toString() => r'matchRequestFormProvider';
}

abstract class _$MatchRequestForm extends $Notifier<MatchRequestFormState> {
  late final _$args = ref.$arg as String;
  String get donorId => _$args;

  MatchRequestFormState build(String donorId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MatchRequestFormState, MatchRequestFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MatchRequestFormState, MatchRequestFormState>,
              MatchRequestFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Demandes de mobilisation reçues, la plus récente d'abord.

@ProviderFor(incomingMatchRequests)
final incomingMatchRequestsProvider = IncomingMatchRequestsProvider._();

/// Demandes de mobilisation reçues, la plus récente d'abord.

final class IncomingMatchRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DonorMatchRequest>>,
          List<DonorMatchRequest>,
          FutureOr<List<DonorMatchRequest>>
        >
    with
        $FutureModifier<List<DonorMatchRequest>>,
        $FutureProvider<List<DonorMatchRequest>> {
  /// Demandes de mobilisation reçues, la plus récente d'abord.
  IncomingMatchRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingMatchRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingMatchRequestsHash();

  @$internal
  @override
  $FutureProviderElement<List<DonorMatchRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DonorMatchRequest>> create(Ref ref) {
    return incomingMatchRequests(ref);
  }
}

String _$incomingMatchRequestsHash() =>
    r'5882d991f4471991a02a83257e0e8ad7c1dd83b5';

/// Demande reçue qui attend encore une réponse : c'est celle que l'accueil
/// propose d'ouvrir en priorité. Une liste sans demande en attente ne doit pas
/// afficher de pastille.

@ProviderFor(pendingIncomingRequest)
final pendingIncomingRequestProvider = PendingIncomingRequestProvider._();

/// Demande reçue qui attend encore une réponse : c'est celle que l'accueil
/// propose d'ouvrir en priorité. Une liste sans demande en attente ne doit pas
/// afficher de pastille.

final class PendingIncomingRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<DonorMatchRequest?>,
          DonorMatchRequest?,
          FutureOr<DonorMatchRequest?>
        >
    with
        $FutureModifier<DonorMatchRequest?>,
        $FutureProvider<DonorMatchRequest?> {
  /// Demande reçue qui attend encore une réponse : c'est celle que l'accueil
  /// propose d'ouvrir en priorité. Une liste sans demande en attente ne doit pas
  /// afficher de pastille.
  PendingIncomingRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingIncomingRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingIncomingRequestHash();

  @$internal
  @override
  $FutureProviderElement<DonorMatchRequest?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DonorMatchRequest?> create(Ref ref) {
    return pendingIncomingRequest(ref);
  }
}

String _$pendingIncomingRequestHash() =>
    r'75c96f29170702fcd9a85a70dace8d2a3e0cde67';

@ProviderFor(incomingMatchRequest)
final incomingMatchRequestProvider = IncomingMatchRequestFamily._();

final class IncomingMatchRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<DonorMatchRequest>,
          DonorMatchRequest,
          FutureOr<DonorMatchRequest>
        >
    with
        $FutureModifier<DonorMatchRequest>,
        $FutureProvider<DonorMatchRequest> {
  IncomingMatchRequestProvider._({
    required IncomingMatchRequestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'incomingMatchRequestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$incomingMatchRequestHash();

  @override
  String toString() {
    return r'incomingMatchRequestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DonorMatchRequest> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DonorMatchRequest> create(Ref ref) {
    final argument = this.argument as String;
    return incomingMatchRequest(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IncomingMatchRequestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incomingMatchRequestHash() =>
    r'07446c0f9e509c957c65188c9eff6a642b57d973';

final class IncomingMatchRequestFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DonorMatchRequest>, String> {
  IncomingMatchRequestFamily._()
    : super(
        retry: null,
        name: r'incomingMatchRequestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IncomingMatchRequestProvider call(String requestId) =>
      IncomingMatchRequestProvider._(argument: requestId, from: this);

  @override
  String toString() => r'incomingMatchRequestProvider';
}

/// Résout l'auteur d'une demande pour l'afficher au donneur. Un donneur ne voit
/// ni le nom du patient ni de donnée médicale : seulement qui demande, et dans
/// quelle commune.

@ProviderFor(requesterInfo)
final requesterInfoProvider = RequesterInfoFamily._();

/// Résout l'auteur d'une demande pour l'afficher au donneur. Un donneur ne voit
/// ni le nom du patient ni de donnée médicale : seulement qui demande, et dans
/// quelle commune.

final class RequesterInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<RequesterInfo>,
          RequesterInfo,
          FutureOr<RequesterInfo>
        >
    with $FutureModifier<RequesterInfo>, $FutureProvider<RequesterInfo> {
  /// Résout l'auteur d'une demande pour l'afficher au donneur. Un donneur ne voit
  /// ni le nom du patient ni de donnée médicale : seulement qui demande, et dans
  /// quelle commune.
  RequesterInfoProvider._({
    required RequesterInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'requesterInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$requesterInfoHash();

  @override
  String toString() {
    return r'requesterInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RequesterInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RequesterInfo> create(Ref ref) {
    final argument = this.argument as String;
    return requesterInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RequesterInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$requesterInfoHash() => r'7560a0976f3edc78cd2c791e06a0eed5afbd8005';

/// Résout l'auteur d'une demande pour l'afficher au donneur. Un donneur ne voit
/// ni le nom du patient ni de donnée médicale : seulement qui demande, et dans
/// quelle commune.

final class RequesterInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RequesterInfo>, String> {
  RequesterInfoFamily._()
    : super(
        retry: null,
        name: r'requesterInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Résout l'auteur d'une demande pour l'afficher au donneur. Un donneur ne voit
  /// ni le nom du patient ni de donnée médicale : seulement qui demande, et dans
  /// quelle commune.

  RequesterInfoProvider call(String requesterId) =>
      RequesterInfoProvider._(argument: requesterId, from: this);

  @override
  String toString() => r'requesterInfoProvider';
}

/// Centre agréé le plus proche, proposé au donneur qui accepte.

@ProviderFor(nearestCenter)
final nearestCenterProvider = NearestCenterFamily._();

/// Centre agréé le plus proche, proposé au donneur qui accepte.

final class NearestCenterProvider
    extends
        $FunctionalProvider<
          AsyncValue<BloodCenter?>,
          BloodCenter?,
          FutureOr<BloodCenter?>
        >
    with $FutureModifier<BloodCenter?>, $FutureProvider<BloodCenter?> {
  /// Centre agréé le plus proche, proposé au donneur qui accepte.
  NearestCenterProvider._({
    required NearestCenterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'nearestCenterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearestCenterHash();

  @override
  String toString() {
    return r'nearestCenterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BloodCenter?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BloodCenter?> create(Ref ref) {
    final argument = this.argument as String;
    return nearestCenter(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NearestCenterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearestCenterHash() => r'31a1b3831a67a455ab2441587eb30f9914d05533';

/// Centre agréé le plus proche, proposé au donneur qui accepte.

final class NearestCenterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BloodCenter?>, String> {
  NearestCenterFamily._()
    : super(
        retry: null,
        name: r'nearestCenterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Centre agréé le plus proche, proposé au donneur qui accepte.

  NearestCenterProvider call(String commune) =>
      NearestCenterProvider._(argument: commune, from: this);

  @override
  String toString() => r'nearestCenterProvider';
}
