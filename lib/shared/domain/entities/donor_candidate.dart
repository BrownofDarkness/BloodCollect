import '../../../core/constants/app_enums.dart';

// Donneur potentiel renvoyé par une recherche, anonymisé côté serveur :
// groupe + commune + distance. Aucune donnée d'identité ni de contact,
// partagées seulement après acceptation de la mise en relation.
class DonorCandidate {
  const DonorCandidate({
    required this.donorId,
    required this.bloodType,
    required this.commune,
    this.distanceKm,
  });

  // UID opaque, nécessaire pour créer la donor_match_request.
  final String donorId;
  final BloodType bloodType;
  final String commune;
  // null si la position du donneur ou du centre est inconnue.
  final double? distanceKm;
}
