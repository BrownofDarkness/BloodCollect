// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(upcomingParticipationCount)
final upcomingParticipationCountProvider =
    UpcomingParticipationCountProvider._();

final class UpcomingParticipationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  UpcomingParticipationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingParticipationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingParticipationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return upcomingParticipationCount(ref);
  }
}

String _$upcomingParticipationCountHash() =>
    r'd7d96945d9fe6f3dde082a845cadf9a13f284fa1';

@ProviderFor(pendingMatchCount)
final pendingMatchCountProvider = PendingMatchCountProvider._();

final class PendingMatchCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  PendingMatchCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingMatchCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingMatchCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingMatchCount(ref);
  }
}

String _$pendingMatchCountHash() => r'6e91ecf807325e2b5da749b248d481695564cabb';
