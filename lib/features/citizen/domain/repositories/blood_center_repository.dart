import '../../../../../shared/domain/entities/entities.dart';

/// Accès aux centres de transfusion agréés et à leur stock déclaré.
///
/// Contrat du domaine : aucune implémentation Firestore ici. L'implémentation
/// de test vit dans `data/repositories/`, une implémentation réelle pourra être
/// branchée sans toucher aux use cases.
abstract interface class BloodCenterRepository {
  /// Centres vérifiés uniquement : un centre non validé n'expose pas de stock.
  Future<List<BloodCenter>> verifiedCenters();

  Future<BloodCenter?> centerById(String centerId);

  /// Tous les lots déclarés par le centre, expiration comprise.
  /// Le calcul de la disponibilité publique est du ressort du domaine
  /// ([BloodAvailability.fromLots]), pas de la source de données.
  Future<List<BloodStockLot>> lotsOfCenter(String centerId);
}
