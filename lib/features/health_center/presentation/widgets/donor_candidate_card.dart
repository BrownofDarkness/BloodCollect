import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/donor_candidate.dart';

/// Donneur potentiel anonymisé, sélectionnable par case à cocher.
/// Code couleur bleu : il s'agit d'une personne, pas de sang disponible.
class DonorCandidateCard extends StatelessWidget {
  const DonorCandidateCard({
    super.key,
    required this.candidate,
    required this.selected,
    required this.onChanged,
  });

  final DonorCandidate candidate;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final distance = candidate.distanceKm;
    final place = [
      if (candidate.commune.isNotEmpty) candidate.commune,
      if (distance != null) Formatters.distanceKm(distance),
    ].join(' · ');

    return Semantics(
      checked: selected,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? AppColors.bleu : AppColors.ligne,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!selected),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.bleuLight,
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
                Checkbox(
                  value: selected,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: AppColors.bleu,
                  side: const BorderSide(color: AppColors.ligne, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
