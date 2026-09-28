import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/entities/entities.dart';
import '../../data/datasources/citizen_mock_datasource.dart';
import '../../data/repositories/blood_center_repository_impl.dart';
import '../../data/repositories/campaign_repository_impl.dart';
import '../../data/repositories/donor_repository_impl.dart';
import '../../data/mock/mock_geography.dart';
import '../../domain/repositories/blood_center_repository.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../../domain/repositories/donor_repository.dart';
import '../../domain/usecases/campaign_registration_usecases.dart';
import '../../domain/usecases/get_blood_availability_usecase.dart';
import '../../domain/usecases/get_blood_center_details_usecase.dart';
import '../../domain/usecases/get_citizen_profile_usecase.dart';
import '../../domain/usecases/get_donation_dashboard_usecase.dart';

part 'citizen_providers.g.dart';

/// Source unique et mutable pour l'ensemble du module : inscrire puis annuler
/// une collecte se reflète partout. `keepAlive` évite qu'un onglet recrée un
/// dépôt différent de celui d'un autre onglet.
@Riverpod(keepAlive: true)
CitizenMockDataSource citizenMockDataSource(Ref ref) => CitizenMockDataSource();

@Riverpod(keepAlive: true)
BloodCenterRepository bloodCenterRepository(Ref ref) =>
    BloodCenterRepositoryImpl(ref.watch(citizenMockDataSourceProvider));

@Riverpod(keepAlive: true)
CampaignRepository campaignRepository(Ref ref) =>
    CampaignRepositoryImpl(ref.watch(citizenMockDataSourceProvider));

@Riverpod(keepAlive: true)
DonorRepository donorRepository(Ref ref) =>
    DonorRepositoryImpl(ref.watch(citizenMockDataSourceProvider));

@Riverpod(keepAlive: true)
GetBloodAvailabilityUseCase getBloodAvailabilityUseCase(Ref ref) =>
    GetBloodAvailabilityUseCase(
      centers: ref.watch(bloodCenterRepositoryProvider),
      donors: ref.watch(donorRepositoryProvider),
    );

@Riverpod(keepAlive: true)
GetBloodCenterDetailsUseCase getBloodCenterDetailsUseCase(Ref ref) =>
    GetBloodCenterDetailsUseCase(
      centers: ref.watch(bloodCenterRepositoryProvider),
      campaigns: ref.watch(campaignRepositoryProvider),
      donors: ref.watch(donorRepositoryProvider),
    );

@Riverpod(keepAlive: true)
GetDonationDashboardUseCase getDonationDashboardUseCase(Ref ref) =>
    GetDonationDashboardUseCase(
      centers: ref.watch(bloodCenterRepositoryProvider),
      campaigns: ref.watch(campaignRepositoryProvider),
      donors: ref.watch(donorRepositoryProvider),
    );

@Riverpod(keepAlive: true)
GetCitizenProfileUseCase getCitizenProfileUseCase(Ref ref) =>
    GetCitizenProfileUseCase(donors: ref.watch(donorRepositoryProvider));

@Riverpod(keepAlive: true)
JoinCampaignUseCase joinCampaignUseCase(Ref ref) => JoinCampaignUseCase(
  campaigns: ref.watch(campaignRepositoryProvider),
  donors: ref.watch(donorRepositoryProvider),
);

@Riverpod(keepAlive: true)
CancelRegistrationUseCase cancelRegistrationUseCase(Ref ref) =>
    CancelRegistrationUseCase(donors: ref.watch(donorRepositoryProvider));

/// Onglet « Sang » : la liste dépend des filtres, donc chaque changement de
/// filtre invalide et relance la requête.
@riverpod
Future<List<BloodCenterAvailability>> bloodAvailabilityList(
  Ref ref,
  BloodAvailabilityFilter filter,
  BloodAvailabilitySort sort,
) {
  return ref.watch(getBloodAvailabilityUseCaseProvider)(
    filter: filter,
    sort: sort,
  );
}

@riverpod
Future<BloodCenterDetails?> bloodCenterDetails(Ref ref, String centerId) {
  return ref.watch(getBloodCenterDetailsUseCaseProvider)(centerId);
}

/// Onglet « Donner ».
@riverpod
Future<DonationDashboard> donationDashboard(Ref ref) {
  return ref.watch(getDonationDashboardUseCaseProvider)();
}

/// Onglet « Profil ».
@riverpod
Future<CitizenProfile> citizenProfile(Ref ref) {
  return ref.watch(getCitizenProfileUseCaseProvider)();
}

/// Villes proposées par le filtre « Ville ». Référentiel de test tant qu'aucun
/// service d'adresses n'est branché — voir `data/mock/README.md`.
@Riverpod(keepAlive: true)
List<String> bloodFilterCities(Ref ref) => mockCities;

/// Communes d'une ville. Un résultat vide signifie « pas de filtre possible ».
@riverpod
Future<List<String>> bloodFilterCommunes(Ref ref, String city) async =>
    mockCommunesOf(city);
