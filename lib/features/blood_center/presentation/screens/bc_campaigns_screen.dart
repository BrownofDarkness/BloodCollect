import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../domain/blood_center_stats.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_shared_widgets.dart';
import '../widgets/bc_shimmer.dart';

// Collectes de sang : campagnes planifiées + remplissage.
// Mock via providers ; étape 2 = streams Firestore.
class BcCampaignsScreen extends ConsumerStatefulWidget {
  const BcCampaignsScreen({super.key});

  @override
  ConsumerState<BcCampaignsScreen> createState() =>
      _BcCampaignsScreenState();
}

class _BcCampaignsScreenState extends ConsumerState<BcCampaignsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(bcCampaignsProvider);
    final loading = campaignsAsync.isLoading;
    final Object? error =
        campaignsAsync.hasError ? campaignsAsync.error : null;
    final campaigns = campaignsAsync.asData?.value ?? const [];
    // Inscrits par collecte : 0 tant que le décompte n'est pas chargé.
    final registeredCounts =
        ref.watch(bcCampaignRegisteredCountsProvider).asData?.value ??
            const <String, int>{};
    final now = DateTime.now();
    final upcoming = upcomingCampaigns(campaigns, now);
    final active = activeCampaigns(campaigns);
    final terminated = terminatedCampaigns(campaigns);

    final shown = switch (_tab) {
      1 => active,
      2 => terminated,
      _ => upcoming,
    };
    final empty = switch (_tab) {
      1 => (
          Icons.play_circle_outlined,
          'Aucune collecte en cours',
          'Les collectes démarrées apparaîtront ici.',
        ),
      2 => (
          Icons.event_available_outlined,
          'Aucune collecte terminée',
          'Les collectes clôturées apparaîtront ici.',
        ),
      _ => (
          Icons.calendar_today_outlined,
          'Aucune collecte à venir',
          'Créez votre première collecte pour mobiliser des donneurs.',
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.rouge,
          onRefresh: () => refreshBcData(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.rouge,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'CENTRE DE TRANSFUSION',
                          style: TextStyle(
                            color: AppColors.rouge,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/bc/campaigns/new'),
                    icon: const Icon(Icons.add_outlined, size: 20),
                    label: const Text(
                      'Créer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Collectes de sang',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Campagnes visibles par les citoyens des communes ciblées',
                style: TextStyle(color: AppColors.gris, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.ligne.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _Tab(
                      label: 'À venir · ${upcoming.length}',
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    _Tab(
                      label: 'En cours',
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                    _Tab(
                      label: 'Terminées',
                      selected: _tab == 2,
                      onTap: () => setState(() => _tab = 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BcErrorState(
                    message: '$error',
                    onRetry: () => refreshBcData(ref),
                  ),
                ),
              if (error == null)
                if (loading)
                  const ListShimmer(count: 2)
              else if (shown.isEmpty)
                BcEmptyState(
                  icon: empty.$1,
                  title: empty.$2,
                  message: empty.$3,
                  actionLabel:
                      _tab == 0 ? 'Créer une collecte' : null,
                  onAction: _tab == 0
                      ? () => context.go('/bc/campaigns/new')
                      : null,
                )
              else
                for (final campaign in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: campaign.status == CampaignStatus.draft
                        ? _DraftCard(
                            campaign: campaign,
                            onResume: () => context.go(
                              '/bc/campaigns/${campaign.id}',
                            ),
                          )
                        : _CampaignCard(
                            campaign: campaign,
                            registeredCount:
                                registeredCounts[campaign.id] ?? 0,
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

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.encre : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.encre,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.registeredCount,
  });

  final Campaign campaign;

  /// Donneurs inscrits à la collecte (inscriptions actives).
  final int registeredCount;

  @override
  Widget build(BuildContext context) {
    final progress = campaign.targetUnits <= 0
        ? 0.0
        : (registeredCount / campaign.targetUnits).clamp(0.0, 1.0);
    final allGroups =
        campaign.targetBloodTypes.length >= BloodType.values.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(status: campaign.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                color: AppColors.gris,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  campaign.locationName,
                  style: const TextStyle(
                    color: AppColors.gris,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.gris,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formatCampaignRange(
                    campaign.startDate,
                    campaign.endDate,
                  ),
                  style: const TextStyle(
                    color: AppColors.gris,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (allGroups)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.rougeLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Tous groupes',
                style: TextStyle(
                  color: AppColors.rouge,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in campaign.targetBloodTypes)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.label,
                      style: const TextStyle(
                        color: AppColors.rouge,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Donneurs inscrits',
                  style: TextStyle(color: AppColors.gris, fontSize: 14),
                ),
              ),
              Text(
                '$registeredCount / ${campaign.targetUnits}',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.ligne.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.rouge,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(
                    '/bc/campaigns/${campaign.id}',
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.encre,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.ligne),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Notifications push automatiques à l’étape Blaze '
                        '(Cloud Functions).',
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.campaign_outlined,
                    size: 18,
                  ),
                  label: const Text('Notifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.encre,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.ligne),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.campaign, required this.onResume});

  final Campaign campaign;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Brouillon · date à confirmer',
                  style: TextStyle(color: AppColors.gris, fontSize: 14),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onResume,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.encre,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.ligne),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Reprendre'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      CampaignStatus.published => (
          'Publiée',
          AppColors.disponible,
          const Color(0xFFDCFCE7),
        ),
      CampaignStatus.active => (
          'En cours',
          AppColors.bleu,
          AppColors.bleuLight,
        ),
      CampaignStatus.draft => (
          'Brouillon',
          AppColors.gris,
          const Color(0xFFF1F1EF),
        ),
      CampaignStatus.completed => (
          'Terminée',
          AppColors.gris,
          const Color(0xFFF1F1EF),
        ),
      CampaignStatus.cancelled => (
          'Annulée',
          AppColors.rouge,
          AppColors.rougeLight,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
