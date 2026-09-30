import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';

/// Chip de sélection de groupe sanguin (filtres, formulaires).
/// Sélectionné = fond rouge sang plein, cohérent avec le système visuel.
class BloodTypeChip extends StatelessWidget {
  const BloodTypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final BloodType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.rouge : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.rouge : AppColors.ligne,
          ),
        ),
        child: Text(
          type.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.encre,
          ),
        ),
      ),
    );
  }
}
