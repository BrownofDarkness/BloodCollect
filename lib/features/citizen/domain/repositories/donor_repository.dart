import '../../../../../shared/domain/entities/entities.dart';

/// Accès au profil du citoyen connecté et à son activité de donneur.
///
/// Le citoyen est le seul acteur dont le compte est actif sans validation
/// admin : aucune vérification ne conditionne l'accès à ces données.
abstract interface class DonorRepository {
  Future<AppUser> currentCitizen();

  /// Position de référence du citoyen pour le calcul des distances.
  ///
  /// En production : la position GPS consentie. En attendant, le centroïde de
  /// la commune déclarée au profil. Le domaine ne fait qu'exploiter la valeur
  /// renvoyée, il ne décide pas de sa source.
  Future<GeoLocation> donorOrigin();

  /// Inscriptions du donneur, toutes campagnes confondues.
  Future<List<CampaignRegistration>> registrationsOf(String donorId);

  /// Mises en relation où le citoyen est donneur cible ou demandeur.
  Future<List<DonorMatchRequest>> matchesOf(String citizenId);

  /// Inscrit le donneur à une campagne. Idempotent : réinscrire à une campagne
  /// déjà rejoint retourne l'inscription existante.
  Future<CampaignRegistration> registerToCampaign({
    required String campaignId,
    required String donorId,
    DateTime? scheduledTime,
  });

  /// Annule une inscription. Sans effet si elle est déjà annulée.
  Future<void> cancelRegistration(String registrationId);
}
