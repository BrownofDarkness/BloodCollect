import '../../../core/constants/app_enums.dart';

/// Projection de présentation pour l'écran "Donneurs potentiels".
///
/// Ce n'est pas une collection Firestore : c'est un profil anonymisé
/// accompagné de sa distance au demandeur, la distance étant calculée depuis
/// le centroïde de la commune (`city_reference.dart`) tant que le citoyen
/// n'a pas partagé sa position GPS.
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
