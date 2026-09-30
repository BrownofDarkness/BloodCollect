import 'dart:math';

/// OPTION A (validée équipe) : le modèle actuel n'a pas de GeoLocation sur
/// AppUser/DonorMatchRequest, donc la distance affichée dans les maquettes
/// ("2,5 km") est IMPOSSIBLE à calculer réellement côté client.
/// Ici on simule une distance plausible à partir de la commune, pour la
/// démo uniquement. Ce n'est PAS branchable tel quel sur Firestore :
/// si un vrai calcul de distance est voulu en Partie 2, il faudra ajouter
/// un champ GeoLocation quelque part (sur AppUser ou sur une sous-collection
/// de position) — à trancher avec l'équipe.
class CommuneDistances {
  CommuneDistances._();

  /// Distance de référence (km) depuis un point fixe (le centre de
  /// Treichville, utilisé comme origine dans les maquettes).
  static const Map<String, double> _reference = {
    'Treichville': 0.0,
    'Marcory': 3.8,
    'Koumassi': 5.2,
    'Plateau': 2.1,
    'Cocody': 6.4,
    'Yopougon': 9.0,
    'Abobo': 11.5,
    'Adjamé': 4.6,
    'Port-Bouët': 7.3,
    'Attécoubé': 5.9,
  };

  /// Distance mockée, légèrement bruitée pour ne pas être identique à
  /// chaque donneur d'une même commune. Seedée sur l'id pour rester stable
  /// entre deux rebuilds de l'écran (pas de scintillement des valeurs).
  static double forCommune(String commune, {required String seedKey}) {
    final base = _reference[commune] ?? 8.0;
    final r = Random(seedKey.hashCode);
    final noise = (r.nextDouble() - 0.5) * 2; // +/- 1 km
    final value = (base + noise).clamp(0.5, 25.0);
    return double.parse(value.toStringAsFixed(1));
  }
}
