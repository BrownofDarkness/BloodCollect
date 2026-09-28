import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import 'blood_status_widgets.dart';

// Cartes d'un centre de transfusion.
//
// Deux presentations : la carte détaillée de l'onglet « Sang » (statut de
// disponibilité et actions) et la ligne compacte de l'onglet « Donner »
// (ouverture et distance, orientée vers la fiche du centre).

/// Carte d'un centre dans la liste « Disponibilité du sang ».
class BloodCenterAvailabilityCard extends StatelessWidget {
  const BloodCenterAvailabilityCard({
    super.key,
    required this.entry,
    required this.bloodType,
    required this.onOpen,
    required this.onCall,
  });

  final BloodCenterAvailability entry;

  /// Groupe sanguin filtré : c'est lui qui détermine le statut affiché. Sans
  /// filtre, on retombe sur le meilleur statut du centre.
  final BloodType? bloodType;
  final VoidCallback onOpen;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final center = entry.center;
    final status = bloodType != null
        ? entry.statusOf(bloodType!)
        : _bestStatusOf(entry);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenterGlyph(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${center.commune} $middleDot${formatDistanceKm(entry.distanceKm)}',
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (bloodType != null)
                Text(
                  bloodType!.label,
                  style: const TextStyle(
                    color: AppColors.rouge,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              BloodStatusBadge(status: status),
              const Spacer(),
              Text(
                formatLastUpdateLabel(entry.updatedAt),
                style: const TextStyle(color: AppColors.gris, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CenterActionButton(
                  label: 'Voir le centre',
                  onTap: onOpen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CenterActionButton(
                  label: 'Appeler',
                  icon: Icons.call_outlined,
                  onTap: onCall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sans filtre actif, le centre est résumé par son meilleur statut : un
  /// centre n'est jamais présenté comme indisponible s'il a un groupe en stock.
  BloodAvailabilityStatus _bestStatusOf(BloodCenterAvailability entry) {
    var best = BloodAvailabilityStatus.unavailable;
    for (final status in BloodType.values.map(entry.statusOf)) {
      if (status == BloodAvailabilityStatus.available) {
        return BloodAvailabilityStatus.available;
      }
      if (status == BloodAvailabilityStatus.limited) {
        best = BloodAvailabilityStatus.limited;
      }
    }
    return best;
  }
}

/// Ligne compacte d'un centre, dans « Centres de transfusion à proximité ».
class BloodCenterNearbyTile extends StatelessWidget {
  const BloodCenterNearbyTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final BloodCenterAvailability entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final center = entry.center;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CenterGlyph(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${center.commune} $middleDot${formatDistanceKm(entry.distanceKm)}',
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: AppColors.disponible,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Ouvert $middleDot jusqu\'à ${closingHourFr(center.openingHoursWeekdays)}',
                            style: const TextStyle(
                              color: AppColors.disponible,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gris),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icône carrée rose d'un centre de transfusion.
class CenterGlyph extends StatelessWidget {
  const CenterGlyph({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.local_hospital_outlined,
        color: AppColors.rouge,
        size: size * 0.5,
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  const _CenterActionButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.encre,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.ligne, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: icon == null
          ? Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
    );
  }
}
