// Auteur d'une demande de mise en relation, tel que le donneur le voit.
// Un centre de santé est nommé ; un particulier reste anonyme. Non persisté.
class MatchRequester {
  const MatchRequester({
    required this.isHealthCenter,
    this.centerName,
    this.commune,
    this.phone,
  });

  final bool isHealthCenter;

  /// Nom de l'établissement ; null pour un particulier.
  final String? centerName;
  final String? commune;

  /// À n'afficher que si la demande est acceptée et que le demandeur a
  /// autorisé le partage de ses coordonnées.
  final String? phone;

  bool get hasPhone => phone != null && phone!.isNotEmpty;
}
