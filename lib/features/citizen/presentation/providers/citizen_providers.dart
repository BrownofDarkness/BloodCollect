import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/blood_center_remote_datasource.dart';
import '../../data/datasources/campaign_remote_datasource.dart';
import '../../data/datasources/donor_remote_datasource.dart';
import '../../data/repositories/blood_center_repository_impl.dart';
import '../../data/repositories/campaign_repository_impl.dart';
import '../../data/repositories/donor_repository_impl.dart';
import 'package:blood_collect/shared/domain/value_objects/city_reference.dart';
import '../../domain/models/center_blood_availability.dart';
import '../../domain/repositories/blood_center_repository.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../../domain/repositories/donor_repository.dart';
import '../../domain/usecases/campaign_registration_usecases.dart';
import '../../domain/usecases/get_blood_availability_usecase.dart';
import '../../domain/usecases/get_blood_center_details_usecase.dart';
import '../../domain/usecases/get_citizen_profile_usecase.dart';
import '../../domain/usecases/get_donation_dashboard_usecase.dart';

part 'citizen_providers.g.dart';

/// Sources Firestore du module. `keepAlive` évite qu'un onglet et un autre
@Riverpod(keepAlive: true)
BloodCenterRemoteDataSource bloodCenterRemoteDataSource(Ref ref) =>
    BloodCenterRemoteDataSource();

@Riverpod(keepAlive: true)
CampaignRemoteDataSource campaignRemoteDataSource(Ref ref) =>
    CampaignRemoteDataSource();

@Riverpod(keepAlive: true)
DonorRemoteDataSource donorRemoteDataSource(Ref ref) => DonorRemoteDataSource();

@Riverpod(keepAlive: true)
BloodCenterRepository bloodCenterRepository(Ref ref) =>
    BloodCenterRepositoryImpl(ref.watch(bloodCenterRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
CampaignRepository campaignRepository(Ref ref) =>
    CampaignRepositoryImpl(ref.watch(campaignRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
DonorRepository donorRepository(Ref ref) => DonorRepositoryImpl(
  ref.watch(donorRemoteDataSourceProvider),
  ref.watch(campaignRemoteDataSourceProvider),
);

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
Future<List<CenterBloodAvailability>> bloodAvailabilityList(
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

/// Villes proposées par le filtre « Ville ». Le référentiel géographique sert
/// tant qu'aucun service d'adresses n'est branché.
@Riverpod(keepAlive: true)
List<String> bloodFilterCities(Ref ref) => referenceCities;

/// Communes d'une ville. Un résultat vide signifie « pas de filtre possible ».
@riverpod
Future<List<String>> bloodFilterCommunes(Ref ref, String city) async =>
    communesOfCity(city);
