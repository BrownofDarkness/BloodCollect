import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/presentation/providers/donor_search_providers.dart';
import '../../../../shared/presentation/widgets/home_action_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/citizen_home_providers.dart';
import '../widgets/campaign_summary_card.dart';
import '../widgets/citizen_role_badge.dart';

// Onglet « Accueil » — Accueil citoyen.
// Identité de donneur (groupe, commune), trois actions (bleu = personnes,
// rouge = sang) et les collectes ouvertes près de chez le citoyen.
class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).value;
    final name = user?.fullName ?? '';

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CitizenRoleBadge(),
                  // Cloche de notifications : masquée en v1. Les demandes de don
                  // en attente restent signalées par la carte ci-dessous.
                ],
              ),
              const Text(
                'Bonjour,',
                style: TextStyle(color: AppColors.gris, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                name.isEmpty ? 'Bienvenue' : name,
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              _IdentityCard(user: user),
              const _ReceivedRequestsCard(),
              const _SentRequestsCard(),
              const SizedBox(height: 20),
              const Text('Que souhaitez-vous faire ?', style: _headingStyle),
              const SizedBox(height: 12),
              HomeActionCard(
                overline: 'PERSONNE',
                title: 'Chercher un donneur',
                description: 'Trouver un donneur potentiel par ville et '
                    'commune.',
                icon: Icons.search,
                onTap: () => context.go(AppRoutes.citizenDonors),
              ),
              const SizedBox(height: 12),
              HomeActionCard(
                style: HomeActionStyle.blood,
                overline: 'SANG · CENTRES AGRÉÉS',
                title: 'Voir la disponibilité de sang',
                description: 'Consulter les disponibilités déclarées par les '
                    'centres de transfusion.',
                icon: Icons.water_drop_outlined,
                onTap: () => context.go(AppRoutes.citizenBlood),
              ),
              const SizedBox(height: 12),
              HomeActionCard(
                style: HomeActionStyle.bloodFilled,
                overline: 'DON VOLONTAIRE',
                title: 'Je veux donner mon sang',
                description: 'Centres de transfusion et collectes près de '
                    'chez vous.',
                icon: Icons.favorite_outline,
                onTap: () => context.go(AppRoutes.citizenDonate),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text('Près de chez vous', style: _headingStyle),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.citizenDonate),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.bleu,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    child: const Text('Tout voir'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _NearbyCampaigns(),
            ],
          ),
        ),
      ),
    );
  }

  static const _headingStyle = TextStyle(
    color: AppColors.encre,
    fontSize: 19,
    fontWeight: FontWeight.w800,
  );
}

/// Demandes de don reçues et restées sans réponse : la seule situation qui
/// exige une action du citoyen, donc mise en avant. Masquée sinon.
class _ReceivedRequestsCard extends ConsumerWidget {
  const _ReceivedRequestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final pending = (ref.watch(incomingDonorRequestsProvider).value ?? const [])
        .where((r) => r.statusAt(now) == DonorMatchStatus.pending)
        .toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    final single = pending.length == 1;
    // La plus récente d'abord : le dépôt les trie ainsi.
    final latest = pending.first;
    final urgency = switch (latest.priority) {
      Priority.normal => 'Urgence normale',
      Priority.elevated => 'Urgence élevée',
      Priority.vital => 'Urgence vitale',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bleu,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.volunteer_activism_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        single
                            ? 'Une demande de don vous attend'
                            : '${pending.length} demandes de don vous '
                                'attendent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        single
                            ? 'Donneur ${latest.bloodType.label} recherché · '
                                '$urgency · reçue '
                                '${Formatters.relative(latest.createdAt, now: now)}'
                            : 'La plus récente : $urgency, reçue '
                                '${Formatters.relative(latest.createdAt, now: now)}',
                        style: const TextStyle(
                          color: AppColors.bleuSurface,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => single
                  ? context.push('${AppRoutes.citizenIncoming}/${latest.id}')
                  : context.go(AppRoutes.citizenMatches),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.bleu,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(single ? 'Répondre' : 'Voir les demandes'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Suivi des demandes envoyées à des donneurs : réponses reçues et demandes
/// encore en attente. Masquée tant que le citoyen n'a sollicité personne.
class _SentRequestsCard extends ConsumerWidget {
  const _SentRequestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sent = ref.watch(sentDonorMatchesProvider).value ?? const [];
    if (sent.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    int count(DonorMatchStatus status) =>
        sent.where((m) => m.statusAt(now) == status).length;
    final accepted = count(DonorMatchStatus.accepted);
    final pending = count(DonorMatchStatus.pending);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: AppColors.bleuSurface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go(AppRoutes.citizenMatches),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_chat_read_outlined,
                  color: AppColors.bleu,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mes demandes envoyées',
                        style: TextStyle(
                          color: AppColors.bleu,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$accepted acceptée${accepted > 1 ? 's' : ''} · '
                        '$pending en attente',
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.bleu),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// « Mon groupe » et « Ma commune », tels que déclarés à l'inscription.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final commune = user?.commune ?? '';
    final city = user?.city ?? '';
    final place = [commune, city].where((part) => part.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mon groupe', style: _labelStyle),
                const SizedBox(height: 2),
                Text(
                  user?.bloodType?.label ?? '—',
                  style: const TextStyle(
                    color: AppColors.rouge,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: VerticalDivider(width: 1, color: AppColors.ligne),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ma commune', style: _labelStyle),
                  const SizedBox(height: 2),
                  Text(
                    place.isEmpty ? 'Non renseignée' : place,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.encre,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(color: AppColors.gris, fontSize: 13);
}

class _NearbyCampaigns extends ConsumerWidget {
  const _NearbyCampaigns();

  static const _maxShown = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(nearbyCampaignsProvider);

    return campaignsAsync.when(
      // Une collecte modifiée ne doit pas faire clignoter l'accueil.
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.rouge),
        ),
      ),
      error: (_, _) => _Notice(
        text: 'Collectes indisponibles. Vérifiez votre connexion.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(openCampaignsProvider),
      ),
      data: (campaigns) => campaigns.isEmpty
          ? const _Notice(
              text: 'Aucune collecte prévue dans votre commune pour le '
                  'moment.',
            )
          : Column(
              children: [
                for (final campaign in campaigns.take(_maxShown)) ...[
                  CampaignSummaryCard(
                    campaign: campaign,
                    onTap: () => context.go(AppRoutes.citizenDonate),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gris, fontSize: 14),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: AppColors.bleu),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
