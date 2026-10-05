import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import 'availability_level_style.dart';

/// Carte d'un centre de transfusion : statut déclaré du groupe recherché
/// et actions. Les quantités ne sont jamais affichées.
class BloodAvailabilityCard extends StatelessWidget {
  const BloodAvailabilityCard({
    super.key,
    required this.availability,
    required this.onViewCenter,
    required this.onRequest,
    required this.onOtherCenters,
  });

  final BloodAvailability availability;
  final VoidCallback onViewCenter;
  final VoidCallback onRequest;
  final VoidCallback onOtherCenters;

  @override
  Widget build(BuildContext context) {
    final center = availability.center;
    final distance = availability.distanceKm;
    final place = distance == null
        ? center.commune
        : '${center.commune} · ${Formatters.distanceKm(distance)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.indisponibleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.rouge,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                availability.bloodType.label,
                style: const TextStyle(
                  color: AppColors.rouge,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Wrap : la date passe à la ligne si la place manque.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                _StatusPill(level: availability.level),
                Text(
                  Formatters.updatedAt(availability.updatedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.gris, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewCenter,
                  style: _outlinedStyle,
                  child: const _ButtonLabel('Voir le centre'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: availability.canRequest
                    ? ElevatedButton(
                        onPressed: onRequest,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: _buttonTextStyle,
                        ),
                        child: const _ButtonLabel('Demander'),
                      )
                    : OutlinedButton.icon(
                        onPressed: onOtherCenters,
                        style: _outlinedStyle,
                        icon: const Icon(Icons.turn_right, size: 18),
                        label: const _ButtonLabel('Autres centres'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _buttonTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static final _outlinedStyle = OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.encre,
    minimumSize: const Size(0, 48),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    side: const BorderSide(color: AppColors.ligne),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: _buttonTextStyle,
  );
}

// Réduit le libellé plutôt que de le tronquer sur les petits écrans.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.level});

  final AvailabilityLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: level.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, color: level.color, size: 12),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              level.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: level.color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
