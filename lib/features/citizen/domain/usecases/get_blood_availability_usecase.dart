import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/utils/distance_utils.dart';
import '../../../../../shared/domain/entities/entities.dart';
import '../models/center_blood_availability.dart';
import '../repositories/blood_center_repository.dart';
import '../repositories/donor_repository.dart';

/// Filtres de l'onglet « Sang ». Un champ nul = pas de filtre sur ce critère.
class BloodAvailabilityFilter {
  const BloodAvailabilityFilter({this.bloodType, this.city, this.commune});

  final BloodType? bloodType;
  final String? city;
  final String? commune;

  static const none = BloodAvailabilityFilter();

  bool get isActive => bloodType != null || city != null || commune != null;

  BloodAvailabilityFilter copyWith({
    BloodType? Function()? bloodType,
    String? Function()? city,
    String? Function()? commune,
  }) {
    return BloodAvailabilityFilter(
      bloodType: bloodType != null ? bloodType() : this.bloodType,
      city: city != null ? city() : this.city,
      commune: commune != null ? commune() : this.commune,
    );
  }
}

/// Trie de la liste des centres. Par défaut : distance croissante, l'ordre du
/// quotidien — le centre le plus proche est le premier levier d'action.
enum BloodAvailabilitySort { distance, name, mostAvailable }

/// Liste « Disponibilité du sang » : centres vérifiés, filtrés, triés, avec
/// leur distance au citoyen et leur statut public agrégé par groupe sanguin.
class GetBloodAvailabilityUseCase {
  const GetBloodAvailabilityUseCase({
    required this.centers,
    required this.donors,
  });

  final BloodCenterRepository centers;
  final DonorRepository donors;

  Future<List<CenterBloodAvailability>> call({
    BloodAvailabilityFilter filter = BloodAvailabilityFilter.none,
    BloodAvailabilitySort sort = BloodAvailabilitySort.distance,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final origin = await donors.donorOrigin();

    final verified = await centers.verifiedCenters();
    final results = <CenterBloodAvailability>[];

    for (final center in verified) {
      if (!_matchesLocation(center, filter)) continue;

      final lots = await centers.lotsOfCenter(center.id);
      results.add(
        CenterBloodAvailability.fromGroups(
          center: center,
          groups: BloodAvailability.allGroups(
            center: center,
            lots: lots,
            now: reference,
            origin: origin,
          ),
          distanceKm: distanceInKm(origin, center.location),
        ),
      );
    }

    results.sort((a, b) => _compare(a, b, sort));
    return results;
  }

  bool _matchesLocation(BloodCenter center, BloodAvailabilityFilter filter) {
    if (filter.city != null && center.city != filter.city) {
      return false;
    }
    if (filter.commune != null && center.commune != filter.commune) {
      return false;
    }
    return true;
  }

  int _compare(
    CenterBloodAvailability a,
    CenterBloodAvailability b,
    BloodAvailabilitySort sort,
  ) => switch (sort) {
    BloodAvailabilitySort.distance => a.distanceKm.compareTo(b.distanceKm),
    BloodAvailabilitySort.name => a.center.name.compareTo(b.center.name),
    BloodAvailabilitySort.mostAvailable =>
      b.availableBloodTypeCount.compareTo(a.availableBloodTypeCount),
  };
}
