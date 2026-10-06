import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/presentation/providers/donor_search_providers.dart';
import 'citizen_donate_providers.dart';
import 'citizen_home_providers.dart';

part 'citizen_profile_providers.g.dart';

// Profil « Mes collectes » : inscriptions actives à des collectes encore
// ouvertes.
@riverpod
Future<int> upcomingParticipationCount(Ref ref) async {
  // Les deux lectures précèdent tout `await` : ref ne doit plus servir une
  // fois le provider détruit.
  final registrationsFuture = ref.watch(myCampaignRegistrationsProvider.future);
  final campaignsFuture = ref.watch(openCampaignsProvider.future);

  final openIds = {for (final c in await campaignsFuture) c.id};
  return (await registrationsFuture)
      .where((r) => r.isActive && openIds.contains(r.campaignId))
      .length;
}

// Profil « Mes mises en relation » : demandes encore en attente de réponse,
// qu'elles soient reçues (à traiter) ou envoyées (à suivre).
@riverpod
Future<int> pendingMatchCount(Ref ref) async {
  final receivedFuture = ref.watch(incomingDonorRequestsProvider.future);
  final sentFuture = ref.watch(sentDonorMatchesProvider.future);

  final now = DateTime.now();
  final all = [...await receivedFuture, ...await sentFuture];
  return all.where((m) => m.statusAt(now) == DonorMatchStatus.pending).length;
}
