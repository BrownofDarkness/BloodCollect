import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../domain/blood_center_stats.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_request_card.dart';
import '../widgets/bc_shared_widgets.dart';
import '../widgets/bc_shimmer.dart';

// UI 4 — Demandes de sang : file de travail vitale d'abord.
// Mock via providers ; étape 2 = streams Firestore.
class BcRequestsScreen extends ConsumerStatefulWidget {
  const BcRequestsScreen({super.key});

  @override
  ConsumerState<BcRequestsScreen> createState() => _BcRequestsScreenState();
}

class _BcRequestsScreenState extends ConsumerState<BcRequestsScreen> {
  int _tab = 0;

  List<BloodRequest> _inProgress(List<BloodRequest> all) {
    final list = all
        .where((r) => r.status == RequestStatus.routing)
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<BloodRequest> _treated(List<BloodRequest> all) {
    const done = {
      RequestStatus.fulfilled,
      RequestStatus.partiallyFulfilled,
      RequestStatus.oriented,
      RequestStatus.cancelled,
      RequestStatus.expired,
    };
    final list = all.where((r) => done.contains(r.status)).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(bcBloodRequestsProvider);
    final namesAsync = ref.watch(bcHealthCenterNamesProvider);
    final loading = requestsAsync.isLoading;
    final Object? error = requestsAsync.hasError
        ? requestsAsync.error
        : namesAsync.hasError
            ? namesAsync.error
            : null;
    final requests = requestsAsync.asData?.value ?? const <BloodRequest>[];
    final names = namesAsync.asData?.value ?? const <String, String>{};
    final pending = pendingSorted(requests);

    final shown = switch (_tab) {
      1 => _inProgress(requests),
      2 => _treated(requests),
      _ => pending,
    };
    final empty = switch (_tab) {
      1 => (
          Icons.sync_outlined,
          'Aucune demande en cours',
          'Les demandes prises en charge par le Blood Route '
              'apparaîtront ici.',
        ),
      2 => (
          Icons.check_circle_outlined,
          'Aucune demande traitée',
          'Les demandes approuvées, refusées ou orientées '
              'apparaîtront ici.',
        ),
      _ => (
          Icons.inbox_outlined,
          'Aucune demande à traiter',
          'Les nouvelles demandes des centres de santé '
              'apparaîtront ici.',
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
              const SizedBox(height: 8),
              const Text(
                'Demandes de sang',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Envoyées par les centres de santé · les plus urgentes '
                'en premier',
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
                      label: 'À traiter · ${pending.length}',
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    _Tab(
                      label: 'En cours',
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                    _Tab(
                      label: 'Traitées',
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
                  const ListShimmer()
              else if (shown.isEmpty)
                BcEmptyState(
                  icon: empty.$1,
                  title: empty.$2,
                  message: empty.$3,
                )
              else
                for (final request in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BcRequestCard(
                      request: request,
                      requesterName:
                          names[request.healthCenterId] ?? 'Centre de santé',
                      onTap: () =>
                          context.go('/bc/requests/${request.id}'),
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
