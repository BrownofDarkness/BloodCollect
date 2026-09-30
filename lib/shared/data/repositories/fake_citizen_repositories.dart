import '../../domain/entities/app_user.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/citizen_repositories.dart';
import '../mock/commune_distances.dart';
import '../mock/mock_data.dart';

class FakeCenterRepository implements CenterRepository {
  @override
  Future<List<BloodCenter>> nearby() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return mockCenters;
  }

  @override
  Future<BloodCenter?> nearestTo(String commune) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mockCenters.isEmpty) return null;
    mockCenters.sort(
      (a, b) => CommuneDistances.forCommune(
        a.commune,
        seedKey: a.id,
      ).compareTo(CommuneDistances.forCommune(b.commune, seedKey: b.id)),
    );
    return mockCenters.first;
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
    return mockCitizenProfile;
  }
}
