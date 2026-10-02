import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/hc_providers.dart';
import '../widgets/blood_request_summary_card.dart';
import '../widgets/hc_role_badge.dart';
import '../widgets/home_action_card.dart';

// Onglet « Accueil » — Accueil centre de santé.
// Deux actions (bleu = personnes, rouge = sang) et l'état des demandes
// de sang du centre connecté, en temps réel.
class HcHomeScreen extends ConsumerWidget {
  const HcHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final center = ref.watch(currentHealthCenterProvider).value;
    final managerName = ref.watch(currentAppUserProvider).value?.fullName;
    final hasName = managerName != null && managerName.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HcRoleBadge(),
                  const Spacer(),
                  _NotificationsButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Notifications bientôt disponibles.'),
                        ),
                      ),
                  ),
                ],
              ),
              Text(
                hasName ? 'Bonjour $managerName,' : 'Bonjour,',
                style: const TextStyle(color: AppColors.gris, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                center?.name ?? 'Votre centre de santé',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Que souhaitez-vous faire ?', style: _headingStyle),
              const SizedBox(height: 12),
              HomeActionCard(
                overline: 'PERSONNE',
                title: 'Chercher un donneur',
                description: 'Trouver des donneurs potentiels pour vos '
                    'patients, par ville et commune.',
                icon: Icons.search,
                onTap: () => context.go(AppRoutes.hcDonors),
              ),
              const SizedBox(height: 12),
              HomeActionCard(
                filled: true,
                overline: 'SANG · CENTRES AGRÉÉS',
                title: 'Trouver du sang disponible',
                description: 'Consulter les disponibilités et envoyer une '
                    'demande à un centre de transfusion.',
                icon: Icons.water_drop_outlined,
                onTap: () => context.go(AppRoutes.hcBlood),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text('Mes demandes de sang', style: _headingStyle),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.hcRequests),
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
              const _RequestsOverview(),
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

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Notifications',
      icon: const Icon(Icons.notifications_outlined, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.encre,
        fixedSize: const Size(44, 44),
        side: const BorderSide(color: AppColors.ligne),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Compteurs et demandes en cours les plus récentes.
class _RequestsOverview extends ConsumerWidget {
  const _RequestsOverview();

  static const _maxRecent = 3;
  static const _processedWindow = Duration(days: 30);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(healthCenterRequestsProvider);

    return requestsAsync.when(
      // Une mise à jour ne doit pas faire clignoter l'accueil.
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.rouge),
        ),
      ),
      error: (_, _) => _Notice(
        text: 'Demandes indisponibles. Vérifiez votre connexion.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(healthCenterRequestsProvider),
      ),
      data: (requests) {
        final since = DateTime.now().subtract(_processedWindow);
        // « En attente » : transmise ou reçue, pas encore prise en charge.
        final waiting = requests.where(
          (r) =>
              r.progress == RequestProgress.waiting ||
              r.progress == RequestProgress.received,
        );
        final vitalCount =
            waiting.where((r) => r.priority == Priority.vital).length;
        final processingCount = requests
            .where((r) => r.progress == RequestProgress.processing)
            .length;
        final processedCount = requests
            .where(
              (r) =>
                  r.progress.isProcessed &&
                  (r.decidedAt ?? r.updatedAt).isAfter(since),
            )
            .length;
        final recent = requests
            .where((r) => r.progress.isOngoing)
            .take(_maxRecent)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StatTile(
                      value: waiting.length,
                      label: 'En attente',
                      detail: vitalCount == 0
                          ? 'aucune vitale'
                          : 'dont $vitalCount vitale'
                              '${vitalCount > 1 ? 's' : ''}',
                      color: AppColors.rouge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      value: processingCount,
                      label: 'En cours',
                      detail: 'traitement',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      value: processedCount,
                      label: 'Traitées',
                      detail: '30 derniers jours',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const _Notice(text: 'Aucune demande en cours.')
            else
              for (final request in recent) ...[
                BloodRequestSummaryCard(
                  request: request,
                  onTap: () => context.go(AppRoutes.hcRequests),
                ),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.detail,
    this.color = AppColors.encre,
  });

  final int value;
  final String label;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              color: AppColors.gris,
              fontSize: 13,
              height: 1.3,
            ),
          ),
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
