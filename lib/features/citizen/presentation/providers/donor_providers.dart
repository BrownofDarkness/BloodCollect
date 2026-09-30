import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/data/repositories/fake_citizen_repositories.dart';
import '../../../../shared/data/repositories/fake_donor_repository.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/domain/repositories/citizen_repositories.dart';
import '../../../../shared/domain/repositories/donor_repository.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import '../../../../shared/presentation/models/requester_info.dart';

// --- Repositories ---
// En Partie 2, remplacer uniquement ces 4 providers par les implémentations
// Firestore : aucun écran n'a besoin d'être modifié.
final donorRepositoryProvider = Provider<DonorRepository>(
  (ref) => FakeDonorRepository(),
);
final centerRepositoryProvider = Provider<CenterRepository>(
  (ref) => FakeCenterRepository(),
);
final campaignRepositoryProvider = Provider<CampaignRepository>(
  (ref) => FakeCampaignRepository(),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FakeProfileRepository(),
);

// --- Écran Accueil ---
final citizenProfileProvider = FutureProvider<AppUser>((ref) {
  return ref.watch(profileRepositoryProvider).getCurrentProfile();
});

final upcomingCampaignsProvider = FutureProvider<List<Campaign>>((ref) {
  return ref.watch(campaignRepositoryProvider).upcoming();
});

// --- Écran Chercher un donneur (état des filtres) ---
class DonorSearchFilters {
  const DonorSearchFilters({
    this.bloodType,
    this.city = 'Abidjan',
    this.communes = const {},
    this.priority = Priority.normal,
  });

  final BloodType? bloodType;
  final String city;
  final Set<String> communes;
  final Priority priority;

  bool get isValid => bloodType != null && communes.isNotEmpty;

  DonorSearchFilters copyWith({
    BloodType? bloodType,
    String? city,
    Set<String>? communes,
    Priority? priority,
  }) {
    return DonorSearchFilters(
      bloodType: bloodType ?? this.bloodType,
      city: city ?? this.city,
      communes: communes ?? this.communes,
      priority: priority ?? this.priority,
    );
  }
}

class DonorSearchFiltersNotifier extends StateNotifier<DonorSearchFilters> {
  DonorSearchFiltersNotifier() : super(const DonorSearchFilters());

  void setBloodType(BloodType type) => state = state.copyWith(bloodType: type);
  void setPriority(Priority p) => state = state.copyWith(priority: p);
  void toggleCommune(String commune) {
    final updated = {...state.communes};
    updated.contains(commune) ? updated.remove(commune) : updated.add(commune);
    state = state.copyWith(communes: updated);
  }

  void selectAllCommunes(List<String> all) =>
      state = state.copyWith(communes: all.toSet());
}

final donorSearchFiltersProvider =
    StateNotifierProvider.autoDispose<
      DonorSearchFiltersNotifier,
      DonorSearchFilters
    >((ref) => DonorSearchFiltersNotifier());

// --- Écran Donneurs potentiels ---
final donorSearchResultsProvider = FutureProvider.autoDispose
    .family<List<DonorSearchCandidate>, DonorSearchFilters>((ref, filters) {
      return ref
          .watch(donorRepositoryProvider)
          .searchDonors(
            bloodType: filters.bloodType!,
            communes: filters.communes.toList(),
            priority: filters.priority,
          );
    });

/// Statut local des cartes déjà contactées dans cette session (évite un
/// refetch juste pour basculer "Contacter" -> "En attente").
final contactedDonorIdsProvider = StateProvider.autoDispose<Set<String>>(
  (ref) => {},
);

// --- Écran Demande de mise en relation ---
class MatchRequestFormState {
  const MatchRequestFormState({
    this.priority = Priority.normal,
    this.message = '',
    this.shareContact = true,
    this.isSubmitting = false,
  });

  final Priority priority;
  final String message;
  final bool shareContact;
  final bool isSubmitting;

  MatchRequestFormState copyWith({
    Priority? priority,
    String? message,
    bool? shareContact,
    bool? isSubmitting,
  }) {
    return MatchRequestFormState(
      priority: priority ?? this.priority,
      message: message ?? this.message,
      shareContact: shareContact ?? this.shareContact,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class MatchRequestFormNotifier extends StateNotifier<MatchRequestFormState> {
  MatchRequestFormNotifier(this._repository)
    : super(const MatchRequestFormState());
  final DonorRepository _repository;

  void setPriority(Priority p) => state = state.copyWith(priority: p);
  void setMessage(String m) => state = state.copyWith(message: m);
  void setShareContact(bool v) => state = state.copyWith(shareContact: v);

  Future<DonorMatchRequest> submit(String donorId) async {
    state = state.copyWith(isSubmitting: true);
    try {
      return await _repository.sendMatchRequest(
        donorId: donorId,
        priority: state.priority,
        message: state.message.isEmpty ? null : state.message,
        shareContact: state.shareContact,
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final matchRequestFormProvider = StateNotifierProvider.autoDispose
    .family<MatchRequestFormNotifier, MatchRequestFormState, String>((
      ref,
      donorId,
    ) {
      return MatchRequestFormNotifier(ref.watch(donorRepositoryProvider));
    });

// --- Écran Demande reçue ---
final incomingMatchRequestProvider = FutureProvider.autoDispose
    .family<DonorMatchRequest, String>((ref, requestId) {
      return ref.watch(donorRepositoryProvider).getIncomingRequest(requestId);
    });

final requesterInfoProvider = FutureProvider.autoDispose
    .family<RequesterInfo, String>((ref, requesterId) {
      return ref.watch(donorRepositoryProvider).resolveRequester(requesterId);
    });

final nearestCenterProvider = FutureProvider.autoDispose
    .family<BloodCenter?, String>((ref, commune) {
      return ref.watch(centerRepositoryProvider).nearestTo(commune);
    });
