import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';

/// Chip de sélection de groupe sanguin (filtres, formulaires).
/// La couleur de sélection est fournie par l'appelant : elle suit le flux de
/// l'écran, rouge pour le sang, bleu pour les personnes.
class BloodTypeChip extends StatelessWidget {
  const BloodTypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  final BloodType type;
  final bool selected;
  final VoidCallback onTap;

  /// Couleur du groupe sélectionné. L'écran qui cherche un donneur est un
  /// parcours personnes, donc bleu ; l'écran de disponibilité du sang est un
  /// parcours sang, donc rouge.
  final Color accent;

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
          color: selected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? accent : AppColors.ligne),
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
