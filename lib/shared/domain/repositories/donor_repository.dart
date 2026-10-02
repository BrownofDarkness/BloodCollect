import '../entities/donor_candidate.dart';
import '../entities/donor_search_criteria.dart';

// Contrat de recherche de donneurs. La collection users n'étant pas
// listable côté app, la sélection et l'anonymisation se font côté serveur.
abstract class DonorRepository {
  /// Donneurs disponibles correspondant aux critères, du plus proche
  /// au plus éloigné.
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria);
}
