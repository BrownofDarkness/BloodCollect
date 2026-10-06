import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/donor_candidate.dart';
import '../../../../shared/presentation/widgets/donor_match_status_style.dart';

/// Donneur potentiel anonymisé d'un résultat de recherche. Propose de le
/// contacter, ou rappelle l'état de la demande déjà envoyée ([sentStatus]).
class DonorResultCard extends StatelessWidget {
  const DonorResultCard({
    super.key,
    required this.candidate,
    required this.sentStatus,
    required this.onContact,
  });

  final DonorCandidate candidate;

  /// Statut de la demande en cours avec ce donneur ; null s'il peut être
  /// contacté (jamais sollicité, ou demande expirée).
  final DonorMatchStatus? sentStatus;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final distance = candidate.distanceKm;
    final place = [
      if (candidate.commune.isNotEmpty) candidate.commune,
      if (distance != null) Formatters.distanceKm(distance),
    ].join(' · ');
    final status = sentStatus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.bleuSurface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  candidate.bloodType.label,
                  style: const TextStyle(
                    color: AppColors.bleu,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donneur potentiel',
                      style: TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (place.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.gris,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.gris,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status == null)
            OutlinedButton.icon(
              onPressed: onContact,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bleu,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.bleu),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.near_me_outlined, size: 18),
              label: const Text('Contacter'),
            )
          else ...[
            const Divider(height: 1, thickness: 1, color: AppColors.ligne),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Text(
                    'Demande envoyée',
                    style: TextStyle(color: AppColors.gris, fontSize: 14),
                  ),
                  _SentStatusPill(status: status),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SentStatusPill extends StatelessWidget {
  const _SentStatusPill({required this.status});

  final DonorMatchStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status == DonorMatchStatus.pending
                  ? 'En attente de réponse'
                  : status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status.color,
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
