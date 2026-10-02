// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hc_providers.dart';

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
    r'9983449168031379cea35c9d8120ecb5b903a8f9';

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
    r'440d431808db352a9b11e6aceb122dce4edf848e';

@ProviderFor(verifiedBloodCenters)
final verifiedBloodCentersProvider = VerifiedBloodCentersFamily._();

final class VerifiedBloodCentersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodCenter>>,
          List<BloodCenter>,
          Stream<List<BloodCenter>>
        >
    with
        $FutureModifier<List<BloodCenter>>,
        $StreamProvider<List<BloodCenter>> {
  VerifiedBloodCentersProvider._({
    required VerifiedBloodCentersFamily super.from,
    required ({String city, String? commune}) super.argument,
  }) : super(
         retry: null,
         name: r'verifiedBloodCentersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$verifiedBloodCentersHash();

  @override
  String toString() {
    return r'verifiedBloodCentersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<BloodCenter>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BloodCenter>> create(Ref ref) {
    final argument = this.argument as ({String city, String? commune});
    return verifiedBloodCenters(
      ref,
      city: argument.city,
      commune: argument.commune,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VerifiedBloodCentersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$verifiedBloodCentersHash() =>
    r'af77c33e6f7f41d24a3d7b3e68463246b757a1cf';

final class VerifiedBloodCentersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<BloodCenter>>,
          ({String city, String? commune})
        > {
  VerifiedBloodCentersFamily._()
    : super(
        retry: null,
        name: r'verifiedBloodCentersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VerifiedBloodCentersProvider call({required String city, String? commune}) =>
      VerifiedBloodCentersProvider._(
        argument: (city: city, commune: commune),
        from: this,
      );

  @override
  String toString() => r'verifiedBloodCentersProvider';
}

@ProviderFor(availableBloodLots)
final availableBloodLotsProvider = AvailableBloodLotsFamily._();

final class AvailableBloodLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodStockLot>>,
          List<BloodStockLot>,
          Stream<List<BloodStockLot>>
        >
    with
        $FutureModifier<List<BloodStockLot>>,
        $StreamProvider<List<BloodStockLot>> {
  AvailableBloodLotsProvider._({
    required AvailableBloodLotsFamily super.from,
    required BloodType super.argument,
  }) : super(
         retry: null,
         name: r'availableBloodLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$availableBloodLotsHash();

  @override
  String toString() {
    return r'availableBloodLotsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BloodStockLot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BloodStockLot>> create(Ref ref) {
    final argument = this.argument as BloodType;
    return availableBloodLots(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableBloodLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$availableBloodLotsHash() =>
    r'0181fae8e67be7f17c9efa709103735c8cd8796a';

final class AvailableBloodLotsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BloodStockLot>>, BloodType> {
  AvailableBloodLotsFamily._()
    : super(
        retry: null,
        name: r'availableBloodLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AvailableBloodLotsProvider call(BloodType bloodType) =>
      AvailableBloodLotsProvider._(argument: bloodType, from: this);

  @override
  String toString() => r'availableBloodLotsProvider';
}

@ProviderFor(bloodCenter)
final bloodCenterProvider = BloodCenterFamily._();

final class BloodCenterProvider
    extends
        $FunctionalProvider<
          AsyncValue<BloodCenter?>,
          BloodCenter?,
          Stream<BloodCenter?>
        >
    with $FutureModifier<BloodCenter?>, $StreamProvider<BloodCenter?> {
  BloodCenterProvider._({
    required BloodCenterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bloodCenterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bloodCenterHash();

  @override
  String toString() {
    return r'bloodCenterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BloodCenter?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BloodCenter?> create(Ref ref) {
    final argument = this.argument as String;
    return bloodCenter(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BloodCenterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bloodCenterHash() => r'11ee3227c186eeeefd7c5c5f6f5b6802c2d2cf4c';

final class BloodCenterFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BloodCenter?>, String> {
  BloodCenterFamily._()
    : super(
        retry: null,
        name: r'bloodCenterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BloodCenterProvider call(String centerId) =>
      BloodCenterProvider._(argument: centerId, from: this);

  @override
  String toString() => r'bloodCenterProvider';
}

@ProviderFor(bloodCenterLots)
final bloodCenterLotsProvider = BloodCenterLotsFamily._();

final class BloodCenterLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodStockLot>>,
          List<BloodStockLot>,
          Stream<List<BloodStockLot>>
        >
    with
        $FutureModifier<List<BloodStockLot>>,
        $StreamProvider<List<BloodStockLot>> {
  BloodCenterLotsProvider._({
    required BloodCenterLotsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bloodCenterLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bloodCenterLotsHash();

  @override
  String toString() {
    return r'bloodCenterLotsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BloodStockLot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BloodStockLot>> create(Ref ref) {
    final argument = this.argument as String;
    return bloodCenterLots(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BloodCenterLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bloodCenterLotsHash() => r'ff79c340987de34f7056d7cee977fbdc87a981d2';

final class BloodCenterLotsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BloodStockLot>>, String> {
  BloodCenterLotsFamily._()
    : super(
        retry: null,
        name: r'bloodCenterLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BloodCenterLotsProvider call(String centerId) =>
      BloodCenterLotsProvider._(argument: centerId, from: this);

  @override
  String toString() => r'bloodCenterLotsProvider';
}

@ProviderFor(bloodCenterAvailabilities)
final bloodCenterAvailabilitiesProvider = BloodCenterAvailabilitiesFamily._();

final class BloodCenterAvailabilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodAvailability>>,
          List<BloodAvailability>,
          FutureOr<List<BloodAvailability>>
        >
    with
        $FutureModifier<List<BloodAvailability>>,
        $FutureProvider<List<BloodAvailability>> {
  BloodCenterAvailabilitiesProvider._({
    required BloodCenterAvailabilitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bloodCenterAvailabilitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bloodCenterAvailabilitiesHash();

  @override
  String toString() {
    return r'bloodCenterAvailabilitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BloodAvailability>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BloodAvailability>> create(Ref ref) {
    final argument = this.argument as String;
    return bloodCenterAvailabilities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BloodCenterAvailabilitiesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bloodCenterAvailabilitiesHash() =>
    r'64c9081fe281c10b50c5681eaa74397b7e194097';

final class BloodCenterAvailabilitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BloodAvailability>>, String> {
  BloodCenterAvailabilitiesFamily._()
    : super(
        retry: null,
        name: r'bloodCenterAvailabilitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BloodCenterAvailabilitiesProvider call(String centerId) =>
      BloodCenterAvailabilitiesProvider._(argument: centerId, from: this);

  @override
  String toString() => r'bloodCenterAvailabilitiesProvider';
}

@ProviderFor(bloodAvailabilities)
final bloodAvailabilitiesProvider = BloodAvailabilitiesFamily._();

final class BloodAvailabilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodAvailability>>,
          List<BloodAvailability>,
          FutureOr<List<BloodAvailability>>
        >
    with
        $FutureModifier<List<BloodAvailability>>,
        $FutureProvider<List<BloodAvailability>> {
  BloodAvailabilitiesProvider._({
    required BloodAvailabilitiesFamily super.from,
    required ({BloodType bloodType, String city, String? commune})
    super.argument,
  }) : super(
         retry: null,
         name: r'bloodAvailabilitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bloodAvailabilitiesHash();

  @override
  String toString() {
    return r'bloodAvailabilitiesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<BloodAvailability>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BloodAvailability>> create(Ref ref) {
    final argument =
        this.argument as ({BloodType bloodType, String city, String? commune});
    return bloodAvailabilities(
      ref,
      bloodType: argument.bloodType,
      city: argument.city,
      commune: argument.commune,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BloodAvailabilitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bloodAvailabilitiesHash() =>
    r'82cd141654fc2fa58a1cc13083e80cd0b304feb2';

final class BloodAvailabilitiesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BloodAvailability>>,
          ({BloodType bloodType, String city, String? commune})
        > {
  BloodAvailabilitiesFamily._()
    : super(
        retry: null,
        name: r'bloodAvailabilitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BloodAvailabilitiesProvider call({
    required BloodType bloodType,
    required String city,
    String? commune,
  }) => BloodAvailabilitiesProvider._(
    argument: (bloodType: bloodType, city: city, commune: commune),
    from: this,
  );

  @override
  String toString() => r'bloodAvailabilitiesProvider';
}
