import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../providers/hc_providers.dart';
import 'request_progress_pill.dart';

/// Résumé d'une demande pour l'accueil : besoin, urgence, centre, avancement.
/// Le suivi détaillé est dans l'onglet « Demandes ».
class BloodRequestSummaryCard extends ConsumerWidget {
  const BloodRequestSummaryCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final BloodRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centerId = request.matchedBloodCenterId;
    final centerName = centerId == null
        ? 'Centre non attribué'
        : ref.watch(bloodCenterProvider(centerId)).value?.name ??
            'Centre de transfusion';
    final quantity = request.quantityNeeded;

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
                decoration: BoxDecoration(
                  color: AppColors.indisponibleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.bloodType.label,
                  style: const TextStyle(
                    color: AppColors.rouge,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$quantity poche${quantity > 1 ? 's' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.encre,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _PriorityChip(priority: request.priority),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$centerName · '
                      '${Formatters.relative(request.createdAt)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RequestProgressPill(
                      progress: request.progress,
                      short: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Seules les urgences sont signalées : une demande normale n'a pas de puce.
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (priority) {
      Priority.vital => (
          'Vitale',
          AppColors.priorityVital,
          AppColors.indisponibleLight,
        ),
      Priority.elevated => (
          'Élevée',
          AppColors.priorityElevated,
          AppColors.limiteLight,
        ),
      Priority.normal => (null, null, null),
    };
    if (label == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
