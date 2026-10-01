import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/distance_utils.dart';
import '../models/donor_search_candidate.dart';
import 'status_pill.dart';

/// Carte d'un donneur potentiel dans les résultats de recherche.
class DonorCard extends StatelessWidget {
  const DonorCard({
    super.key,
    required this.candidate,
    required this.onContact,
  });

  final DonorSearchCandidate candidate;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.bleuLight,
                  child: Text(
                    candidate.bloodType.label,
                    style: const TextStyle(
                      color: AppColors.bleu,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donneur potentiel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${candidate.commune} $middleDot${formatDistanceKm(candidate.distanceKm)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (candidate.matchStatus == DonorMatchStatus.pending) ...[
              const Divider(height: 24, color: AppColors.ligne),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Demande envoyée',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const MatchStatusPill(status: DonorMatchStatus.pending),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onContact,
                  icon: const Icon(Icons.near_me_outlined, size: 18),
                  label: const Text('Contacter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bleu,
                    side: const BorderSide(color: AppColors.bleu),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
