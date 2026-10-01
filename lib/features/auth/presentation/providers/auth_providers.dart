import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/data/repositories/center_repository_impl.dart';
import '../../../../shared/data/repositories/user_repository_impl.dart';
import '../../../../shared/domain/repositories/center_repository.dart';
import '../../../../shared/domain/repositories/user_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl();

@riverpod
UserRepository userRepository(Ref ref) => UserRepositoryImpl();

@riverpod
CenterRepository centerRepository(Ref ref) => CenterRepositoryImpl();

@riverpod
Stream<AuthUser?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

// Rôle du connecté en temps réel : suit la création du doc users, donc pas de null figé pendant les écritures d'inscription.
@riverpod
Stream<UserRole?> currentUserRole(Ref ref) async* {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* ref
      .watch(userRepositoryProvider)
      .watchById(user.id)
      .map((profile) => profile?.role);
}

// Statut de vérification du centre connecté en temps réel (null si non concerné). Une validation console ou admin (dans une v2) bascule l'app en direct.
@riverpod
Stream<VerificationStatus?> centerVerificationStatus(Ref ref) async* {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  final role = await ref.watch(currentUserRoleProvider.future);
  if (role == null ||
      (role != UserRole.healthCenter && role != UserRole.bloodCenter)) {
    yield null;
    return;
  }
  yield* ref.watch(centerRepositoryProvider).watchVerificationStatus(
        userId: user.id,
        role: role,
      );
}
