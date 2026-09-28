import '../../../../../shared/domain/entities/entities.dart';

/// Accès aux campagnes de collecte publiées.
abstract interface class CampaignRepository {
  /// Campagnes à venir, de la plus proche de commencer à la plus lointaine.
  Future<List<Campaign>> upcomingCampaigns({String? commune});

  /// Campagnes à venir organisées par un centre donné.
  Future<List<Campaign>> upcomingCampaignsOfCenter(String centerId);

  /// Récupère une collecte par identifiant, quel que soit son statut.
  Future<Campaign?> campaignById(String campaignId);
}
