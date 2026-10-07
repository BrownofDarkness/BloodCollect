import '../entities/donor_candidate.dart';
import '../entities/donor_contact.dart';
import '../entities/donor_search_criteria.dart';

// Contrat de recherche de donneurs. L'implémentation ne doit renvoyer que
// des profils anonymisés, quelle que soit la source des données.
abstract class DonorRepository {
  /// Donneurs potentiels correspondant aux critères.
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria);

  /// Coordonnées d'un citoyen (null si le profil est introuvable).
  /// Nom et téléphone ne doivent être montrés qu'après acceptation de la
  /// mise en relation : les règles Firestore ne peuvent pas vérifier cette
  /// condition, c'est à l'appelant de la respecter.
  Future<DonorContact?> contactOf(String donorId);
}
