import 'auth_exceptions.dart';

// Messages pour les exceptions métier auth.
String authErrorMessage(AuthException e) => switch (e) {
      InvalidCredentialsException() ||
      UserNotFoundException() => "Email ou mot de passe incorrect.",
      InvalidEmailException() => "Adresse email invalide.",
      EmailInUseException() => "Un compte existe déjà avec cet email.",
      WeakPasswordException() => "Mot de passe trop faible.",
      UserDisabledException() => "Ce compte a été désactivé.",
      TooManyRequestsException() => "Trop de tentatives. Réessayez dans quelques minutes.",
      NetworkAuthException() => "Pas de connexion internet. Vérifiez votre réseau.",
      SessionExpiredException() => "Session expirée. Reconnectez-vous.",
      OperationNotAllowedException() => "Connexion par email désactivée. Contactez le support.",
      UnknownAuthException() => "Une erreur est survenue. Réessayez.",
    };
