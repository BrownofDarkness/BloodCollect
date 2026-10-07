import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/blood_center_stats.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_request_card.dart';
import '../widgets/bc_shared_widgets.dart';
import '../widgets/bc_shimmer.dart';

// Tableau de bord transfusion (cockpit lecture seule).
// Données mockées typées via providers ; étape 2 = streams Firestore.
class BcHomeScreen extends ConsumerWidget {
  const BcHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centerAsync = ref.watch(myBloodCenterProvider);
    final lotsAsync = ref.watch(bcStockLotsProvider);
    final requestsAsync = ref.watch(bcBloodRequestsProvider);
    final campaignsAsync = ref.watch(bcCampaignsProvider);
    final namesAsync = ref.watch(bcHealthCenterNamesProvider);

    final loading = centerAsync.isLoading ||
        lotsAsync.isLoading ||
        requestsAsync.isLoading ||
        campaignsAsync.isLoading;
    final center = centerAsync.asData?.value;
    final Object? error = centerAsync.hasError
        ? centerAsync.error
        : lotsAsync.hasError
            ? lotsAsync.error
            : requestsAsync.hasError
                ? requestsAsync.error
                : campaignsAsync.hasError
                    ? campaignsAsync.error
                    : (!loading && center == null)
                        ? 'Aucun centre associé à ce compte.'
                        : null;

    final lots = lotsAsync.asData?.value ?? const [];
    final requests = requestsAsync.asData?.value ?? const [];
    final campaigns = campaignsAsync.asData?.value ?? const [];
    final names = namesAsync.asData?.value ?? const {};

    final byType = unitsByBloodType(lots);
    final total = totalUnits(byType);
    final pending = pendingSorted(requests);
    final vitals = vitalCount(pending);
    final upcoming = upcomingCampaigns(campaigns, DateTime.now());
    final low = ref.watch(bcLowThresholdProvider);
    final unavailable = ref.watch(bcUnavailableThresholdProvider);
    final alertGroups = byType.entries
        .where(
          (e) =>
              availabilityFor(
                units: e.value,
                low: low,
                unavailable: unavailable,
              ) !=
              StockAvailability.available,
        )
        .length;

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
                  // Cloche de notifications : masquée en v1, aucune
                  // notification n'est encore envoyée (Cloud Functions à
                  // venir).
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Tableau de bord',
                style: TextStyle(color: AppColors.gris, fontSize: 15),
              ),
              Text(
                center?.name ?? 'Centre de transfusion',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
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
                loading
                  ? const StatsShimmer()
                  : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 13,
                childAspectRatio: 1.55,
                children: [
                  _StatCard(
                    value: '${pending.length}',
                    valueColor: AppColors.rouge,
                    title: 'Demandes à traiter',
                    subtitle:
                        vitals > 0 ? 'dont $vitals vitale${vitals > 1 ? 's' : ''}' : 'aucune vitale',
                  ),
                  _StatCard(
                    value: '$total',
                    valueColor: AppColors.encre,
                    title: 'Poches en stock',
                    subtitle: '8 groupes suivis',
                  ),
                  _StatCard(
                    value: '$alertGroups',
                    valueColor: AppColors.encre,
                    title: 'Groupes en alerte',
                    subtitle: 'limitée ou indisponible',
                  ),
                  _StatCard(
                    value: '${upcoming.length}',
                    valueColor: AppColors.encre,
                    title: 'Collectes',
                    subtitle: 'à venir ce mois-ci',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_outlined,
                      label: 'Ajouter des\npoches',
                      onTap: () => context.go(AppRoutes.bcStocks),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.list_outlined,
                      label: 'Traiter les\ndemandes',
                      onTap: () => context.go(AppRoutes.bcRequests),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.campaign_outlined,
                      label: 'Nouvelle\ncollecte',
                      onTap: () => context.go(AppRoutes.bcCampaigns),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'État des stocks',
                      style: TextStyle(
                        color: AppColors.encre,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.bcStocks),
                    child: const Text(
                      'Gérer',
                      style: TextStyle(
                        color: AppColors.bleu,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.bleu,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (error == null)
                loading
                  ? const GroupGridShimmer()
                  : GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: [
                  for (final entry in byType.entries)
                    _GroupTile(
                      type: entry.key.label,
                      units: entry.value,
                      availability: availabilityFor(
                        units: entry.value,
                        low: low,
                        unavailable: unavailable,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  AvailabilityDot(
                    availability: StockAvailability.available,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Disponible',
                    style: TextStyle(color: AppColors.gris, fontSize: 13),
                  ),
                  SizedBox(width: 12),
                  AvailabilityDot(
                    availability: StockAvailability.limited,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Limitée',
                    style: TextStyle(color: AppColors.gris, fontSize: 13),
                  ),
                  SizedBox(width: 12),
                  AvailabilityDot(
                    availability: StockAvailability.unavailable,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Indisponible',
                    style: TextStyle(color: AppColors.gris, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Demandes urgentes',
                      style: TextStyle(
                        color: AppColors.encre,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.bcRequests),
                    child: const Text(
                      'Tout voir',
                      style: TextStyle(
                        color: AppColors.bleu,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.bleu,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (error == null)
                if (loading)
                  const ListShimmer(count: 1)
              else if (pending.isEmpty)
                const BcEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Aucune demande en attente',
                  message: 'Tout est traité. Les urgences apparaîtront ici.',
                )
              else
                BcRequestCard(
                  request: pending.first,
                  requesterName:
                      names[pending.first.healthCenterId] ?? 'Centre de santé',
                  onTap: () => context.go(AppRoutes.bcRequests),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.valueColor,
    required this.title,
    required this.subtitle,
  });

  final String value;
  final Color valueColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.gris, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.ligne),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.rouge, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.type,
    required this.units,
    required this.availability,
  });

  final String type;
  final int units;
  final StockAvailability availability;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.rouge,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AvailabilityDot(availability: availability, size: 12),
            ],
          ),
          Text(
            '$units',
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'poches',
            style: TextStyle(color: AppColors.gris, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
