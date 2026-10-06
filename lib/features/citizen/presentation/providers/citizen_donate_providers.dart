import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/campaign_registration.dart';
import '../../../../shared/presentation/providers/blood_availability_providers.dart';
import '../../../../shared/presentation/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'citizen_home_providers.dart';

part 'citizen_donate_providers.g.dart';

// Écran « Je veux donner mon sang » : collectes ouvertes, celles qui
// concernent la commune du citoyen en tête, puis par date.
@riverpod
Future<List<Campaign>> upcomingCampaigns(Ref ref) async {
  // Les deux lectures précèdent tout `await` : ref ne doit plus servir une
  // fois le provider détruit.
  final userFuture = ref.watch(currentAppUserProvider.future);
  final campaignsFuture = ref.watch(openCampaignsProvider.future);

  final commune = (await userFuture)?.commune ?? '';
  final campaigns = await campaignsFuture;
  int rank(Campaign c) => c.concernsCommune(commune) ? 0 : 1;
  return [...campaigns]..sort((a, b) {
      final byProximity = rank(a).compareTo(rank(b));
      return byProximity != 0
          ? byProximity
          : a.startDate.compareTo(b.startDate);
    });
}

// Inscriptions aux collectes du citoyen connecté, en temps réel.
@riverpod
Stream<List<CampaignRegistration>> myCampaignRegistrations(Ref ref) async* {
  final repository = ref.watch(campaignRegistrationRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* repository.watchByDonor(user.id);
}

// Centres de transfusion vérifiés de la ville du citoyen connecté, ceux de
// sa commune en tête. Vide si sa ville est inconnue.
@riverpod
Future<List<BloodCenter>> nearbyBloodCenters(Ref ref) async {
  final user = await ref.watch(currentAppUserProvider.future);
  final city = user?.city;
  if (city == null || city.isEmpty) return const [];

  final centers = await ref.watch(
    verifiedBloodCentersProvider(city: city).future,
  );
  int rank(BloodCenter c) => c.commune == user?.commune ? 0 : 1;
  return [...centers]..sort((a, b) {
      final byProximity = rank(a).compareTo(rank(b));
      return byProximity != 0 ? byProximity : a.name.compareTo(b.name);
    });
}
