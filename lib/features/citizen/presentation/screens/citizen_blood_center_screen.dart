import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/widgets/blood_center_sheet.dart';
import '../providers/citizen_home_providers.dart';
import '../widgets/campaign_summary_card.dart';

// Onglet « Sang » — Fiche centre de transfusion.
// Fiche vue par un citoyen : en plus des coordonnées et des disponibilités
// déclarées, elle explique le déroulé d'un don et annonce les collectes du
// centre. Le citoyen ne peut pas y demander de sang.
class CitizenBloodCenterScreen extends StatelessWidget {
  const CitizenBloodCenterScreen({super.key, required this.centerId});

  final String centerId;

  @override
  Widget build(BuildContext context) {
    return BloodCenterSheet(
      centerId: centerId,
      onBack: () => context.go(AppRoutes.citizenBlood),
      sectionsBuilder: (context, center) => [
        _DonationSection(bloodCenterId: center.id),
      ],
      primaryActionBuilder: (context, center) => BloodCenterPrimaryButton(
        label: 'Je souhaite donner mon sang',
        icon: Icons.favorite_outline,
        onPressed: () => context.go(AppRoutes.citizenDonate),
      ),
    );
  }
}

/// Déroulé d'un don en centre agréé, suivi des collectes ouvertes organisées
/// par le centre s'il y en a.
class _DonationSection extends ConsumerWidget {
  const _DonationSection({required this.bloodCenterId});

  final String bloodCenterId;

  static const _steps = [
    'Accueil et identification',
    'Vérification de l’éligibilité',
    'Procédures médicales',
    'Don',
    'Enregistrement du don',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns =
        ref.watch(centerCampaignsProvider(bloodCenterId)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment se passe votre don',
          style: BloodCenterSheet.sectionStyle,
        ),
        const SizedBox(height: 12),
        for (final (index, step) in _steps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.roseLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.rouge,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: AppColors.encre,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (final campaign in campaigns) ...[
          const SizedBox(height: 10),
          CampaignSummaryCard(
            campaign: campaign,
            onTap: () => context.go(AppRoutes.citizenDonate),
          ),
        ],
      ],
    );
  }
}
