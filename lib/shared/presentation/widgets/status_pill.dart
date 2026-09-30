import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../models/enum_labels.dart';

/// Pill de statut d'une DonorMatchRequest.
/// NOTE : DonorMatchStatus n'a pas de valeur "indisponible" dans le modèle
/// actuel — "Je suis indisponible" (maquette) est mappé sur `declined` côté
/// repository. Si l'équipe ajoute cette valeur plus tard, il suffira
/// d'ajouter un cas ici.
class MatchStatusPill extends StatelessWidget {
  const MatchStatusPill({super.key, required this.status});

  final DonorMatchStatus? status; // null = pas encore contacté

  (Color fg, Color bg, IconData icon)? get _visual {
    switch (status) {
      case DonorMatchStatus.pending:
        return (AppColors.limite, AppColors.limite, Icons.schedule);
      case DonorMatchStatus.accepted:
        return (AppColors.disponible, AppColors.disponible, Icons.check_circle);
      case DonorMatchStatus.declined:
        return (AppColors.indisponible, AppColors.indisponible, Icons.cancel);
      case DonorMatchStatus.expired:
        return (AppColors.textSecondary, AppColors.ligne, Icons.timer_off);
      case DonorMatchStatus.completed:
        return (AppColors.disponible, AppColors.disponible, Icons.favorite);
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    final label = status?.label;
    if (visual == null || label == null) return const SizedBox.shrink();
    final (fg, bg, icon) = visual;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
