import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../domain/usecases/campaign_registration_usecases.dart';
import '../../domain/usecases/get_donation_dashboard_usecase.dart';
import '../providers/citizen_providers.dart';
import '../widgets/blood_center_card.dart';
import '../widgets/campaign_card.dart';
import '../widgets/citizen_scaffold_parts.dart';

/// Onglet « Donner » — don volontaire.
///
/// Rassemble ce dont un citoyen a besoin pour se rendre dans un centre ou à une
/// collecte : son profil donneur, les collectes à venir auxquelles il peut
/// s'inscrire, et les centres agréés les plus proches.
class DonateScreen extends ConsumerWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(donationDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: dashboardAsync.when(
          loading: () => const _DonateSkeleton(),
          error: (error, _) => _DonateError(
            onRetry: () => ref.invalidate(donationDashboardProvider),
          ),
          data: (dashboard) => _DonateBody(dashboard: dashboard),
        ),
      ),
    );
  }
}

class _DonateBody extends ConsumerWidget {
  const _DonateBody({required this.dashboard});

  final DonationDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citizen = dashboard.citizen;

    return RefreshIndicator(
      color: AppColors.rouge,
      onRefresh: () async => ref.invalidate(donationDashboardProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          CitizenScreenHeader(
            contextLabel: 'Don volontaire',
            contextIcon: Icons.favorite_outline,
            tone: ContextTone.blood,
            onBack: () => context.go(AppRoutes.citizenHome),
          ),
          const SizedBox(height: 18),
          const CitizenPageTitle('Je veux donner mon sang'),
          const SizedBox(height: 22),

          _DonorProfileCard(citizen: citizen),
          const SizedBox(height: 26),

          const CitizenSectionTitle('Collectes à venir'),
          const SizedBox(height: 14),
          if (dashboard.campaigns.isEmpty)
            const _NoCampaign()
          else
            for (final entry in dashboard.campaigns) ...[
              CampaignCard(
                entry: entry,
                onJoin: () => _join(context, ref, entry.campaign.id),
                onCancel: entry.registration == null
                    ? null
                    : () => _cancel(context, ref, entry.registration!.id),
                onOpenDetails: () =>
                    _showCampaignDetails(context, entry.campaign),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 14),

          const CitizenSectionTitle('Centres de transfusion à proximité'),
          const SizedBox(height: 14),
          if (dashboard.nearbyCenters.isEmpty)
            const _NoCenter()
          else
            for (final entry in dashboard.nearbyCenters) ...[
              BloodCenterNearbyTile(
                entry: entry,
                onTap: () =>
                    context.go('${AppRoutes.citizenBlood}/${entry.center.id}'),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 6),

          const CitizenInfoBanner(
            title: "L'éligibilité est vérifiée sur place.",
            message:
                "Le personnel du centre s'assure que vous pouvez donner avant "
                'tout prélèvement.',
          ),
        ],
      ),
    );
  }

  Future<void> _join(
    BuildContext context,
    WidgetRef ref,
    String campaignId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(joinCampaignUseCaseProvider)(campaignId);
      ref.invalidate(donationDashboardProvider);
      ref.invalidate(citizenProfileProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Participation enregistrée')),
      );
    } on CampaignRegistrationNotJoinable catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    String registrationId,
  ) async {
    await ref.read(cancelRegistrationUseCaseProvider)(registrationId);
    ref.invalidate(donationDashboardProvider);
    ref.invalidate(citizenProfileProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Participation annulée')));
  }
}

/// Rappel du profil donneur : groupe sanguin et commune, modifiables.
class _DonorProfileCard extends StatelessWidget {
  const _DonorProfileCard({required this.citizen});

  final AppUser citizen;

  @override
  Widget build(BuildContext context) {
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
            children: [
              const Expanded(
                child: Text(
                  'Mon profil donneur',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    color: AppColors.bleu,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.bleu,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DonorFact(
                  label: 'Groupe',
                  value: citizen.bloodType?.label ?? 'Non renseigné',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DonorFact(
                  label: 'Commune',
                  value: citizen.commune ?? 'Non renseignée',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonorFact extends StatelessWidget {
  const _DonorFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.encart,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gris, fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

void _showCampaignDetails(BuildContext context, Campaign campaign) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.ivoire,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COLLECTE DE SANG',
            style: TextStyle(
              color: AppColors.rouge,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            campaign.title,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            campaign.description,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          _DetailLine(label: 'Lieu', value: campaign.locationName),
          _DetailLine(
            label: 'Quand',
            value: formatCampaignPeriodFr(campaign.startDate, campaign.endDate),
          ),
          _DetailLine(label: 'Objectif', value: '${campaign.targetUnits} dons'),
        ],
      ),
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.gris, fontSize: 13.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCampaign extends StatelessWidget {
  const _NoCampaign();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Aucune collecte annoncée dans votre commune pour le moment.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.slate, fontSize: 14, height: 1.4),
      ),
    );
  }
}

class _NoCenter extends StatelessWidget {
  const _NoCenter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Aucun centre de transfusion agréé dans votre zone.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.slate, fontSize: 14, height: 1.4),
      ),
    );
  }
}

class _DonateSkeleton extends StatelessWidget {
  const _DonateSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const _SkeletonBar(width: 150, height: 28),
        const SizedBox(height: 22),
        const _SkeletonBar(width: 280, height: 16),
        const SizedBox(height: 26),
        const _SkeletonBar(width: 180, height: 22),
        const SizedBox(height: 14),
        const _SkeletonBar(height: 200),
        const SizedBox(height: 12),
        const _SkeletonBar(height: 200),
      ],
    );
  }
}

class _DonateError extends StatelessWidget {
  const _DonateError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 36, color: AppColors.gris),
            const SizedBox(height: 12),
            const Text(
              "Les collectes n'ont pas pu être chargées.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({this.width, required this.height});

  /// `null` = barre pleine largeur.
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
