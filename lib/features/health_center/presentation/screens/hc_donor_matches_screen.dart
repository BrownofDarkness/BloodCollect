import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../providers/hc_providers.dart';
import '../../../../shared/presentation/widgets/donor_match_card.dart';
import '../../../../shared/presentation/widgets/donor_match_status_style.dart';
import '../widgets/hc_role_badge.dart';

// Onglet « Profil » — Historique des mises en relation.
// Sollicitations envoyées aux donneurs par le centre connecté et leurs
// réponses, en temps réel. Les acceptations sont listées en premier.
class HcDonorMatchesScreen extends ConsumerWidget {
  const HcDonorMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(sentDonorMatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(
                    onPressed: () => context.go(AppRoutes.hcProfile),
                  ),
                  const Spacer(),
                  const HcRoleBadge(),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Mises en relation',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Réponses des donneurs que vous avez sollicités.',
                style: TextStyle(color: AppColors.gris, fontSize: 15),
              ),
              const SizedBox(height: 16),
              matchesAsync.when(
                // Une réponse reçue ne doit pas faire clignoter la liste.
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.bleu),
                  ),
                ),
                error: (_, _) => _Message(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chargement impossible',
                  body: 'Vérifiez votre connexion puis réessayez.',
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(sentDonorMatchesProvider),
                ),
                data: (matches) => matches.isEmpty
                    ? _Message(
                        icon: Icons.person_search_outlined,
                        title: 'Aucune mise en relation',
                        body: 'Les donneurs que vous sollicitez et leurs '
                            'réponses apparaîtront ici.',
                        actionLabel: 'Chercher un donneur',
                        onAction: () => context.go(AppRoutes.hcDonors),
                      )
                    : _MatchList(matches: matches),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches});

  final List<DonorMatchRequest> matches;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int count(DonorMatchStatus status) =>
        matches.where((m) => m.statusAt(now) == status).length;
    final accepted = count(DonorMatchStatus.accepted);
    final pending = count(DonorMatchStatus.pending);
    // Réponses positives d'abord, puis de la plus récente à la plus ancienne.
    final sorted = [...matches]..sort((a, b) {
        final byStatus = a
            .statusAt(now)
            .displayRank
            .compareTo(b.statusAt(now).displayRank);
        return byStatus != 0 ? byStatus : b.createdAt.compareTo(a.createdAt);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$accepted acceptée${accepted > 1 ? 's' : ''} · '
          '$pending en attente',
          style: const TextStyle(
            color: AppColors.encre,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (final match in sorted) ...[
          DonorMatchCard(match: match, now: now),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gris, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gris,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.encre,
              minimumSize: const Size(0, 44),
              side: const BorderSide(color: AppColors.ligne),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
