import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Badge beige « CENTRE DE SANTÉ » affiché en tête des écrans de l'espace.
class HcRoleBadge extends StatelessWidget {
  const HcRoleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ligne.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_outlined, color: AppColors.encre, size: 16),
          SizedBox(width: 4),
          Text(
            'CENTRE DE SANTÉ',
            style: TextStyle(
              color: AppColors.encre,
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
