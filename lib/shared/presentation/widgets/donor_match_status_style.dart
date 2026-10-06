import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';

/// Code visuel de la réponse d'un donneur à une sollicitation.
extension DonorMatchStatusStyle on DonorMatchStatus {
  String get label => switch (this) {
        DonorMatchStatus.pending => 'En attente',
        DonorMatchStatus.accepted => 'Acceptée',
        DonorMatchStatus.declined => 'Déclinée',
        DonorMatchStatus.expired => 'Expirée',
        DonorMatchStatus.completed => 'Don effectué',
      };

  IconData get icon => switch (this) {
        DonorMatchStatus.pending => Icons.schedule_outlined,
        DonorMatchStatus.accepted => Icons.check_circle_outline,
        DonorMatchStatus.declined => Icons.block,
        DonorMatchStatus.expired => Icons.timer_off_outlined,
        DonorMatchStatus.completed => Icons.volunteer_activism_outlined,
      };

  Color get color => switch (this) {
        DonorMatchStatus.pending => AppColors.limite,
        DonorMatchStatus.accepted ||
        DonorMatchStatus.completed =>
          AppColors.disponible,
        DonorMatchStatus.declined => AppColors.rouge,
        DonorMatchStatus.expired => AppColors.slate,
      };

  Color get background => switch (this) {
        DonorMatchStatus.pending => AppColors.limiteLight,
        DonorMatchStatus.accepted ||
        DonorMatchStatus.completed =>
          AppColors.disponibleLight,
        DonorMatchStatus.declined => AppColors.indisponibleLight,
        DonorMatchStatus.expired => AppColors.ligne,
      };

  /// Ordre d'affichage : les réponses positives d'abord.
  int get displayRank => switch (this) {
        DonorMatchStatus.accepted => 0,
        DonorMatchStatus.pending => 1,
        DonorMatchStatus.completed => 2,
        DonorMatchStatus.declined => 3,
        DonorMatchStatus.expired => 4,
      };
}
