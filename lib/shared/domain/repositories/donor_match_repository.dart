import '../../../core/constants/app_enums.dart';
import '../entities/donor_match_request.dart';

// Contrat d'accès aux mises en relation centre / donneur.
abstract class DonorMatchRepository {
  /// Crée toutes les sollicitations en une seule écriture atomique.
  Future<void> createAll(List<DonorMatchRequest> requests);

  /// Sollicitations émises par un compte en temps réel, de la plus récente
  /// à la plus ancienne.
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId);

  /// Sollicitations reçues par un donneur en temps réel, de la plus récente
  /// à la plus ancienne.
  Stream<List<DonorMatchRequest>> watchByDonor(String donorId);

  /// Une sollicitation en temps réel (null si elle n'existe pas).
  Stream<DonorMatchRequest?> watchById(String id);

  /// Réponse du donneur : [status] vaut `accepted` ou `declined`.
  Future<void> respond(String id, DonorMatchStatus status);
}
