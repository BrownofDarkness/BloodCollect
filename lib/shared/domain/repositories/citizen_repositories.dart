import '../entities/app_user.dart';
import '../entities/blood_center.dart';
import '../entities/campaign.dart';

abstract class CenterRepository {
  Future<List<BloodCenter>> nearby();

  /// Centre le plus proche d'une commune donnée (mock Option A).
  Future<BloodCenter?> nearestTo(String commune);
}

abstract class CampaignRepository {
  Future<List<Campaign>> upcoming();
}

abstract class ProfileRepository {
  Future<AppUser> getCurrentProfile();
}
