import '../entities/donor_match_request.dart';

// Contrat d'accès aux mises en relation centre / donneur.
abstract class DonorMatchRepository {
  /// Crée toutes les sollicitations en une seule écriture atomique.
  Future<void> createAll(List<DonorMatchRequest> requests);
}
