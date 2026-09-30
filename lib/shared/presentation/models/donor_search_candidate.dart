import '../../../core/constants/app_enums.dart';

/// Projection de présentation pour l'écran "Donneurs potentiels".
/// Ce n'est PAS une collection Firestore — c'est une combinaison
/// AppUser (anonymisé) + une distance mockée (cf. commune_distances.dart,
/// Option A). En Partie 2, le repository Firestore réel devra construire
/// cet objet à partir d'une requête sur `users` + le calcul de distance
/// qui sera finalement choisi par l'équipe.
class DonorSearchCandidate {
  const DonorSearchCandidate({
    required this.donorId,
    required this.bloodType,
    required this.commune,
    required this.distanceKm,
    this.matchStatus, // null = pas encore contacté dans cette recherche
  });

  final String donorId;
  final BloodType bloodType;
  final String commune;
  final double distanceKm;
  final DonorMatchStatus? matchStatus;

  DonorSearchCandidate copyWith({DonorMatchStatus? matchStatus}) =>
      DonorSearchCandidate(
        donorId: donorId,
        bloodType: bloodType,
        commune: commune,
        distanceKm: distanceKm,
        matchStatus: matchStatus ?? this.matchStatus,
      );
}
