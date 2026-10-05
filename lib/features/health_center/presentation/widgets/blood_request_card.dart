import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../providers/hc_providers.dart';
import 'blood_request_timeline.dart';
import 'request_progress_pill.dart';
import 'request_progress_style.dart';

/// Carte d'une demande de sang : besoin, centre destinataire, avancement.
/// Dépliée, elle affiche la frise de suivi.
class BloodRequestCard extends ConsumerWidget {
  const BloodRequestCard({
    super.key,
    required this.request,
    required this.expanded,
    required this.onTap,
  });

  final BloodRequest request;
  final bool expanded;
  final VoidCallback onTap;

  // Demande en cours et urgente : l'urgence prime sur l'ancienneté.
  String get _context {
    if (request.progress.isOngoing) {
      switch (request.priority) {
        case Priority.vital:
          return 'Urgence vitale';
        case Priority.elevated:
          return 'Urgence élevée';
        case Priority.normal:
      }
    }
    return Formatters.relative(request.createdAt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = request.progress;
    final centerId = request.matchedBloodCenterId;
    final centerName = centerId == null
        ? 'Centre non attribué'
        : ref.watch(bloodCenterProvider(centerId)).value?.name ??
            'Centre de transfusion';
    final quantity = request.quantityNeeded;
    final reference = request.patientReference;
    final response = request.responseMessage?.trim() ?? '';
    final showBanner =
        response.isNotEmpty || progress == RequestProgress.oriented;

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          [
                            '$quantity poche${quantity > 1 ? 's' : ''}',
                            if (reference != null && reference.isNotEmpty)
                              reference,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.encre,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$centerName · $_context',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gris,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RequestProgressPill(progress: progress),
                      ],
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 16),
                BloodRequestTimeline(request: request),
              ],
              if (showBanner) ...[
                const SizedBox(height: 12),
                _ResponseBanner(
                  progress: progress,
                  message: response.isEmpty
                      ? 'Orientée vers un autre centre de transfusion'
                      : response,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Réponse écrite du centre de transfusion (orientation, motif, précision).
class _ResponseBanner extends StatelessWidget {
  const _ResponseBanner({required this.progress, required this.message});

  final RequestProgress progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: progress.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(progress.icon, color: progress.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: progress.color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
