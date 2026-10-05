import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Couleurs primaires du design system BloodCollect
  static const Color rouge = Color(
    0xFF9F1239,
  ); // sang — stocks, collectes, disponibilités
  static const Color bleu = Color(
    0xFF1E3A8A,
  ); // personnes — donneurs, demandeurs
  static const Color ivoire = Color(0xFFF6F2EC); // fond général

  // Déclinaisons claires
  static const Color rougeLight = Color(0xFFFFF1F2);
  static const Color bleuLight = Color(0xFFEFF6FF);

  // Fonds de surfaces — valeurs relevees sur les maquettes du PDF Citoyen.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color encart = Color(0xFFEDE6DC); // appel sur fond ivoire
  static const Color carteFond = Color(0xFFE8E1D7); // fond de la carte
  static const Color roseLight = Color(0xFFFCE8EA); // pastille, icone centre
  static const Color bleuSurface = Color(0xFFE6ECF8); // avatar profil

  // Fonds des pastilles de statut. Jamais la couleur seule : toujours
  // accompagnees d'une icone et d'un libelle.
  static const Color disponibleLight = Color(0xFFDCFCE7);
  static const Color limiteLight = Color(0xFFFFEDD5);
  static const Color indisponibleLight = Color(0xFFFEE2E1);

  // Statuts de disponibilité du stock (calculés depuis les seuils)
  static const Color disponible = Color(0xFF166534); // vert foncé
  static const Color limite = Color(0xFFB45309); // amber
  static const Color indisponible = Color(0xFF9F1239); // rouge

  // Fonds des pastilles de statut
  static const Color disponibleLight   = Color(0xFFDCFCE7);
  static const Color limiteLight       = Color(0xFFFFEDD5);
  static const Color indisponibleLight = Color(0xFFFFE4E6);

  // Demande orientée vers un autre centre
  static const Color violet      = Color(0xFF5B21B6);
  static const Color violetLight = Color(0xFFF3E8FF);

  // Priorités
  static const Color priorityNormal = Color(0xFF6B7280); // gris
  static const Color priorityElevated = Color(0xFFB45309); // amber
  static const Color priorityVital = Color(0xFF9F1239); // rouge

  // Neutres
  static const Color encre = Color(0xFF1C1917);
  static const Color gris = Color(0xFF6B7280);
  static const Color slate = Color(0xFF374151);
  static const Color ligne = Color(0xFFE7E0D6);
  static const textSecondary = Color(0xFF57534E); // Texte secondaire
}
