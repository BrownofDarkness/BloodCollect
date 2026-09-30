import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Badge bleu utilisé pour tout ce qui relève du flux PERSONNES
/// (ex: "PERSONNE", "CITOYEN", "VOUS ÊTES DONNEUR").
/// Ne jamais utiliser cette couleur pour un contenu lié au flux SANG.
class PersonBadge extends StatelessWidget {
  const PersonBadge({super.key, required this.label, this.icon = Icons.person});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bleu,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.bleuLight),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.bleu,

              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Équivalent rouge pour le flux SANG (ex: "SANG · CENTRES AGRÉÉS").
class BloodBadge extends StatelessWidget {
  const BloodBadge({
    super.key,
    required this.label,
    this.icon = Icons.water_drop,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.rougeLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.rouge),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.rouge,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
