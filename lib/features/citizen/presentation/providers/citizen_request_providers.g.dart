// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(incomingDonorRequest)
final incomingDonorRequestProvider = IncomingDonorRequestFamily._();

final class IncomingDonorRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<DonorMatchRequest?>,
          DonorMatchRequest?,
          Stream<DonorMatchRequest?>
        >
    with
        $FutureModifier<DonorMatchRequest?>,
        $StreamProvider<DonorMatchRequest?> {
  IncomingDonorRequestProvider._({
    required IncomingDonorRequestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'incomingDonorRequestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$incomingDonorRequestHash();

  @override
  String toString() {
    return r'incomingDonorRequestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DonorMatchRequest?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DonorMatchRequest?> create(Ref ref) {
    final argument = this.argument as String;
    return incomingDonorRequest(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IncomingDonorRequestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incomingDonorRequestHash() =>
    r'b34c3ee2fa40e0ead53e24454ac66ebc16bdc38d';

final class IncomingDonorRequestFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DonorMatchRequest?>, String> {
  IncomingDonorRequestFamily._()
    : super(
        retry: null,
        name: r'incomingDonorRequestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IncomingDonorRequestProvider call(String requestId) =>
      IncomingDonorRequestProvider._(argument: requestId, from: this);

  @override
  String toString() => r'incomingDonorRequestProvider';
}

@ProviderFor(matchRequester)
final matchRequesterProvider = MatchRequesterFamily._();

final class MatchRequesterProvider
    extends
        $FunctionalProvider<
          AsyncValue<MatchRequester>,
          MatchRequester,
          FutureOr<MatchRequester>
        >
    with $FutureModifier<MatchRequester>, $FutureProvider<MatchRequester> {
  MatchRequesterProvider._({
    required MatchRequesterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'matchRequesterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchRequesterHash();

  @override
  String toString() {
    return r'matchRequesterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MatchRequester> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MatchRequester> create(Ref ref) {
    final argument = this.argument as String;
    return matchRequester(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchRequesterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchRequesterHash() => r'ccb10c7b380a13c9019471fd201df89d75fbe644';

final class MatchRequesterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MatchRequester>, String> {
  MatchRequesterFamily._()
    : super(
        retry: null,
        name: r'matchRequesterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchRequesterProvider call(String requesterId) =>
      MatchRequesterProvider._(argument: requesterId, from: this);

  @override
  String toString() => r'matchRequesterProvider';
}

@ProviderFor(nearestBloodCenter)
final nearestBloodCenterProvider = NearestBloodCenterProvider._();

final class NearestBloodCenterProvider
    extends
        $FunctionalProvider<
          AsyncValue<BloodCenter?>,
          BloodCenter?,
          FutureOr<BloodCenter?>
        >
    with $FutureModifier<BloodCenter?>, $FutureProvider<BloodCenter?> {
  NearestBloodCenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearestBloodCenterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearestBloodCenterHash();

  @$internal
  @override
  $FutureProviderElement<BloodCenter?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BloodCenter?> create(Ref ref) {
    return nearestBloodCenter(ref);
  }
}

String _$nearestBloodCenterHash() =>
    r'0679f2b11c440243f8f6dfbf100aec45e14594f2';
