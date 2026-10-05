import '../../../core/constants/app_enums.dart';
import 'blood_center.dart';
import 'blood_stock_lot.dart';
import 'geo_location.dart';

// Niveau de disponibilité déclaré, calculé depuis les seuils du centre.
// Non persisté : pas de valeur Firestore.
enum AvailabilityLevel { available, limited, unavailable }

// Disponibilité d'un groupe sanguin dans un centre de transfusion.
// Vue calculée (aucune collection) : seul le niveau est exposé,
// jamais les quantités du stock.
class BloodAvailability {
  const BloodAvailability({
    required this.center,
    required this.bloodType,
    required this.level,
    required this.updatedAt,
    this.distanceKm,
  });

  /// Agrège les lots d'un centre pour un groupe. Seuls les lots
  /// `available` non périmés comptent ; les seuils du centre tranchent.
  factory BloodAvailability.fromLots({
    required BloodCenter center,
    required BloodType bloodType,
    required Iterable<BloodStockLot> lots,
    required DateTime now,
    GeoLocation? origin,
  }) {
    var units = 0;
    var updatedAt = center.updatedAt;
    var hasLot = false;
    for (final lot in lots) {
      if (lot.bloodCenterId != center.id || lot.bloodType != bloodType) {
        continue;
      }
      if (!hasLot || lot.updatedAt.isAfter(updatedAt)) {
        updatedAt = lot.updatedAt;
      }
      hasLot = true;
      if (lot.isAvailable && !lot.isExpiredAt(now)) units += lot.quantity;
    }

    final level = units <= center.unavailableThreshold
        ? AvailabilityLevel.unavailable
        : units <= center.lowStockThreshold
        ? AvailabilityLevel.limited
        : AvailabilityLevel.available;

    return BloodAvailability(
      center: center,
      bloodType: bloodType,
      level: level,
      updatedAt: updatedAt,
      distanceKm: center.location.knownDistanceKmTo(origin),
    );
  }

  /// Disponibilité des 8 groupes d'un centre, dans l'ordre d'affichage.
  static List<BloodAvailability> allGroups({
    required BloodCenter center,
    required Iterable<BloodStockLot> lots,
    required DateTime now,
    GeoLocation? origin,
  }) {
    return [
      for (final bloodType in BloodType.displayOrder)
        BloodAvailability.fromLots(
          center: center,
          bloodType: bloodType,
          lots: lots,
          now: now,
          origin: origin,
        ),
    ];
  }

  final BloodCenter center;
  final BloodType bloodType;
  final AvailabilityLevel level;
  final DateTime updatedAt;
  // null tant que l'une des deux positions GPS n'est pas renseignée.
  final double? distanceKm;

  bool get canRequest => level != AvailabilityLevel.unavailable;

  /// Tri d'affichage : du plus disponible au moins disponible,
  /// puis du plus proche au plus loin, puis par nom.
  static int compare(BloodAvailability a, BloodAvailability b) {
    final byLevel = a.level.index.compareTo(b.level.index);
    if (byLevel != 0) return byLevel;
    final byDistance = (a.distanceKm ?? double.infinity)
        .compareTo(b.distanceKm ?? double.infinity);
    if (byDistance != 0) return byDistance;
    return a.center.name.compareTo(b.center.name);
  }
}