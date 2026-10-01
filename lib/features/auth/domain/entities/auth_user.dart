// Utilisateur authentifié minimal (domaine pur, sans Firebase).
class AuthUser {
  const AuthUser({required this.id, this.email});

  final String id;
  final String? email;
}
