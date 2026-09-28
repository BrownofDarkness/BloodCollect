// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'758ae4e4e34de70fe2d743034d78a541d9de3f05';

@ProviderFor(currentUserRole)
final currentUserRoleProvider = CurrentUserRoleProvider._();

final class CurrentUserRoleProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserRole?>,
          UserRole?,
          FutureOr<UserRole?>
        >
    with $FutureModifier<UserRole?>, $FutureProvider<UserRole?> {
  CurrentUserRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserRoleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserRoleHash();

  @$internal
  @override
  $FutureProviderElement<UserRole?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserRole?> create(Ref ref) {
    return currentUserRole(ref);
  }
}

String _$currentUserRoleHash() => r'0ebac24318acbd103a752035d18bf08dcf3b49ef';
