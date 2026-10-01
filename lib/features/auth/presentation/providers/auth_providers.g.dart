// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'73f2cf57238e6fa5dfc299eb58ae9b96f900bd76';

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'c804efe7cc22a6d4845ca6e3e45cb8c9b0824a76';

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
        isAutoDispose: true,
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

String _$centerRepositoryHash() => r'8fb355ef292975f247b34b200e193f8a3c660711';

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
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
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'd24b8b997b98cd8aa79a826dbb910b27b448154c';

/// Rôle du connecté en temps réel : suit la création du doc users,
/// donc pas de null figé pendant les écritures d'inscription.

@ProviderFor(currentUserRole)
final currentUserRoleProvider = CurrentUserRoleProvider._();

/// Rôle du connecté en temps réel : suit la création du doc users,
/// donc pas de null figé pendant les écritures d'inscription.

final class CurrentUserRoleProvider
    extends
        $FunctionalProvider<AsyncValue<UserRole?>, UserRole?, Stream<UserRole?>>
    with $FutureModifier<UserRole?>, $StreamProvider<UserRole?> {
  /// Rôle du connecté en temps réel : suit la création du doc users,
  /// donc pas de null figé pendant les écritures d'inscription.
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
  $StreamProviderElement<UserRole?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserRole?> create(Ref ref) {
    return currentUserRole(ref);
  }
}

String _$currentUserRoleHash() => r'a1ebe213b18170654bf434c09f3b47f19f979dc3';

/// Statut de vérification du centre connecté en temps réel
/// (null si non concerné). Une validation console bascule l'app en direct.

@ProviderFor(centerVerificationStatus)
final centerVerificationStatusProvider = CenterVerificationStatusProvider._();

/// Statut de vérification du centre connecté en temps réel
/// (null si non concerné). Une validation console bascule l'app en direct.

final class CenterVerificationStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<VerificationStatus?>,
          VerificationStatus?,
          Stream<VerificationStatus?>
        >
    with
        $FutureModifier<VerificationStatus?>,
        $StreamProvider<VerificationStatus?> {
  /// Statut de vérification du centre connecté en temps réel
  /// (null si non concerné). Une validation console bascule l'app en direct.
  CenterVerificationStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'centerVerificationStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$centerVerificationStatusHash();

  @$internal
  @override
  $StreamProviderElement<VerificationStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<VerificationStatus?> create(Ref ref) {
    return centerVerificationStatus(ref);
  }
}

String _$centerVerificationStatusHash() =>
    r'b325a07f4d948a7d8cbd0400713582b84bcbec3b';
