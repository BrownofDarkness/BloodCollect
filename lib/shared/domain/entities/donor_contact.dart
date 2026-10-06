// Coordonnées d'un citoyen, lues depuis son profil users. Non persisté.
// Nom et téléphone ne doivent être affichés qu'une fois la mise en relation
// acceptée ; la commune seule sert à situer un demandeur resté anonyme.
class DonorContact {
  const DonorContact({
    required this.donorId,
    required this.fullName,
    this.phone,
    this.commune,
  });

  final String donorId;
  final String fullName;
  final String? phone;
  final String? commune;

  bool get hasPhone => phone != null && phone!.isNotEmpty;
}
