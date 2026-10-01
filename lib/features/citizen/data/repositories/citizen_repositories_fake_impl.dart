import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../domain/repositories/citizen_read_repositories.dart';
import '../mock/commune_distances.dart';
import '../mock/mock_records.dart';

/// Implémentations de test des repositories de lecture du parcours donneurs.
///
/// Elles s'appuient sur le même jeu de données que les onglets Sang, Donner et
/// Profil : un seul profil, une seule liste de centres, une seule liste de
/// collectes. Sans cela, l'accueil et l'onglet Sang afficheraient des centres
/// différents, avec des distances et des horaires incohérents entre les écrans.
class FakeCenterRepository implements CenterRepository {
  @override
  Future<List<BloodCenter>> nearby() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return mockBloodCenters;
  }

  @override
  Future<BloodCenter?> nearestTo(String commune) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mockBloodCenters.isEmpty) return null;

    // Copie avant tri : trier la liste partagée la réordonnerait pour tous les
    // écrans qui la lisent.
    final ranked = List<BloodCenter>.of(mockBloodCenters)
      ..sort(
        (a, b) => CommuneDistances.forCommune(
          a.commune,
          seedKey: a.id,
        ).compareTo(CommuneDistances.forCommune(b.commune, seedKey: b.id)),
      );
    return ranked.first;
  }
}

class FakeCampaignRepository implements CampaignRepository {
  @override
  Future<List<Campaign>> upcoming() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return mockCampaigns;
  }
}

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<AppUser> getCurrentProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockCitizen;
  }
}
