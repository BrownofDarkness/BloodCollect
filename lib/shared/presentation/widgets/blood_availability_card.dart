import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../domain/entities/blood_availability.dart';
import 'availability_level_style.dart';

/// Carte d'un centre de transfusion : statut déclaré du groupe recherché,
/// bouton « Voir le centre » et une action propre à l'espace ([action] :
/// demander pour un centre de santé, appeler pour un citoyen). Les
/// quantités ne sont jamais affichées.
class BloodAvailabilityCard extends StatelessWidget {
  const BloodAvailabilityCard({
    super.key,
    required this.availability,
    required this.onViewCenter,
    required this.action,
  });

  final BloodAvailability availability;
  final VoidCallback onViewCenter;

  /// Second bouton, à construire avec [AvailabilityActionButton].
  final Widget action;

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
                child: AvailabilityActionButton(
                  label: 'Voir le centre',
                  onPressed: onViewCenter,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: action),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action d'une [BloodAvailabilityCard] : contour par défaut,
/// plein rouge avec [filled] pour l'action principale.
class AvailabilityActionButton extends StatelessWidget {
  const AvailabilityActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  static const _textStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    // Réduit le libellé plutôt que de le tronquer sur les petits écrans.
    final text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, maxLines: 1),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    if (filled) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: shape,
          textStyle: _textStyle,
        ),
        child: text,
      );
    }
    final style = OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.encre,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: const BorderSide(color: AppColors.ligne),
      shape: shape,
      textStyle: _textStyle,
    );
    final icon = this.icon;
    return icon == null
        ? OutlinedButton(onPressed: onPressed, style: style, child: text)
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 18),
            label: text,
          );
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
