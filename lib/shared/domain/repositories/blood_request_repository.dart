import '../entities/blood_request.dart';

// Contrat d'accès aux demandes de sang (collection centrale du Blood Route).
abstract class BloodRequestRepository {
  /// Crée la demande et renvoie son identifiant.
  Future<String> create(BloodRequest request);

  /// Demandes d'un centre de santé en temps réel, de la plus récente
  /// à la plus ancienne.
  Stream<List<BloodRequest>> watchByHealthCenter(String healthCenterId);
}
