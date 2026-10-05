import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/data/repositories/blood_center_data_repository_impl.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../../shared/domain/entities/blood_stock_lot.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/repositories/blood_center_data_repository.dart';

// Providers temps réel (Firestore). Remplacent les mocks de l'étape 1.
// Chaque stream charge indépendamment : shimmer par écran à la première
// visite, erreur + réessayer si réseau/permissions, refresh via invalidate.
final bloodCenterDataRepositoryProvider =
    Provider<BloodCenterDataRepository>(
  (ref) => BloodCenterDataRepositoryImpl(),
);

/// Centre du connecté (null si aucun doc). Nom, seuils, horaires.
final myBloodCenterProvider = StreamProvider<BloodCenter?>((ref) async* {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* ref
      .watch(bloodCenterDataRepositoryProvider)
      .watchBloodCenterForUser(user.id);
});

/// Lots du centre, tous statuts (le tri/filtrage est côté écrans).
final bcStockLotsProvider =
    StreamProvider<List<BloodStockLot>>((ref) async* {
  final center = await ref.watch(myBloodCenterProvider.future);
  if (center == null) {
    yield const [];
    return;
  }
  yield* ref
      .watch(bloodCenterDataRepositoryProvider)
      .watchStockLots(center.id);
});

/// Toutes les demandes (triées côté client : vitales d'abord).
final bcBloodRequestsProvider =
    StreamProvider<List<BloodRequest>>((ref) {
  return ref.watch(bloodCenterDataRepositoryProvider).watchBloodRequests();
});

/// Campagnes du centre.
final bcCampaignsProvider = StreamProvider<List<Campaign>>((ref) async* {
  final center = await ref.watch(myBloodCenterProvider.future);
  if (center == null) {
    yield const [];
    return;
  }
  yield* ref
      .watch(bloodCenterDataRepositoryProvider)
      .watchCampaigns(center.id);
});

/// id -> nom des centres de santé (jointure d'affichage).
final bcHealthCenterNamesProvider =
    StreamProvider<Map<String, String>>((ref) {
  return ref
      .watch(bloodCenterDataRepositoryProvider)
      .watchHealthCenters()
      .map((list) => {for (final c in list) c.id: c.name});
});

/// id -> téléphone des centres de santé (contact affiché, users privés).
final bcHealthCenterPhonesProvider =
    StreamProvider<Map<String, String>>((ref) {
  return ref
      .watch(bloodCenterDataRepositoryProvider)
      .watchHealthCenters()
      .map((list) => {for (final c in list) c.id: c.phone});
});

/// Seuils depuis le doc centre (défauts 20/5 si indisponible).
final bcLowThresholdProvider = Provider<int>(
  (ref) =>
      ref.watch(myBloodCenterProvider).asData?.value?.lowStockThreshold ??
      20,
);

/// Seuil critique depuis le doc centre (défaut 5 si indisponible).
final bcUnavailableThresholdProvider = Provider<int>(
  (ref) => ref
          .watch(myBloodCenterProvider)
          .asData
          ?.value
          ?.unavailableThreshold ??
      5,
);

/// Pull-to-refresh : ré-émet les streams.
Future<void> refreshBcData(WidgetRef ref) async {
  ref.invalidate(myBloodCenterProvider);
  ref.invalidate(bcStockLotsProvider);
  ref.invalidate(bcBloodRequestsProvider);
  ref.invalidate(bcCampaignsProvider);
  ref.invalidate(bcHealthCenterNamesProvider);
  ref.invalidate(bcHealthCenterPhonesProvider);
  // Laisse le shimmer visible un instant (retour visuel).
  await Future.delayed(const Duration(seconds: 1));
}
