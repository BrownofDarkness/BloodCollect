import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remote = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthUser?> authStateChanges() => _remote.authStateChanges();

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _remote.signInWithEmail(email: email, password: password);

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _remote.signUpWithEmail(email: email, password: password);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remote.sendPasswordResetEmail(email);

  @override
  Future<void> signOut() => _remote.signOut();
}
