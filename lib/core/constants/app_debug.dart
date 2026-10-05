/// Réglages de développement, pilotés par variables de compilation.
///
/// Ils permettent de travailler sur un écran sans être bloqué par une brique
/// encore en cours d'implémentation — typiquement l'authentification, partagée
/// entre tous les rôles.
///
/// Toutes ces options sont **désactivées par défaut** et ne s'activent qu'avec
/// une variable `--dart-define` passée au lancement :
///
/// ```sh
/// flutter run --dart-define=SKIP_AUTH=true --dart-define=START_ROLE=citizen
/// ```
///
/// Une compilation de livraison ne les définit pas : le comportement normal de
/// l'application est donc inchangé.
abstract final class AppDebug {
  const AppDebug._();

  /// Ouvre directement l'accueil du rôle demandé au lieu de la connexion.
  static const bool skipAuth = bool.fromEnvironment('SKIP_AUTH');

  /// Rôle ouvert lorsque [skipAuth] est actif : `citizen`, `health_center`,
  /// `blood_center`.
  static const String startRole = String.fromEnvironment(
    'START_ROLE',
    defaultValue: 'citizen',
  );
}
