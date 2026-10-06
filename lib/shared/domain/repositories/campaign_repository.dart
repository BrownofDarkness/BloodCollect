import '../entities/campaign.dart';

// Contrat de lecture des collectes de sang côté public (citoyens).
// La gestion par le centre organisateur passe par BloodCenterDataRepository.
abstract class CampaignRepository {
  /// Collectes publiées ou en cours et non terminées, en temps réel,
  /// de la plus proche dans le temps à la plus lointaine.
  Stream<List<Campaign>> watchOpen();
}
