import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/campaign.dart';

/// Résumé d'une collecte de sang : lieu, créneau et groupes recherchés.
/// Cliquable en entier avec [onTap], ou pourvue d'actions avec [footer].
class CampaignSummaryCard extends StatelessWidget {
  const CampaignSummaryCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.footer,
  });

  final Campaign campaign;
  final VoidCallback? onTap;

  /// Actions affichées sous le résumé (participer, détails…).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final commune = campaign.commune;
    final place = [
      if (campaign.locationName.isNotEmpty) campaign.locationName,
      if (commune != null && commune.isNotEmpty) commune,
    ].join(', ');
    final footer = this.footer;
    final types = campaign.targetBloodTypes;
    // Aucun groupe ciblé, ou tous : la collecte est ouverte à tous.
    final groupLabels = types.isEmpty || types.length == BloodType.values.length
        ? const ['Tous groupes']
        : [for (final type in types) type.label];

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.ligne),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.roseLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_outlined,
                      color: AppColors.rouge,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COLLECTE DE SANG',
                          style: TextStyle(
                            color: AppColors.rouge,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          campaign.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.encre,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (place.isNotEmpty) ...[
                _InfoLine(icon: Icons.location_on_outlined, text: place),
                const SizedBox(height: 6),
              ],
              _InfoLine(
                icon: Icons.calendar_today_outlined,
                text: Formatters.schedule(
                  campaign.startDate,
                  campaign.endDate,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Groupes recherchés',
                    style: TextStyle(color: AppColors.gris, fontSize: 13),
                  ),
                  for (final label in groupLabels)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.roseLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.rouge,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.slate, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
