import '../entities/app_user.dart';

// Contrat d'accès aux profils users.
abstract class UserRepository {
  Future<AppUser?> getById(String id);
  Stream<AppUser?> watchById(String id);
  Future<void> save(AppUser user);
}
