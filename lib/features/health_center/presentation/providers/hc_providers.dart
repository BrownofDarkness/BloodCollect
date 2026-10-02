import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/data/repositories/blood_request_repository_impl.dart';
import '../../../../shared/data/repositories/blood_stock_repository_impl.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../../shared/domain/entities/blood_stock_lot.dart';
import '../../../../shared/domain/entities/health_center.dart';
import '../../../../shared/domain/repositories/blood_request_repository.dart';
import '../../../../shared/domain/repositories/blood_stock_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'hc_providers.g.dart';

@riverpod
BloodStockRepository bloodStockRepository(Ref ref) =>
    BloodStockRepositoryImpl();

@riverpod
BloodRequestRepository bloodRequestRepository(Ref ref) =>
    BloodRequestRepositoryImpl();

// Fiche du centre de santé connecté en temps réel (null si absente).
@riverpod
Stream<HealthCenter?> currentHealthCenter(Ref ref) async* {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* ref.watch(centerRepositoryProvider).watchHealthCenterByUser(user.id);
}

// Écran « Mes demandes de sang » : demandes du centre connecté, en temps
// réel. Liste vide tant que la fiche du centre est absente.
@riverpod
Stream<List<BloodRequest>> healthCenterRequests(Ref ref) async* {
  final healthCenter = await ref.watch(currentHealthCenterProvider.future);
  if (healthCenter == null) {
    yield const [];
    return;
  }
  yield* ref
      .watch(bloodRequestRepositoryProvider)
      .watchByHealthCenter(healthCenter.id);
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

// Écran « Fiche centre » : statut déclaré des 8 groupes d'un centre.
// Liste vide si le centre est introuvable.
@riverpod
Future<List<BloodAvailability>> bloodCenterAvailabilities(
  Ref ref,
  String centerId,
) async {
  final center = await ref.watch(bloodCenterProvider(centerId).future);
  if (center == null) return const [];
  final lots = await ref.watch(bloodCenterLotsProvider(centerId).future);
  final origin = ref.watch(currentHealthCenterProvider).value?.location;

  return BloodAvailability.allGroups(
    center: center,
    lots: lots,
    now: DateTime.now(),
    origin: origin,
  );
}

// Écran « Trouver du sang disponible » : croise les centres vérifiés de la
// zone avec leurs lots déclarés. Se recalcule à chaque changement de stock.
@riverpod
Future<List<BloodAvailability>> bloodAvailabilities(
  Ref ref, {
  required BloodType bloodType,
  required String city,
  String? commune,
}) async {
  final centers = await ref.watch(
    verifiedBloodCentersProvider(city: city, commune: commune).future,
  );
  final lots = await ref.watch(availableBloodLotsProvider(bloodType).future);
  // Non bloquant : sans position du demandeur, la distance est masquée.
  final origin = ref.watch(currentHealthCenterProvider).value?.location;
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
