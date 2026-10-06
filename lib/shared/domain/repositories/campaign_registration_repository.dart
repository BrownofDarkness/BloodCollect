import '../entities/campaign_registration.dart';

// Contrat d'accès aux inscriptions des donneurs aux collectes de sang.
abstract class CampaignRegistrationRepository {
  /// Inscriptions d'un donneur, tous statuts confondus, en temps réel.
  Stream<List<CampaignRegistration>> watchByDonor(String donorId);

  /// Inscriptions aux collectes d'un centre de transfusion, tous statuts
  /// confondus, en temps réel.
  Stream<List<CampaignRegistration>> watchByBloodCenter(String bloodCenterId);

  /// Inscrit le donneur à la collecte, ou réactive son inscription annulée.
  /// [bloodCenterId] est le centre organisateur de la collecte.
  Future<void> register({
    required String campaignId,
    required String bloodCenterId,
    required String donorId,
  });

  /// Annule une inscription (le document est conservé).
  Future<void> cancel(String registrationId);
}
