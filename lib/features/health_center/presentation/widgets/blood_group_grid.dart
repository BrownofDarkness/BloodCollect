import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import 'availability_level_style.dart';

/// Grille 4 × 2 du statut déclaré de chaque groupe sanguin, avec sa légende.
/// Les quantités ne sont jamais affichées.
class BloodGroupGrid extends StatelessWidget {
  const BloodGroupGrid({super.key, required this.availabilities});

  final List<BloodAvailability> availabilities;

  static const _columns = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < availabilities.length; i += _columns) ...[
          if (i > 0) const SizedBox(height: 6),
          Row(
            children: [
              for (var j = i; j < i + _columns; j++) ...[
                if (j > i) const SizedBox(width: 6),
                Expanded(
                  child: j < availabilities.length
                      ? _GroupTile(availability: availabilities[j])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final level in AvailabilityLevel.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(level.icon, color: level.color, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    level.shortLabel,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.availability});

  final BloodAvailability availability;

  @override
  Widget build(BuildContext context) {
    final level = availability.level;

    return Semantics(
      label: '${availability.bloodType.label} : ${level.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: level.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                availability.bloodType.label,
                style: TextStyle(
                  color: level.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Icon(level.icon, color: level.color, size: 14),
          ],
        ),
      ),
    );
  }
}
