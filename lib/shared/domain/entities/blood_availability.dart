import '../../../core/constants/app_enums.dart';
import 'blood_center.dart';
import 'blood_stock_lot.dart';

// Disponibilité publique d'un centre de transfusion, agrégée par groupe sanguin.
//
// Règle du design system : cette classe ne décrit QUE du sang collecté, qualifié
// et géré par un centre agréé. Elle ne représente jamais une personne.

/// Les 3 niveaux de disponibilité, jamais communiqués par la couleur seule.
enum BloodAvailabilityStatus { available, limited, unavailable }

/// Vue « Disponibilité du sang » d'un centre : un statut par groupe sanguin.
class BloodAvailability {
  const BloodAvailability({
    required this.center,
    required this.statusByBloodType,
    required this.unitsByBloodType,
    required this.updatedAt,
  });

  final BloodCenter center;
  final Map<BloodType, BloodAvailabilityStatus> statusByBloodType;
  final Map<BloodType, int> unitsByBloodType;

  /// Dernière mise à jour du stock déclarée par le centre.
  final DateTime updatedAt;

  /// Un groupe absent du stock est indiscernable d'un groupe épuisé.
  BloodAvailabilityStatus statusOf(BloodType bloodType) =>
      statusByBloodType[bloodType] ?? BloodAvailabilityStatus.unavailable;

  int unitsOf(BloodType bloodType) => unitsByBloodType[bloodType] ?? 0;

  /// Agrège les lots en stock d'un centre selon ses seuils.
  ///
  /// Les lots périmés, utilisés ou éliminés sont ignorés : seuls les lots
  /// `available` non expirés alimentent la disponibilité publique.
  factory BloodAvailability.fromLots({
    required BloodCenter center,
    required List<BloodStockLot> lots,
    required DateTime updatedAt,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final units = <BloodType, int>{
      for (final type in BloodType.values) type: 0,
    };

    for (final lot in lots) {
      if (lot.bloodCenterId != center.id) continue;
      if (!lot.isAvailable || lot.isExpiredAt(reference)) continue;
      units[lot.bloodType] = units[lot.bloodType]! + lot.quantity;
    }

    return BloodAvailability(
      center: center,
      unitsByBloodType: units,
      statusByBloodType: {
        for (final type in BloodType.values)
          type: _statusOf(
            units[type]!,
            lowStockThreshold: center.lowStockThreshold,
            unavailableThreshold: center.unavailableThreshold,
          ),
      },
      updatedAt: updatedAt,
    );
  }

  static BloodAvailabilityStatus _statusOf(
    int units, {
    required int lowStockThreshold,
    required int unavailableThreshold,
  }) {
    if (units >= lowStockThreshold) return BloodAvailabilityStatus.available;
    if (units >= unavailableThreshold) return BloodAvailabilityStatus.limited;
    return BloodAvailabilityStatus.unavailable;
  }
}

/// Un centre vu depuis la position du citoyen : sa disponibilité publique et
/// la distance à parcourir. Le centre reste l'objet du sang — la distance est
/// une donnée de contexte, jamais de la disponibilité.
class BloodCenterAvailability {
  const BloodCenterAvailability({
    required this.availability,
    required this.distanceKm,
  });

  final BloodAvailability availability;
  final double distanceKm;

  BloodCenter get center => availability.center;

  BloodAvailabilityStatus statusOf(BloodType bloodType) =>
      availability.statusOf(bloodType);

  DateTime get updatedAt => availability.updatedAt;
}
