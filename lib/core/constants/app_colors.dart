import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Couleurs primaires du design system BloodCollect
  static const Color rouge  = Color(0xFF9F1239); // sang — stocks, collectes, disponibilités
  static const Color bleu   = Color(0xFF1E3A8A); // personnes — donneurs, demandeurs
  static const Color ivoire = Color(0xFFF6F2EC); // fond général

  // Déclinaisons claires
  static const Color rougeLight = Color(0xFFFFF1F2);
  static const Color bleuLight  = Color(0xFFEFF6FF);

  // Statuts de disponibilité du stock (calculés depuis les seuils)
  static const Color disponible   = Color(0xFF166534); // vert foncé
  static const Color limite       = Color(0xFFB45309); // amber
  static const Color indisponible = Color(0xFF9F1239); // rouge

  // Fonds des pastilles de statut
  static const Color disponibleLight   = Color(0xFFDCFCE7);
  static const Color limiteLight       = Color(0xFFFFEDD5);
  static const Color indisponibleLight = Color(0xFFFFE4E6);

  // Priorités
  static const Color priorityNormal   = Color(0xFF6B7280); // gris
  static const Color priorityElevated = Color(0xFFB45309); // amber
  static const Color priorityVital    = Color(0xFF9F1239); // rouge

  // Neutres
  static const Color encre = Color(0xFF1C1917);
  static const Color gris  = Color(0xFF6B7280);
  static const Color slate = Color(0xFF374151);
  static const Color ligne = Color(0xFFE7E0D9);
}
