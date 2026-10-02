import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';

// Champs du formulaire « Demande de sang ».

/// Grille 4 × 2 de choix du groupe sanguin.
class BloodTypeGridSelector extends StatelessWidget {
  const BloodTypeGridSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final BloodType value;
  final ValueChanged<BloodType> onChanged;

  static const _columns = 4;

  @override
  Widget build(BuildContext context) {
    const types = BloodType.displayOrder;

    return Column(
      children: [
        for (var i = 0; i < types.length; i += _columns) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var j = i; j < i + _columns; j++) ...[
                if (j > i) const SizedBox(width: 8),
                Expanded(
                  child: _BloodTypeTile(
                    bloodType: types[j],
                    selected: types[j] == value,
                    onTap: () => onChanged(types[j]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _BloodTypeTile extends StatelessWidget {
  const _BloodTypeTile({
    required this.bloodType,
    required this.selected,
    required this.onTap,
  });

  final BloodType bloodType;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.rouge : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.rouge : AppColors.ligne,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  bloodType.label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compteur de poches borné entre [min] et [max].
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    required this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove,
            tooltip: 'Retirer une poche',
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Text(
              '$value poche${value > 1 ? 's' : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: 'Ajouter une poche',
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.ivoire,
        foregroundColor: AppColors.encre,
        disabledForegroundColor: AppColors.ligne,
        fixedSize: const Size(40, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Sélecteur segmenté du niveau d'urgence.
class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Priority value;
  final ValueChanged<Priority> onChanged;

  static String _label(Priority priority) => switch (priority) {
        Priority.normal => 'Normale',
        Priority.elevated => 'Élevée',
        Priority.vital => 'Vitale',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ligne.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final priority in Priority.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: priority == value,
                child: Material(
                  color: priority == value
                      ? AppColors.rouge
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onChanged(priority),
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _label(priority),
                            style: TextStyle(
                              color: priority == value
                                  ? Colors.white
                                  : AppColors.slate,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
