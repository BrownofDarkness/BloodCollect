import '../../../../core/utils/distance_utils.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/value_objects/city_reference.dart';
import '../../domain/repositories/citizen_read_repositories.dart';
import '../datasources/citizen_read_remote_datasource.dart';

/// Implémentations Firestore des lectures de l'accueil.
class CenterReadRepositoryImpl implements CenterRepository {
  const CenterReadRepositoryImpl(this._remote);

  final CitizenReadRemoteDataSource _remote;

  @override
  Future<List<BloodCenter>> nearby() => _remote.verifiedCenters();

  @override
  Future<BloodCenter?> nearestTo(String commune) async {
    // Distance depuis le centroïde de la commune : approximation à l'échelle
    // du quartier, le citizens n'ayant pas de position GPS partagée.
    final origin = communeCentroids[commune] ?? defaultOrigin;

    final centers = await _remote.verifiedCenters();
    if (centers.isEmpty) return null;

    final ranked = List<BloodCenter>.of(centers)
      ..sort(
        (a, b) => distanceInKm(origin, a.location).compareTo(
          distanceInKm(origin, b.location),
        ),
      );
    return ranked.first;
  }
}

class CampaignReadRepositoryImpl implements CampaignRepository {
  const CampaignReadRepositoryImpl(this._remote);

  final CitizenReadRemoteDataSource _remote;

  @override
  Future<List<Campaign>> upcoming() => _remote.publishedCampaigns();
}

class ProfileReadRepositoryImpl implements ProfileRepository {
  const ProfileReadRepositoryImpl(this._remote);

  final CitizenReadRemoteDataSource _remote;

  @override
  Future<AppUser> getCurrentProfile() async {
    final profile = await _remote.currentProfile();
    if (profile == null) {
      throw StateError('Aucun profil pour la session ouverte.');
    }
    return profile;
  }
}