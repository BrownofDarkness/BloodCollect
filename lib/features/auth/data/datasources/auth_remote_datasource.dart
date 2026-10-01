import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/errors/auth_exceptions.dart';
import '../../domain/entities/auth_user.dart';

// Wrapper fin sur FirebaseAuth (injectable pour les tests).
// Mappe les erreurs Firebase vers des exceptions métier typées.
class AuthRemoteDataSource {
  AuthRemoteDataSource({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseConfig.auth;

  final FirebaseAuth _auth;

  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAuthUser);

  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _toAuthUser(cred.user);
      if (user == null) throw const UnknownAuthException();
      return user;
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _toAuthUser(cred.user);
      if (user == null) throw const UnknownAuthException();
      return user;
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<void> signOut() => _auth.signOut();

  AuthUser? _toAuthUser(User? user) =>
      user == null ? null : AuthUser(id: user.uid, email: user.email);

  static AuthException mapAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-credential' ||
      'wrong-password' =>
        const InvalidCredentialsException(),
      'user-not-found' => const UserNotFoundException(),
      'invalid-email' => const InvalidEmailException(),
      'email-already-in-use' => const EmailInUseException(),
      'weak-password' => const WeakPasswordException(),
      'user-disabled' => const UserDisabledException(),
      'too-many-requests' => const TooManyRequestsException(),
      'user-token-expired' => const SessionExpiredException(),
      'operation-not-allowed' => const OperationNotAllowedException(),
      'network-request-failed' => const NetworkAuthException(),
      _ => const UnknownAuthException(),
    };
  }
}
