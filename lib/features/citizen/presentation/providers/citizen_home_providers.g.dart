// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(openCampaigns)
final openCampaignsProvider = OpenCampaignsProvider._();

final class OpenCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          Stream<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $StreamProvider<List<Campaign>> {
  OpenCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openCampaignsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openCampaignsHash();

  @$internal
  @override
  $StreamProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Campaign>> create(Ref ref) {
    return openCampaigns(ref);
  }
}

String _$openCampaignsHash() => r'dc60cc55842f3b56317401a542768716c3dd48c1';

@ProviderFor(nearbyCampaigns)
final nearbyCampaignsProvider = NearbyCampaignsProvider._();

final class NearbyCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          FutureOr<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $FutureProvider<List<Campaign>> {
  NearbyCampaignsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyCampaignsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyCampaignsHash();

  @$internal
  @override
  $FutureProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Campaign>> create(Ref ref) {
    return nearbyCampaigns(ref);
  }
}

String _$nearbyCampaignsHash() => r'529f2d6f1a71dda74ea81d7fe4e57e05fdbaa6c4';

@ProviderFor(centerCampaigns)
final centerCampaignsProvider = CenterCampaignsFamily._();

final class CenterCampaignsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Campaign>>,
          List<Campaign>,
          FutureOr<List<Campaign>>
        >
    with $FutureModifier<List<Campaign>>, $FutureProvider<List<Campaign>> {
  CenterCampaignsProvider._({
    required CenterCampaignsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'centerCampaignsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$centerCampaignsHash();

  @override
  String toString() {
    return r'centerCampaignsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Campaign>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Campaign>> create(Ref ref) {
    final argument = this.argument as String;
    return centerCampaigns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CenterCampaignsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$centerCampaignsHash() => r'2a3414993b7f5e5d777b8d4ddebf5bc667c5cf6f';

final class CenterCampaignsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Campaign>>, String> {
  CenterCampaignsFamily._()
    : super(
        retry: null,
        name: r'centerCampaignsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CenterCampaignsProvider call(String bloodCenterId) =>
      CenterCampaignsProvider._(argument: bloodCenterId, from: this);

  @override
  String toString() => r'centerCampaignsProvider';
}

@ProviderFor(incomingDonorRequests)
final incomingDonorRequestsProvider = IncomingDonorRequestsProvider._();

final class IncomingDonorRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DonorMatchRequest>>,
          List<DonorMatchRequest>,
          Stream<List<DonorMatchRequest>>
        >
    with
        $FutureModifier<List<DonorMatchRequest>>,
        $StreamProvider<List<DonorMatchRequest>> {
  IncomingDonorRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingDonorRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingDonorRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<DonorMatchRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DonorMatchRequest>> create(Ref ref) {
    return incomingDonorRequests(ref);
  }
}

String _$incomingDonorRequestsHash() =>
    r'e33cf8aecfe1d92a36560c84fb3c46ccd4ddc177';
