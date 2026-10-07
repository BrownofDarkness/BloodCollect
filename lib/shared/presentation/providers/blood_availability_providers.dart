import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_enums.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/blood_availability.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/blood_stock_lot.dart';
import '../../domain/entities/geo_location.dart';
import 'repository_providers.dart';

part 'blood_availability_providers.g.dart';

// Disponibilité du sang déclarée par les centres de transfusion, commune
// aux espaces qui la consultent (citoyen, centre de santé).

// Position du demandeur pour le calcul des distances : celle de son centre
// de santé s'il en gère un, sinon null (un citoyen n'a pas de position).
@riverpod
Stream<GeoLocation?> requesterLocation(Ref ref) async* {
  final centers = ref.watch(centerRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* centers
      .watchHealthCenterByUser(user.id)
      .map((center) => center?.location);
}

@riverpod
Stream<List<BloodCenter>> verifiedBloodCenters(
  Ref ref, {
  required String city,
  String? commune,
}) {
  return ref
      .watch(centerRepositoryProvider)
      .watchVerifiedBloodCenters(city: city, commune: commune);
}

@riverpod
Stream<List<BloodStockLot>> availableBloodLots(Ref ref, BloodType bloodType) {
  return ref.watch(bloodStockRepositoryProvider).watchAvailableLots(bloodType);
}

@riverpod
Stream<BloodCenter?> bloodCenter(Ref ref, String centerId) {
  return ref.watch(centerRepositoryProvider).watchBloodCenter(centerId);
}

@riverpod
Stream<List<BloodStockLot>> bloodCenterLots(Ref ref, String centerId) {
  return ref
      .watch(bloodStockRepositoryProvider)
      .watchAvailableLotsByCenter(centerId);
}

// Fiche d'un centre : statut déclaré de ses 8 groupes. Liste vide si le
// centre est introuvable.
@riverpod
Future<List<BloodAvailability>> bloodCenterAvailabilities(
  Ref ref,
  String centerId,
) async {
  // Lus avant tout `await` : ref ne doit plus servir une fois le provider
  // détruit.
  final centerFuture = ref.watch(bloodCenterProvider(centerId).future);
  final lotsFuture = ref.watch(bloodCenterLotsProvider(centerId).future);
  // Non bloquant : sans position du demandeur, la distance est masquée.
  final origin = ref.watch(requesterLocationProvider).value;

  final center = await centerFuture;
  if (center == null) return const [];
  return BloodAvailability.allGroups(
    center: center,
    lots: await lotsFuture,
    now: DateTime.now(),
    origin: origin,
  );
}

// Recherche par groupe et zone : croise les centres vérifiés avec leurs lots
// déclarés. Se recalcule à chaque changement de stock.
@riverpod
Future<List<BloodAvailability>> bloodAvailabilities(
  Ref ref, {
  required BloodType bloodType,
  required String city,
  String? commune,
}) async {
  final centersFuture = ref.watch(
    verifiedBloodCentersProvider(city: city, commune: commune).future,
  );
  final lotsFuture = ref.watch(availableBloodLotsProvider(bloodType).future);
  final origin = ref.watch(requesterLocationProvider).value;

  final centers = await centersFuture;
  final lots = await lotsFuture;
  final now = DateTime.now();
  return centers
      .map(
        (center) => BloodAvailability.fromLots(
          center: center,
          bloodType: bloodType,
          lots: lots,
          now: now,
          origin: origin,
        ),
      )
      .toList()
    ..sort(BloodAvailability.compare);
}
