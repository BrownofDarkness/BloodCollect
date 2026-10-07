import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Badge bleu « CITOYEN » affiché en tête des écrans de l'espace.
class CitizenRoleBadge extends StatelessWidget {
  const CitizenRoleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bleuSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, color: AppColors.bleu, size: 16),
          SizedBox(width: 4),
          Text(
            'CITOYEN',
            style: TextStyle(
              color: AppColors.bleu,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
