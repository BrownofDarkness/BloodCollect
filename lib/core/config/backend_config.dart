// Bascule backend réel / simulé. simulate = true : tous les appels Firebase Auth / Firestore / Storage
// sont remplacés par des Future.delayed pour tester le flow complet
// sans connexion. Passer à false quand Firebase est branché.
abstract final class BackendConfig {
  static const bool simulate = false;
  static const Duration simulatedDelay = Duration(seconds: 2);

  /// Storage/Functions exigent Blaze (carte enregistrée). À false,
  /// l'upload du justificatif est sauté et le document devient optionnel.
  /// Passer à true après activation Blaze + publication de storage.rules.
  static const bool storageEnabled = false;
}
