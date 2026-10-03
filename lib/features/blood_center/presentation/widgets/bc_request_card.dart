import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import 'bc_shared_widgets.dart';

// Carte demande reçue — dashboard + liste demandes. Bordure rose si vitale, ligne standard sinon.
class BcRequestCard extends StatelessWidget {
  const BcRequestCard({
    super.key,
    required this.request,
    required this.requesterName,
    this.onTap,
  });

  final BloodRequest request;
  final String requesterName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final vital = request.priority == Priority.vital;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: vital ? AppColors.rouge : AppColors.ligne,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'CENTRE DE SANTÉ',
                      style: TextStyle(
                        color: AppColors.gris,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(
                    formatTimeAgo(request.createdAt),
                    style: const TextStyle(
                      color: AppColors.gris,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${request.bloodType.label} · '
                      '${request.quantityNeeded} '
                      'poche${request.quantityNeeded > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  PriorityChip(priority: request.priority),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      requesterName,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  RequestStatusChip(status: request.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
