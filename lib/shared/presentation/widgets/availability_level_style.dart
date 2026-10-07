import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/blood_availability.dart';

/// Code visuel des trois niveaux de disponibilité (pastilles, tuiles, légende).
extension AvailabilityLevelStyle on AvailabilityLevel {
  String get label => switch (this) {
        AvailabilityLevel.available => 'Disponible',
        AvailabilityLevel.limited => 'Disponibilité limitée',
        AvailabilityLevel.unavailable => 'Indisponible',
      };

  String get shortLabel => switch (this) {
        AvailabilityLevel.available => 'Disponible',
        AvailabilityLevel.limited => 'Limitée',
        AvailabilityLevel.unavailable => 'Indisponible',
      };

  IconData get icon => switch (this) {
        AvailabilityLevel.available => Icons.circle,
        AvailabilityLevel.limited => Icons.contrast,
        AvailabilityLevel.unavailable => Icons.circle_outlined,
      };

  Color get color => switch (this) {
        AvailabilityLevel.available => AppColors.disponible,
        AvailabilityLevel.limited => AppColors.limite,
        AvailabilityLevel.unavailable => AppColors.indisponible,
      };

  Color get background => switch (this) {
        AvailabilityLevel.available => AppColors.disponibleLight,
        AvailabilityLevel.limited => AppColors.limiteLight,
        AvailabilityLevel.unavailable => AppColors.indisponibleLight,
      };
}
