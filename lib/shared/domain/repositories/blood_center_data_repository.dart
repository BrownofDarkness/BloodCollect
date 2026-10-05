import '../entities/blood_center.dart';
import '../entities/blood_request.dart';
import '../entities/blood_stock_lot.dart';
import '../entities/campaign.dart';
import '../entities/health_center.dart';

// Données temps réel du centre de transfusion (Firestore).
abstract class BloodCenterDataRepository {
  Stream<BloodCenter?> watchBloodCenterForUser(String userId);
  Stream<List<HealthCenter>> watchHealthCenters();

  Stream<List<BloodStockLot>> watchStockLots(String bloodCenterId);

  /// Crée (id vide) ou met à jour un lot. Renvoie l'id.
  Future<String> saveStockLot(BloodStockLot lot);
  Future<void> deleteStockLot(String id);

  Stream<List<BloodRequest>> watchBloodRequests();
  Future<void> updateBloodRequest(BloodRequest request);

  Stream<List<Campaign>> watchCampaigns(String bloodCenterId);

  /// Crée (id vide) ou met à jour une campagne. Renvoie l'id.
  Future<String> saveCampaign(Campaign campaign);

  Future<void> updateCenterThresholds({
    required String centerId,
    required int low,
    required int unavailable,
  });
}
