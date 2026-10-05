// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/back_control.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/presentation/models/enum_labels.dart';
import '../../../../shared/presentation/widgets/app_snackbar.dart';
import '../../../../shared/presentation/widgets/donor_card.dart';
// ignore: unused_import
import '../../../../shared/presentation/widgets/loading_skeleton.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../providers/donor_providers.dart';

/// Écran 4 — "Donneurs potentiels". Consomme les filtres de l'écran 2 et
/// gère explicitement les 4 états : chargement / vide / données / erreur.
class DonorResultsScreen extends ConsumerWidget {
  const DonorResultsScreen({super.key, required this.filters});

  final DonorSearchFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(donorSearchResultsProvider(filters));
    final contactedIds = ref.watch(contactedDonorIdsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ivoire,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: BackControl(onBack: () => context.pop()),
        title: const PersonBadge(label: 'Personne'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donneurs potentiels',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterPill(text: filters.bloodType?.label ?? ''),
                      _FilterPill(
                        text:
                            filters.communes.take(3).join(', ') +
                            (filters.communes.length > 3 ? '...' : ''),
                      ),
                      _FilterPill(
                        text: 'Urgence ${filters.priority.label.toLowerCase()}',
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.bleu,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                          color: AppColors.bleu,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.bleu,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bleuLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.bleu,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Un donneur n'est pas du sang disponible.",
                                style: TextStyle(
                                  color: AppColors.bleu,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "S'il accepte, il se rendra dans un centre de "
                                "transfusion pour l'évaluation et le don.",
                                style: TextStyle(
                                  color: AppColors.bleu,
                                  fontSize: 12.5,
                                  height: 1.45,
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
          ),
          resultsAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: _ResultsSkeletonList(),
            ),
            error: (err, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorResults(
                onRetry: () =>
                    ref.invalidate(donorSearchResultsProvider(filters)),
              ),
            ),
            data: (donors) {
              if (donors.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyResults(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            '${donors.length} donneur${donors.length > 1 ? 's' : ''} correspondent à votre recherche',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }
                    final raw = donors[i - 1];
                    final candidate =
                        contactedIds.contains(raw.donorId) &&
                            raw.matchStatus == null
                        ? raw.copyWith(matchStatus: DonorMatchStatus.pending)
                        : raw;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DonorCard(
                        candidate: candidate,
                        onContact: () async {
                          final sent = await context.push<bool>(
                            '${AppRoutes.citizenDonors}/${AppRoutes.citizenDonorsRequest}',
                            extra: candidate,
                          );
                          if (sent == true) {
                            ref
                                .read(contactedDonorIdsProvider.notifier)
                                .markContacted(candidate.donorId);
                            if (context.mounted) {
                              AppSnackbar.success(
                                context,
                                'Demande envoyée à ce donneur.',
                              );
                            }
                          }
                        },
                      ),
                    );
                  }, childCount: min(donors.length + 1, 51)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ResultsSkeletonList extends StatelessWidget {
  const _ResultsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) {
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
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.ligne,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 120,
                            color: AppColors.ligne,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 180,
                            color: AppColors.ligne,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 74,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.ligne,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: AppColors.ligne,
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 220, color: AppColors.ligne),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Aucun donneur ne correspond à votre recherche',
              style: TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              "Essayez d'élargir les communes ou le niveau d'urgence.",
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Modifier la recherche'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorResults extends StatelessWidget {
  const _ErrorResults({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 44, color: AppColors.indisponible),
            const SizedBox(height: 14),
            const Text(
              'Impossible de charger les donneurs',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vérifiez votre connexion et réessayez.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
