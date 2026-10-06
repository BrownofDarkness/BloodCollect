import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_candidate.dart';
import '../../../../shared/domain/entities/donor_contact_selection.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/domain/entities/donor_search_criteria.dart';
import '../../../../shared/presentation/providers/donor_search_providers.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../widgets/donor_result_card.dart';

// Onglet « Donneurs » — Donneurs potentiels.
// Résultat anonymisé d'une recherche. Le citoyen contacte les donneurs un
// par un ; une demande déjà envoyée affiche son état au lieu du bouton.
class CitizenDonorResultsScreen extends ConsumerWidget {
  const CitizenDonorResultsScreen({super.key, required this.criteria});

  /// null si l'URL ne porte pas de critères valides.
  final DonorSearchCriteria? criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = this.criteria;
    void back() => context.canPop()
        ? context.pop()
        : context.go(AppRoutes.citizenDonors);

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
                  AppBackButton(onPressed: back),
                  const Spacer(),
                  const PersonBadge(
                    label: 'Personne',
                    icon: Icons.person_outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Donneurs potentiels',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (criteria == null)
                _Message(
                  icon: Icons.tune,
                  title: 'Critères incomplets',
                  body: 'Relancez la recherche depuis le formulaire.',
                  actionLabel: 'Modifier la recherche',
                  onAction: () => context.go(AppRoutes.citizenDonors),
                )
              else ...[
                _CriteriaChips(criteria: criteria),
                TextButton(
                  onPressed: back,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.bleu,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text('Modifier'),
                ),
                const SizedBox(height: 8),
                const _DonorNotBloodNotice(),
                const SizedBox(height: 20),
                _Results(criteria: criteria, onEdit: back),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.criteria, required this.onEdit});

  final DonorSearchCriteria criteria;
  final VoidCallback onEdit;

  /// Demande la plus récente envoyée à chaque donneur encore en vigueur.
  /// Une demande expirée ne compte plus : le donneur peut être recontacté.
  static Map<String, DonorMatchStatus> _statusByDonor(
    List<DonorMatchRequest> sent,
  ) {
    final now = DateTime.now();
    final statuses = <String, DonorMatchStatus>{};
    // [sent] est trié de la plus récente à la plus ancienne.
    for (final match in sent) {
      final status = match.statusAt(now);
      if (status == DonorMatchStatus.expired) continue;
      statuses.putIfAbsent(match.donorId, () => status);
    }
    return statuses;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(donorCandidatesProvider(criteria));
    final statuses = _statusByDonor(
      ref.watch(sentDonorMatchesProvider).value ?? const [],
    );

    return candidatesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.bleu),
        ),
      ),
      error: (_, _) => _Message(
        icon: Icons.cloud_off_outlined,
        title: 'Recherche indisponible',
        body: 'La recherche de donneurs n’a pas abouti. Vérifiez votre '
            'connexion, puis réessayez.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(donorCandidatesProvider(criteria)),
      ),
      data: (candidates) {
        if (candidates.isEmpty) {
          return _Message(
            icon: Icons.person_search_outlined,
            title: 'Aucun donneur ne correspond',
            body: 'Élargissez la zone en ajoutant des communes, ou essayez '
                'une autre ville.',
            actionLabel: 'Modifier la recherche',
            onAction: onEdit,
          );
        }
        final count = candidates.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count > 1
                  ? '$count donneurs correspondent à votre recherche'
                  : '1 donneur correspond à votre recherche',
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final candidate in candidates) ...[
              DonorResultCard(
                candidate: candidate,
                sentStatus: statuses[candidate.donorId],
                onContact: () => _contact(context, candidate),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  void _contact(BuildContext context, DonorCandidate candidate) {
    context.push(
      AppRoutes.citizenDonorContact,
      extra: DonorContactSelection(
        criteria: criteria,
        candidates: [candidate],
      ),
    );
  }
}

class _CriteriaChips extends StatelessWidget {
  const _CriteriaChips({required this.criteria});

  final DonorSearchCriteria criteria;

  @override
  Widget build(BuildContext context) {
    final urgency = switch (criteria.priority) {
      Priority.normal => 'Urgence normale',
      Priority.elevated => 'Urgence élevée',
      Priority.vital => 'Urgence vitale',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in [
          criteria.bloodType.label,
          criteria.communes.join(', '),
          urgency,
        ])
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.ligne),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

// Règle fondamentale du projet, rappelée avant tout contact.
class _DonorNotBloodNotice extends StatelessWidget {
  const _DonorNotBloodNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bleuSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.bleu, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Un donneur n’est pas du sang disponible.',
                  style: TextStyle(
                    color: AppColors.bleu,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'S’il accepte, il se rendra dans un centre de transfusion '
                  'pour l’évaluation et le don.',
                  style: TextStyle(
                    color: AppColors.slate,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
