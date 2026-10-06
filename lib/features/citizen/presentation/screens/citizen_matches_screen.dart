import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/presentation/providers/donor_search_providers.dart';
import '../../../../shared/presentation/widgets/donor_match_card.dart';
import '../../../../shared/presentation/widgets/donor_match_status_style.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';
import '../providers/citizen_home_providers.dart';
import '../widgets/citizen_role_badge.dart';

// Onglet « Profil » — Mes mises en relation.
// Un citoyen est à la fois donneur et demandeur : l'écran réunit les
// demandes qu'il a reçues (auxquelles répondre) et celles qu'il a envoyées
// (dont suivre la réponse), en temps réel.
class CitizenMatchesScreen extends ConsumerWidget {
  const CitizenMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedAsync = ref.watch(incomingDonorRequestsProvider);
    final sentAsync = ref.watch(sentDonorMatchesProvider);
    final now = DateTime.now();
    final loading = receivedAsync.isLoading || sentAsync.isLoading;
    final failed = receivedAsync.hasError || sentAsync.hasError;
    final received = receivedAsync.value ?? const <DonorMatchRequest>[];
    final sent = sentAsync.value ?? const <DonorMatchRequest>[];

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
                    onPressed: () => context.go(AppRoutes.citizenProfile),
                  ),
                  const Spacer(),
                  const CitizenRoleBadge(),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Mes mises en relation',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              if (failed)
                _Message(
                  text: 'Chargement impossible. Vérifiez votre connexion.',
                  actionLabel: 'Réessayer',
                  onAction: () {
                    ref.invalidate(incomingDonorRequestsProvider);
                    ref.invalidate(sentDonorMatchesProvider);
                  },
                )
              else if (loading && received.isEmpty && sent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.bleu),
                  ),
                )
              else ...[
                const SectionTitle('DEMANDES REÇUES'),
                const SizedBox(height: 12),
                if (received.isEmpty)
                  const _Message(
                    text: 'Aucune demande de don reçue pour le moment.',
                  )
                else
                  for (final request in received) ...[
                    _ReceivedTile(
                      request: request,
                      now: now,
                      onTap: () => context.push(
                        '${AppRoutes.citizenIncoming}/${request.id}',
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 14),
                const SectionTitle('DEMANDES ENVOYÉES'),
                const SizedBox(height: 12),
                if (sent.isEmpty)
                  _Message(
                    text: 'Vous n’avez sollicité aucun donneur.',
                    actionLabel: 'Chercher un donneur',
                    onAction: () => context.go(AppRoutes.citizenDonors),
                  )
                else
                  for (final match in sent) ...[
                    DonorMatchCard(match: match, now: now),
                    const SizedBox(height: 10),
                  ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Demande reçue : ouvre l'écran de réponse.
class _ReceivedTile extends StatelessWidget {
  const _ReceivedTile({
    required this.request,
    required this.now,
    required this.onTap,
  });

  final DonorMatchRequest request;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = request.statusAt(now);
    final urgency = switch (request.priority) {
      Priority.normal => 'Urgence normale',
      Priority.elevated => 'Urgence élevée',
      Priority.vital => 'Urgence vitale',
    };

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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.bleuSurface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  request.bloodType.label,
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
                      'Demande de don',
                      style: TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$urgency · reçue '
                      '${Formatters.relative(request.createdAt, now: now)}',
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(status.icon, color: status.color, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          status == DonorMatchStatus.pending
                              ? 'À traiter'
                              : status.label,
                          style: TextStyle(
                            color: status.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.encre),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

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
