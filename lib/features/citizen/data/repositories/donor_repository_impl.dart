import '../../../../shared/domain/entities/entities.dart';
import '../../domain/repositories/donor_repository.dart';
import '../datasources/campaign_remote_datasource.dart';
import '../datasources/donor_remote_datasource.dart';
import 'package:blood_collect/shared/domain/value_objects/city_reference.dart';

/// Implémentation Firestore de [DonorRepository].
///
/// Le profil vient du document `users` du connecté, les inscriptions et les
/// mises en relation des collections dédiées. Un compte sans document `users`
/// est une inscription inachevée : la méthode lève au lieu de renvoyer un
/// profil de substitution, pour que l'appelant affiche l'état réel plutôt
/// qu'un profil inventé.
class DonorRepositoryImpl implements DonorRepository {
  const DonorRepositoryImpl(this._donors, this._campaigns);

  final DonorRemoteDataSource _donors;
  final CampaignRemoteDataSource _campaigns;

  @override
  Future<AppUser> currentCitizen() async {
    final user = await _donors.currentUser();
    if (user == null) {
      throw StateError('Aucun utilisateur Firebase connecté.');
    }
    return user;
  }

  @override
  Future<GeoLocation> donorOrigin() async {
    final commune = (await currentCitizen()).commune;
    return communeCentroids[commune] ?? defaultOrigin;
  }

  @override
  Future<List<CampaignRegistration>> registrationsOf(String donorId) =>
      _campaigns.registrationsOf(donorId);

  @override
  Future<List<DonorMatchRequest>> matchesOf(String citizenId) =>
      _donors.matchesOf(citizenId);

  @override
  Future<CampaignRegistration> registerToCampaign({
    required String campaignId,
    required String donorId,
    DateTime? scheduledTime,
  }) => _campaigns.registerToCampaign(
    campaignId: campaignId,
    donorId: donorId,
    scheduledTime: scheduledTime,
  );

  @override
  Future<void> cancelRegistration(String registrationId) =>
      _campaigns.cancelRegistration(registrationId);
}