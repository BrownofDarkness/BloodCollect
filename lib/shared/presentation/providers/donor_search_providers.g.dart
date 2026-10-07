// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(donorCandidates)
final donorCandidatesProvider = DonorCandidatesFamily._();

final class DonorCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DonorCandidate>>,
          List<DonorCandidate>,
          FutureOr<List<DonorCandidate>>
        >
    with
        $FutureModifier<List<DonorCandidate>>,
        $FutureProvider<List<DonorCandidate>> {
  DonorCandidatesProvider._({
    required DonorCandidatesFamily super.from,
    required DonorSearchCriteria super.argument,
  }) : super(
         retry: null,
         name: r'donorCandidatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$donorCandidatesHash();

  @override
  String toString() {
    return r'donorCandidatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DonorCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DonorCandidate>> create(Ref ref) {
    final argument = this.argument as DonorSearchCriteria;
    return donorCandidates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DonorCandidatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$donorCandidatesHash() => r'f2aa70e1569989715588a8f31a209060f36b3674';

final class DonorCandidatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DonorCandidate>>,
          DonorSearchCriteria
        > {
  DonorCandidatesFamily._()
    : super(
        retry: null,
        name: r'donorCandidatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DonorCandidatesProvider call(DonorSearchCriteria criteria) =>
      DonorCandidatesProvider._(argument: criteria, from: this);

  @override
  String toString() => r'donorCandidatesProvider';
}

@ProviderFor(donorContact)
final donorContactProvider = DonorContactFamily._();

final class DonorContactProvider
    extends
        $FunctionalProvider<
          AsyncValue<DonorContact?>,
          DonorContact?,
          FutureOr<DonorContact?>
        >
    with $FutureModifier<DonorContact?>, $FutureProvider<DonorContact?> {
  DonorContactProvider._({
    required DonorContactFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'donorContactProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$donorContactHash();

  @override
  String toString() {
    return r'donorContactProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DonorContact?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DonorContact?> create(Ref ref) {
    final argument = this.argument as String;
    return donorContact(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DonorContactProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$donorContactHash() => r'9bd9fa3ef9ca85246228c9b79b621f0eaa9ebfe1';

final class DonorContactFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DonorContact?>, String> {
  DonorContactFamily._()
    : super(
        retry: null,
        name: r'donorContactProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DonorContactProvider call(String donorId) =>
      DonorContactProvider._(argument: donorId, from: this);

  @override
  String toString() => r'donorContactProvider';
}

@ProviderFor(sentDonorMatches)
final sentDonorMatchesProvider = SentDonorMatchesProvider._();

final class SentDonorMatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DonorMatchRequest>>,
          List<DonorMatchRequest>,
          Stream<List<DonorMatchRequest>>
        >
    with
        $FutureModifier<List<DonorMatchRequest>>,
        $StreamProvider<List<DonorMatchRequest>> {
  SentDonorMatchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentDonorMatchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentDonorMatchesHash();

  @$internal
  @override
  $StreamProviderElement<List<DonorMatchRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DonorMatchRequest>> create(Ref ref) {
    return sentDonorMatches(ref);
  }
}

String _$sentDonorMatchesHash() => r'a68e7a565601dbc1176d775b74a4e48888b6e89c';
