import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';

abstract class CenterRepository {
  Future<List<BloodCenter>> nearby();

  /// Centre le plus proche d'une commune donnée.
  Future<BloodCenter?> nearestTo(String commune);
}

abstract class CampaignRepository {
  Future<List<Campaign>> upcoming();
}

abstract class ProfileRepository {
  Future<AppUser> getCurrentProfile();
}
