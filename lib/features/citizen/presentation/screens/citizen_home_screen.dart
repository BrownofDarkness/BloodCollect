import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/presentation/widgets/loading_skeleton.dart';
import '../providers/donor_providers.dart';

/// Écran 3 — Accueil citoyen. Dashboard en lecture seule : profil (AppUser),
/// 3 cartes d'action, et les collectes à proximité (état vide géré).
class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Demande la plus recente en attente : c'est celle que le
    // citoyen doit traiter en priorite, et celle que le point
    // rouge signale.
    final pendingAsync = ref.watch(pendingIncomingRequestProvider);

    final profileAsync = ref.watch(citizenAccountProvider);
    final campaignsAsync = ref.watch(upcomingCampaignsProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(citizenAccountProvider);
            ref.invalidate(upcomingCampaignsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bleuSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 14, color: AppColors.bleu),
                        SizedBox(width: 6),
                        Text(
                          'CITOYEN',
                          style: TextStyle(
                            color: AppColors.bleu,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _NotificationButton(
                    // La pastille n'apparait que s'il y a reellement une
                    // demande a traiter, et le tap ouvre cette demande.
                    pendingCount: pendingAsync.value == null ? 0 : 1,
                    onTap: () {
                      final pending = pendingAsync.value;
                      if (pending != null) {
                        context.push(
                          '${AppRoutes.citizenIncoming}/${pending.id}',
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              profileAsync.when(
                loading: () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 160, height: 28),
                    SizedBox(height: 12),
                    SkeletonBox(height: 64),
                  ],
                ),
                error: (_, _) =>
                    const Text('Profil indisponible pour le moment.'),
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bonjour,',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.ligne),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mon groupe',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  profile.bloodType?.label ?? 'Non renseigné',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.rouge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: AppColors.ligne,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ma commune',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  // Commune et ville : « Treichville,
                                  // Abidjan », pour situer le donneur sans
                                  // avoir à ouvrir une autre écran.
                                  [
                                    profile.commune,
                                    profile.city,
                                  ].whereType<String>().join(', '),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Que souhaitez-vous faire ?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                badgeLabel: 'PERSONNE',
                badgeColor: AppColors.bleu,
                badgeBg: AppColors.bleuLight,
                icon: Icons.search,
                title: 'Chercher un donneur',
                subtitle: 'Trouver un donneur potentiel par ville et commune.',
                onTap: () => context.go(AppRoutes.citizenDonors),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                badgeLabel: 'SANG · CENTRES AGRÉÉS',
                badgeColor: AppColors.rouge,
                badgeBg: AppColors.rougeLight,
                icon: Icons.water_drop_outlined,
                title: 'Voir la disponibilité de sang',
                subtitle:
                    'Consulter les disponibilités déclarées par les centres de transfusion.',
                onTap: () => context.go(AppRoutes.citizenBlood),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                badgeLabel: 'DON VOLONTAIRE',
                badgeColor: Colors.white,
                badgeBg: AppColors.rouge,
                icon: Icons.favorite,
                title: 'Je veux donner mon sang',
                subtitle:
                    'Centres de transfusion et collectes près de chez vous.',
                onTap: () => context.go(AppRoutes.citizenDonate),
                filled: true,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Près de chez vous',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Tout voir')),
                ],
              ),
              const SizedBox(height: 8),
              campaignsAsync.when(
                loading: () => const Column(
                  children: [
                    SkeletonBox(height: 88),
                    SizedBox(height: 8),
                    SkeletonBox(height: 88),
                  ],
                ),
                error: (_, _) =>
                    const Text('Impossible de charger les collectes.'),
                data: (campaigns) {
                  if (campaigns.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.ligne),
                      ),
                      child: const Center(
                        child: Text(
                          'Aucune collecte prévue près de chez vous pour le moment.',
                          style: TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: campaigns
                        .map((c) => _CampaignTile(campaign: c))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.filled = false,
  });

  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.encre;
    final subtitleColor = filled ? Colors.white70 : AppColors.textSecondary;

    return Material(
      color: filled ? AppColors.rouge : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: filled ? null : Border.all(color: AppColors.ligne),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: badgeColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignTile extends StatelessWidget {
  const _CampaignTile({required this.campaign});
  final Campaign campaign;

  String _dateLabel() {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final d = campaign.startDate;
    final jour = jours[d.weekday - 1];
    final h1 =
        '${campaign.startDate.hour}h${campaign.startDate.minute.toString().padLeft(2, '0')}';
    final h2 =
        '${campaign.endDate.hour}h${campaign.endDate.minute.toString().padLeft(2, '0')}';
    return '$jour ${d.day} · $h1 – $h2';
  }

  @override
  Widget build(BuildContext context) {
    final isOpenToAll = campaign.targetBloodTypes.isEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.rougeLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: AppColors.rouge,
              size: 18,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rouge,
                  ),
                ),
                Text(
                  campaign.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.locationName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _dateLabel(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: isOpenToAll
                      ? const [_MiniChip(label: 'Tous groupes')]
                      : campaign.targetBloodTypes
                            .map((t) => _MiniChip(label: t.label))
                            .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.rougeLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.rouge,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bouton de notifications : carré blanc, cloche encre, point rouge quand une
/// demande attend une réponse.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap, this.pendingCount = 0});

  final VoidCallback onTap;

  /// Nombre de demandes en attente. A zero, aucune pastille : une pastille
  /// permanente alors qu'il n'y a rien a traiter apprend au citoyen a
  /// l'ignorer.
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Notifications',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_none,
                    size: 22,
                    color: AppColors.encre,
                  ),
                ),
                if (pendingCount > 0)
                  Positioned(
                    right: 11,
                    top: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.rouge,
                        shape: BoxShape.circle,
                      ),
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
