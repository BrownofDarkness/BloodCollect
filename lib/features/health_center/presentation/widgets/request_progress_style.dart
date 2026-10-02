import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/blood_request.dart';

/// Code visuel de l'avancement d'une demande (pastille, bandeau, frise).
extension RequestProgressStyle on RequestProgress {
  String get label => switch (this) {
        RequestProgress.waiting => 'En attente',
        RequestProgress.received => 'Reçue par le centre',
        RequestProgress.processing => 'En cours de traitement',
        RequestProgress.approved => 'Approuvée',
        RequestProgress.partial => 'Partiellement approuvée',
        RequestProgress.refused => 'Refusée',
        RequestProgress.oriented => 'Orientée',
        RequestProgress.cancelled => 'Annulée',
        RequestProgress.expired => 'Expirée',
      };

  IconData get icon => switch (this) {
        RequestProgress.waiting => Icons.schedule_outlined,
        RequestProgress.received => Icons.mark_email_read_outlined,
        RequestProgress.processing => Icons.refresh,
        RequestProgress.approved => Icons.check_circle_outline,
        RequestProgress.partial => Icons.contrast,
        RequestProgress.refused => Icons.block,
        RequestProgress.oriented => Icons.turn_right,
        RequestProgress.cancelled => Icons.close,
        RequestProgress.expired => Icons.timer_off_outlined,
      };

  Color get color => switch (this) {
        RequestProgress.waiting || RequestProgress.partial => AppColors.limite,
        RequestProgress.received ||
        RequestProgress.processing =>
          AppColors.bleu,
        RequestProgress.approved => AppColors.disponible,
        RequestProgress.refused => AppColors.rouge,
        RequestProgress.oriented => AppColors.violet,
        RequestProgress.cancelled || RequestProgress.expired => AppColors.slate,
      };

  Color get background => switch (this) {
        RequestProgress.waiting ||
        RequestProgress.partial =>
          AppColors.limiteLight,
        RequestProgress.received ||
        RequestProgress.processing =>
          AppColors.bleuLight,
        RequestProgress.approved => AppColors.disponibleLight,
        RequestProgress.refused => AppColors.indisponibleLight,
        RequestProgress.oriented => AppColors.violetLight,
        RequestProgress.cancelled || RequestProgress.expired => AppColors.ligne,
      };
}
