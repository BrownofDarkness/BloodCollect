import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import '../../../../shared/presentation/models/requester_info.dart';
import '../../data/datasources/citizen_read_remote_datasource.dart';
import '../../data/datasources/donor_search_remote_datasource.dart';
import '../../data/repositories/citizen_read_repository_impl.dart';
import '../../data/repositories/donor_search_repository_impl.dart';
import '../../domain/repositories/citizen_read_repositories.dart';
import '../../domain/repositories/donor_search_repository.dart';

part 'donor_providers.g.dart';

/// Repositories du parcours donneurs.
@Riverpod(keepAlive: true)
CitizenReadRemoteDataSource citizenReadRemoteDataSource(Ref ref) =>
    CitizenReadRemoteDataSource();

@Riverpod(keepAlive: true)
DonorSearchRemoteDataSource donorSearchRemoteDataSource(Ref ref) =>
    DonorSearchRemoteDataSource();

@Riverpod(keepAlive: true)
DonorRepository donorSearchRepository(Ref ref) =>
    DonorSearchRepositoryImpl(ref.watch(donorSearchRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
CenterRepository centerRepository(Ref ref) =>
    CenterReadRepositoryImpl(ref.watch(citizenReadRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
CampaignRepository upcomingCampaignRepository(Ref ref) =>
    CampaignReadRepositoryImpl(
      ref.watch(citizenReadRemoteDataSourceProvider),
    );

@Riverpod(keepAlive: true)
ProfileRepository citizenAccountRepository(Ref ref) =>
    ProfileReadRepositoryImpl(ref.watch(citizenReadRemoteDataSourceProvider));

// --- Écran Accueil ---

@riverpod
Future<AppUser> citizenAccount(Ref ref) {
  return ref.watch(citizenAccountRepositoryProvider).getCurrentProfile();
}

@riverpod
Future<List<Campaign>> upcomingCampaigns(Ref ref) {
  return ref.watch(upcomingCampaignRepositoryProvider).upcoming();
}

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

  /// Une recherche n'est lancé qu'un groupe sanguin et au moins une commune
  /// sont choisis : sans cela, le citizenéen verrait tout Abidjan.
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

@riverpod
class DonorSearchFiltersNotifier extends _$DonorSearchFiltersNotifier {
  @override
  DonorSearchFilters build() =>
      const DonorSearchFilters(bloodType: BloodType.oPos);

  void setBloodType(BloodType type) => state = state.copyWith(bloodType: type);

  void setPriority(Priority priority) =>
      state = state.copyWith(priority: priority);

  /// Changer de ville invalide les communes choisies : elles appartiennent a
  /// l'ancienne ville, et les conserver produirait une recherche incoherente.
  void setCity(String city) => state = state.copyWith(city: city, communes: const {});

  void toggleCommune(String commune) {
    final updated = {...state.communes};
    if (!updated.remove(commune)) updated.add(commune);
    state = state.copyWith(communes: updated);
  }

  void selectAllCommunes(List<String> all) =>
      state = state.copyWith(communes: all.toSet());
}

/// Écrans Donneurs potentiels.
@riverpod
Future<List<DonorSearchCandidate>> donorSearchResults(
  Ref ref,
  DonorSearchFilters filters,
) {
  return ref
      .watch(donorSearchRepositoryProvider)
      .searchDonors(
        bloodType: filters.bloodType!,
        communes: filters.communes.toList(),
        priority: filters.priority,
      );
}

/// Donneurs déjà contactés dans cette session : permet de basculer la carte en
/// « En attente » sans relancer la recherche.
@riverpod
class ContactedDonorIds extends _$ContactedDonorIds {
  @override
  Set<String> build() => const {};

  void markContacted(String donorId) {
    state = {...state, donorId};
  }
}

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

  /// Le demandeur ne transmet son numéro qu'après acceptation, et seulement
  /// s'il l'a demandé.
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

@riverpod
class MatchRequestForm extends _$MatchRequestForm {
  @override
  MatchRequestFormState build(String donorId) => const MatchRequestFormState();

  void setPriority(Priority priority) =>
      state = state.copyWith(priority: priority);

  void setMessage(String message) => state = state.copyWith(message: message);

  void setShareContact(bool value) =>
      state = state.copyWith(shareContact: value);

  /// `donorBloodType` est celui du donneur ciblé : il rejoint la demande
  /// parce que le profil du donneur n'est pas lisible par le demandeur.
  Future<DonorMatchRequest> submit(
    String donorId, {
    required BloodType donorBloodType,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      return await ref
          .read(donorSearchRepositoryProvider)
          .sendMatchRequest(
            donorId: donorId,
            bloodType: donorBloodType,
            priority: state.priority,
            message: state.message.isEmpty ? null : state.message,
            shareContact: state.shareContact,
          );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

// --- Écran Demande reçue ---

/// Demandes de mobilisation reçues, la plus récente d'abord.
@riverpod
Future<List<DonorMatchRequest>> incomingMatchRequests(Ref ref) {
  return ref.watch(donorSearchRepositoryProvider).incomingRequests();
}

/// Demande reçue qui attend encore une réponse : c'est celle que l'accueil
/// propose d'ouvrir en priorité. Une liste sans demande en attente ne doit pas
/// afficher de pastille.
@riverpod
Future<DonorMatchRequest?> pendingIncomingRequest(Ref ref) async {
  final requests = await ref.watch(incomingMatchRequestsProvider.future);
  for (final request in requests) {
    if (request.status == DonorMatchStatus.pending) return request;
  }
  return null;
}

@riverpod
Future<DonorMatchRequest> incomingMatchRequest(Ref ref, String requestId) {
  return ref.watch(donorSearchRepositoryProvider).getIncomingRequest(requestId);
}

/// Résout l'auteur d'une demande pour l'afficher au donneur. Un donneur ne voit
/// ni le nom du patient ni de donnée médicale : seulement qui demande, et dans
/// quelle commune.
@riverpod
Future<RequesterInfo> requesterInfo(Ref ref, String requesterId) {
  return ref.watch(donorSearchRepositoryProvider).resolveRequester(requesterId);
}

/// Centre agréé le plus proche, proposé au donneur qui accepte.
@riverpod
Future<BloodCenter?> nearestCenter(Ref ref, String commune) {
  return ref.watch(centerRepositoryProvider).nearestTo(commune);
}
