import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_candidate.dart';
import '../../../../shared/domain/entities/donor_search_criteria.dart';
import '../providers/hc_providers.dart';
import '../widgets/donor_candidate_card.dart';
import '../widgets/hc_role_badge.dart';
import 'hc_donor_contact_screen.dart';

// Onglet « Donneurs » — Donneurs potentiels · sélection multiple.
// Le centre coche les donneurs anonymisés à solliciter, puis précise sa
// demande sur l'écran « Demande de mise en relation ».
class HcDonorResultsScreen extends ConsumerStatefulWidget {
  const HcDonorResultsScreen({super.key, required this.criteria});

  /// null si l'URL ne porte pas de critères valides.
  final DonorSearchCriteria? criteria;

  @override
  ConsumerState<HcDonorResultsScreen> createState() =>
      _HcDonorResultsScreenState();
}

class _HcDonorResultsScreenState extends ConsumerState<HcDonorResultsScreen> {
  final _selected = <String>{};

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.hcDonors);

  void _contact(
    DonorSearchCriteria criteria,
    List<DonorCandidate> candidates,
  ) {
    context.push(
      AppRoutes.hcDonorContact,
      extra: DonorContactSelection(
        criteria: criteria,
        candidates: candidates
            .where((c) => _selected.contains(c.donorId))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final criteria = widget.criteria;
    final candidatesAsync =
        criteria == null ? null : ref.watch(donorCandidatesProvider(criteria));
    final candidates = candidatesAsync?.value ?? const <DonorCandidate>[];

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      bottomNavigationBar: criteria == null || candidates.isEmpty
          ? null
          : _SelectionBar(
              selectedCount: _selected.length,
              wantedCount: criteria.donorCount,
              onContact: _selected.isEmpty
                  ? null
                  : () => _contact(criteria, candidates),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: _back),
                  const Spacer(),
                  const HcRoleBadge(),
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
                  onAction: () => context.go(AppRoutes.hcDonors),
                )
              else ...[
                _CriteriaChips(criteria: criteria),
                const SizedBox(height: 20),
                candidatesAsync!.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.bleu),
                    ),
                  ),
                  error: (_, _) => _Message(
                    icon: Icons.cloud_off_outlined,
                    title: 'Recherche indisponible',
                    body: 'La recherche de donneurs n’a pas abouti. '
                        'Réessayez dans un instant.',
                    actionLabel: 'Réessayer',
                    onAction: () =>
                        ref.invalidate(donorCandidatesProvider(criteria)),
                  ),
                  data: (items) => items.isEmpty
                      ? _Message(
                          icon: Icons.person_search_outlined,
                          title: 'Aucun donneur disponible',
                          body: 'Élargissez la zone en ajoutant des '
                              'communes, ou essayez une autre ville.',
                          actionLabel: 'Modifier la recherche',
                          onAction: _back,
                        )
                      : _CandidateList(
                          candidates: items,
                          selected: _selected,
                          onToggleAll: () => setState(() {
                            final all = items.map((c) => c.donorId);
                            if (_selected.containsAll(all)) {
                              _selected.clear();
                            } else {
                              _selected.addAll(all);
                            }
                          }),
                          onChanged: (id, value) => setState(
                            () => value
                                ? _selected.add(id)
                                : _selected.remove(id),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
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

class _CandidateList extends StatelessWidget {
  const _CandidateList({
    required this.candidates,
    required this.selected,
    required this.onToggleAll,
    required this.onChanged,
  });

  final List<DonorCandidate> candidates;
  final Set<String> selected;
  final VoidCallback onToggleAll;
  final void Function(String donorId, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final count = candidates.length;
    final allSelected =
        selected.containsAll(candidates.map((c) => c.donorId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$count donneur${count > 1 ? 's' : ''} '
                'trouvé${count > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: onToggleAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.bleu,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(
                allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final candidate in candidates) ...[
          DonorCandidateCard(
            candidate: candidate,
            selected: selected.contains(candidate.donorId),
            onChanged: (value) => onChanged(candidate.donorId, value),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.selectedCount,
    required this.wantedCount,
    required this.onContact,
  });

  final int selectedCount;
  final int wantedCount;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    final plural = selectedCount > 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.ligne)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$selectedCount',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: ' sélectionné${plural ? 's' : ''} sur '
                          '$wantedCount souhaité${wantedCount > 1 ? 's' : ''}',
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bleu,
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.near_me_outlined, size: 20),
              label: Text('Contacter ($selectedCount)'),
            ),
          ],
        ),
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
