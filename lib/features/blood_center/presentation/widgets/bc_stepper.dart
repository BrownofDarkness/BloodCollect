import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

// Stepper : pastille beige aux extrémités (– / +), valeur centrée.
// Utilisé : quantité lot, objectif donneurs, quantité accordée.
class BcStepper extends StatelessWidget {
  const BcStepper({
    super.key,
    required this.display,
    required this.onMinus,
    required this.onPlus,
    this.minusEnabled = true,
    this.plusEnabled = true,
  });

  final String display;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final bool minusEnabled;
  final bool plusEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: _EndButton(
              icon: Icons.remove_outlined,
              enabled: minusEnabled,
              onTap: onMinus,
            ),
          ),
          Expanded(
            child: Text(
              display,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: _EndButton(
              icon: Icons.add_outlined,
              enabled: plusEnabled,
              onTap: onPlus,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndButton extends StatelessWidget {
  const _EndButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.ligne.withValues(alpha: 0.7)
              : AppColors.ligne.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.encre : AppColors.gris,
          size: 20,
        ),
      ),
    );
  }
}
