import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/blood_availability.dart';

// Représentation des groupes sanguins et des statuts de disponibilité.
//
// Règle du design system : un statut n'est jamais porté par la couleur seule.
// Chaque pastille porte une icône ET un libellé.

/// Pastille ronde d'un groupe sanguin, sélectionnable (filtre) ou non.
class BloodTypeChip extends StatelessWidget {
  const BloodTypeChip({
    super.key,
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
      label: 'Groupe sanguin ${bloodType.label}',
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.rouge : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.rouge : AppColors.ligne,
              width: 1.5,
            ),
          ),
          child: Text(
            bloodType.label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Rangée des 8 groupes sanguins, dans l'ordre du design system.
class BloodTypeFilterRow extends StatelessWidget {
  const BloodTypeFilterRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final BloodType? selected;
  final ValueChanged<BloodType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: BloodType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bloodType = BloodType.values[index];
          return BloodTypeChip(
            bloodType: bloodType,
            selected: bloodType == selected,
            onTap: () => onSelected(bloodType),
          );
        },
      ),
    );
  }
}

/// Libellé et couleurs d'un statut de disponibilité de sang.
class BloodStatusStyle {
  const BloodStatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData icon;

  factory BloodStatusStyle.of(BloodAvailabilityStatus status) =>
      switch (status) {
        BloodAvailabilityStatus.available => const BloodStatusStyle(
          label: 'Disponible',
          foreground: AppColors.disponible,
          background: AppColors.disponibleLight,
          icon: Icons.circle,
        ),
        BloodAvailabilityStatus.limited => const BloodStatusStyle(
          label: 'Disponibilité limitée',
          foreground: AppColors.limite,
          background: AppColors.limiteLight,
          icon: Icons.hourglass_bottom_rounded,
        ),
        BloodAvailabilityStatus.unavailable => const BloodStatusStyle(
          label: 'Indisponible',
          foreground: AppColors.indisponible,
          background: AppColors.indisponibleLight,
          icon: Icons.circle_outlined,
        ),
      };
}

/// Pastille de statut : icône + libellé sur fond teinté (écran « Sang »).
class BloodStatusBadge extends StatelessWidget {
  const BloodStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final BloodAvailabilityStatus status;

  /// Version courte pour les lignes serrées : « Limitée » au lieu de
  /// « Disponibilité limitée ».
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = BloodStatusStyle.of(status);
    final label = compact
        ? (status == BloodAvailabilityStatus.limited ? 'Limitée' : style.label)
        : style.label;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 9 : 11, color: style.foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: style.foreground,
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Case carrée d'un groupe dans la grille des disponibilités déclarées
/// (fiche centre). L'icône porte le statut, le libellé le confirme.
class BloodAvailabilityTile extends StatelessWidget {
  const BloodAvailabilityTile({
    super.key,
    required this.bloodType,
    required this.status,
  });

  final BloodType bloodType;
  final BloodAvailabilityStatus status;

  @override
  Widget build(BuildContext context) {
    final style = BloodStatusStyle.of(status);

    return Semantics(
      label: '${bloodType.label} : ${style.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bloodType.label,
              style: TextStyle(
                color: style.foreground,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Icon(style.icon, size: 11, color: style.foreground),
          ],
        ),
      ),
    );
  }
}

/// Grille des 8 groupes d'un centre, avec la légende des trois statuts.
class BloodAvailabilityGrid extends StatelessWidget {
  const BloodAvailabilityGrid({super.key, required this.availability});

  final BloodAvailability availability;

  @override
  Widget build(BuildContext context) {
    const columns = 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.9,
          children: [
            for (final bloodType in BloodType.values)
              BloodAvailabilityTile(
                bloodType: bloodType,
                status: availability.statusOf(bloodType),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendItem(status: BloodAvailabilityStatus.available),
            _LegendItem(status: BloodAvailabilityStatus.limited),
            _LegendItem(status: BloodAvailabilityStatus.unavailable),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.status});

  final BloodAvailabilityStatus status;

  @override
  Widget build(BuildContext context) {
    final style = BloodStatusStyle.of(status);
    final label = status == BloodAvailabilityStatus.limited
        ? 'Limitée'
        : style.label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(style.icon, size: 11, color: style.foreground),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: style.foreground,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
