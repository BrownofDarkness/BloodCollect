import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import '../../../../shared/domain/entities/blood_center.dart';

/// Disponibilité d'un centre de transfusion, regroupée pour le module citoyen.
///
/// L'entité partagée [BloodAvailability] décrit UN groupe sanguin dans UN
/// centre. Les écrans du citoyen affichent, eux, UNE carte par centre avec un
/// statut résumé et une grille des 8 groupes. Cette classe fait la transposition
/// des deux vues : elle ne duplique rien de l'entité partagée, elle ne garde que
/// la forme agrégée dont l'interface citoyen a besoin.
class CenterBloodAvailability {
  const CenterBloodAvailability({
    required this.center,
    required this.levelsByBloodType,
    required this.updatedAt,
    required this.distanceKm,
  });

  /// Regroupe les lignes produites par [BloodAvailability.allGroups].
  ///
  /// `updatedAt` reste la date déclarée par le centre : c'est elle qui est
  /// affichée sur les cartes, indépendamment de la date du dernier lot.
  factory CenterBloodAvailability.fromGroups({
    required BloodCenter center,
    required List<BloodAvailability> groups,
    required double distanceKm,
  }) {
    return CenterBloodAvailability(
      center: center,
      levelsByBloodType: {
        for (final group in groups) group.bloodType: group.level,
      },
      updatedAt: center.updatedAt,
      distanceKm: distanceKm,
    );
  }

  final BloodCenter center;

  /// Niveau déclaré, groupe par groupe. Un groupe absent vaut « indisponible ».
  final Map<BloodType, AvailabilityLevel> levelsByBloodType;

  /// Dernière mise à jour déclarée par le centre.
  final DateTime updatedAt;

  /// Distance au citoyen, en kilomètres.
  final double distanceKm;

  /// Niveau d'un groupe sanguin. Un groupe absent du stock est indiscernable
  /// d'un groupe épuisé.
  AvailabilityLevel levelOf(BloodType bloodType) =>
      levelsByBloodType[bloodType] ?? AvailabilityLevel.unavailable;

  /// Meilleur niveau du centre : un centre n'est jamais présenté comme
  /// indisponible s'il a un groupe en stock.
  AvailabilityLevel get bestLevel {
    var best = AvailabilityLevel.unavailable;
    for (final level in levelsByBloodType.values) {
      if (level == AvailabilityLevel.available) {
        return AvailabilityLevel.available;
      }
      if (level == AvailabilityLevel.limited) {
        best = AvailabilityLevel.limited;
      }
    }
    return best;
  }

  /// Nombre de groupes sanguins disponibles : sert au tri « les plus fournis ».
  int get availableBloodTypeCount => levelsByBloodType.values
      .where((level) => level == AvailabilityLevel.available)
      .length;
}
