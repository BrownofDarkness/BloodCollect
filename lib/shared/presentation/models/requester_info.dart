import '../../../core/constants/app_enums.dart';

/// Résolution de présentation de `DonorMatchRequest.requesterId`.
/// On réutilise UserRole (déjà dans app_enums.dart) plutôt qu'un enum
/// maison : health_center / citizen y sont déjà distingués.
/// displayName vient soit du nom de la structure (health_centers.name,
/// non fourni dans les fichiers reçus — à brancher en Partie 2), soit
/// d'un libellé générique pour un citoyen (anonymat, cf. système visuel).
class RequesterInfo {
  const RequesterInfo({
    required this.role,
    required this.displayName,
    required this.commune,
  });

  final UserRole role;
  final String displayName;
  final String commune;

  bool get isHealthCenter => role == UserRole.healthCenter;
}
