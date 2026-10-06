import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/data/repositories/blood_request_repository_impl.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../../shared/domain/entities/health_center.dart';
import '../../../../shared/domain/repositories/blood_request_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Providers partagés avec l'espace Citoyen (disponibilité du sang, recherche
// de donneurs, mises en relation), réexportés pour les écrans du centre.
export '../../../../shared/presentation/providers/blood_availability_providers.dart';
export '../../../../shared/presentation/providers/donor_search_providers.dart';
export '../../../../shared/presentation/providers/repository_providers.dart'
    show
        bloodStockRepositoryProvider,
        donorMatchRepositoryProvider,
        donorRepositoryProvider;

part 'hc_providers.g.dart';

@riverpod
BloodRequestRepository bloodRequestRepository(Ref ref) =>
    BloodRequestRepositoryImpl();

// Fiche du centre de santé connecté en temps réel (null si absente).
@riverpod
Stream<HealthCenter?> currentHealthCenter(Ref ref) async* {
  // Lu avant tout `await` : ref ne doit plus servir une fois le provider
  // détruit.
  final repository = ref.watch(centerRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* repository.watchHealthCenterByUser(user.id);
}

// Écran « Mes demandes de sang » : demandes du centre connecté, en temps
// réel. Liste vide tant que la fiche du centre est absente.
@riverpod
Stream<List<BloodRequest>> healthCenterRequests(Ref ref) async* {
  final repository = ref.watch(bloodRequestRepositoryProvider);
  final healthCenter = await ref.watch(currentHealthCenterProvider.future);
  if (healthCenter == null) {
    yield const [];
    return;
  }
  yield* repository.watchByHealthCenter(healthCenter.id);
}

