import 'donor_candidate.dart';
import 'donor_search_criteria.dart';

// Donneurs retenus sur un écran de résultats, transmis à l'écran de mise en
// relation avec les critères de la recherche. Non persisté.
class DonorContactSelection {
  const DonorContactSelection({
    required this.criteria,
    required this.candidates,
  });

  final DonorSearchCriteria criteria;
  final List<DonorCandidate> candidates;
}
