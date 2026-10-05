import '../../../../../core/utils/distance_utils.dart';
import '../../../../../shared/domain/entities/entities.dart';
import '../models/center_blood_availability.dart';
import '../repositories/blood_center_repository.dart';
import '../repositories/campaign_repository.dart';
import '../repositories/donor_repository.dart';

/// Fiche complète d'un centre de transfusion : ce que le citoyen peut consulter
/// en lecture seule — adresse, horaires, disponibilités déclarées, et la
/// collecte à venir la plus proche organisée par ce centre.
class BloodCenterDetails {
  const BloodCenterDetails({required this.entry, this.nearestCampaign});

  final CenterBloodAvailability entry;

  /// Première campagne à venir du centre, la source étant déjà triée par
  /// date de début croissante. `null` si le centre n'organise aucune collecte.
  final Campaign? nearestCampaign;

  BloodCenter get center => entry.center;
  double get distanceKm => entry.distanceKm;

  /// Dernière mise à jour du stock déclarée par le centre.
  DateTime get updatedAt => entry.updatedAt;
}

class GetBloodCenterDetailsUseCase {
  const GetBloodCenterDetailsUseCase({
    required this.centers,
    required this.campaigns,
    required this.donors,
  });

  final BloodCenterRepository centers;
  final CampaignRepository campaigns;
  final DonorRepository donors;

  /// Renvoie `null` si le centre n'existe pas ou n'est pas vérifié : un citizen
  /// ne doit pas voir la fiche d'une structure non agréée.
  Future<BloodCenterDetails?> call(String centerId, {DateTime? now}) async {
    final reference = now ?? DateTime.now();

    final center = await centers.centerById(centerId);
    if (center == null || !center.isVerified) return null;

    final lots = await centers.lotsOfCenter(center.id);
    final origin = await donors.donorOrigin();
    final upcoming = await campaigns.upcomingCampaignsOfCenter(center.id);

    return BloodCenterDetails(
      entry: CenterBloodAvailability.fromGroups(
        center: center,
        groups: BloodAvailability.allGroups(
          center: center,
          lots: lots,
          now: reference,
          origin: origin,
        ),
        distanceKm: distanceInKm(origin, center.location),
      ),
      nearestCampaign: upcoming.isEmpty ? null : upcoming.first,
    );
  }
}
