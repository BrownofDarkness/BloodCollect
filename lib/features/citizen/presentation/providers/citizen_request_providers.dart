import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/domain/entities/match_requester.dart';
import '../../../../shared/presentation/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'citizen_donate_providers.dart';

part 'citizen_request_providers.g.dart';

// Écran « Demande reçue » : une sollicitation de don, en temps réel.
@riverpod
Stream<DonorMatchRequest?> incomingDonorRequest(Ref ref, String requestId) {
  return ref.watch(donorMatchRepositoryProvider).watchById(requestId);
}

// Auteur d'une sollicitation. Un centre de santé a une fiche publique et
// est nommé ; sinon c'est un particulier, présenté anonymement.
@riverpod
Future<MatchRequester> matchRequester(Ref ref, String requesterId) async {
  // Lus avant tout `await` : ref ne doit plus servir une fois le provider
  // détruit.
  final centers = ref.watch(centerRepositoryProvider);
  final donors = ref.watch(donorRepositoryProvider);

  final center = await centers.watchHealthCenterByUser(requesterId).first;
  if (center != null) {
    return MatchRequester(
      isHealthCenter: true,
      centerName: center.name,
      commune: center.commune,
      phone: center.phone,
    );
  }
  final citizen = await donors.contactOf(requesterId);
  return MatchRequester(
    isHealthCenter: false,
    commune: citizen?.commune,
    phone: citizen?.phone,
  );
}

// Centre de transfusion vérifié le plus proche du citoyen connecté : celui
// de sa commune s'il y en a un, sinon le premier de sa ville. Null si sa
// ville est inconnue ou sans centre.
@riverpod
Future<BloodCenter?> nearestBloodCenter(Ref ref) async {
  final centers = await ref.watch(nearbyBloodCentersProvider.future);
  return centers.isEmpty ? null : centers.first;
}
