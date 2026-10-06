import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/presentation/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'citizen_home_providers.g.dart';

// Collectes ouvertes au public, en temps réel.
@riverpod
Stream<List<Campaign>> openCampaigns(Ref ref) {
  return ref.watch(campaignRepositoryProvider).watchOpen();
}

// Accueil « Près de chez vous » : collectes ouvertes qui se tiennent dans la
// commune du citoyen connecté ou la ciblent. Vide si sa commune est inconnue.
@riverpod
Future<List<Campaign>> nearbyCampaigns(Ref ref) async {
  // Les deux lectures précèdent tout `await` : ref ne doit plus servir une
  // fois le provider détruit.
  final userFuture = ref.watch(currentAppUserProvider.future);
  final campaignsFuture = ref.watch(openCampaignsProvider.future);

  final commune = (await userFuture)?.commune;
  if (commune == null || commune.isEmpty) return const [];

  final campaigns = await campaignsFuture;
  return campaigns.where((c) => c.concernsCommune(commune)).toList();
}

// Fiche centre : collectes ouvertes organisées par un centre de transfusion.
@riverpod
Future<List<Campaign>> centerCampaigns(Ref ref, String bloodCenterId) async {
  final campaigns = await ref.watch(openCampaignsProvider.future);
  return campaigns.where((c) => c.bloodCenterId == bloodCenterId).toList();
}

// Sollicitations de don reçues par le citoyen connecté, en temps réel.
@riverpod
Stream<List<DonorMatchRequest>> incomingDonorRequests(Ref ref) async* {
  final repository = ref.watch(donorMatchRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* repository.watchByDonor(user.id);
}
