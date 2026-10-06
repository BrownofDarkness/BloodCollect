import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/donor_candidate.dart';
import '../../domain/entities/donor_contact.dart';
import '../../domain/entities/donor_match_request.dart';
import '../../domain/entities/donor_search_criteria.dart';
import 'repository_providers.dart';

part 'donor_search_providers.g.dart';

// Recherche de donneurs et suivi des mises en relation, communs aux
// demandeurs (citoyen, centre de santé).

// Écrans « Donneurs potentiels » : résultat d'une recherche (non temps
// réel). Le demandeur lui-même n'y figure jamais.
@riverpod
Future<List<DonorCandidate>> donorCandidates(
  Ref ref,
  DonorSearchCriteria criteria,
) async {
  // Lu avant tout `await` : ref ne doit plus servir une fois le provider
  // détruit (changement d'écran pendant la recherche).
  final repository = ref.watch(donorRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  final candidates = await repository.search(criteria);
  return candidates.where((c) => c.donorId != user?.id).toList();
}

// Coordonnées d'un donneur ayant accepté une mise en relation.
@riverpod
Future<DonorContact?> donorContact(Ref ref, String donorId) {
  return ref.watch(donorRepositoryProvider).contactOf(donorId);
}

// Sollicitations envoyées aux donneurs par le compte connecté, avec leurs
// réponses, en temps réel.
@riverpod
Stream<List<DonorMatchRequest>> sentDonorMatches(Ref ref) async* {
  final repository = ref.watch(donorMatchRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* repository.watchByRequester(user.id);
}
