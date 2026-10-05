import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../domain/blood_center_stats.dart';

// Pastille + libellé de disponibilité : jamais la couleur seule.
class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({super.key, required this.availability});

  final StockAvailability availability;

  @override
  Widget build(BuildContext context) {
    final (dot, label, fg, bg) = switch (availability) {
      StockAvailability.available => (
          AppColors.disponible,
          'Disponible',
          AppColors.disponible,
          const Color(0xFFDCFCE7),
        ),
      StockAvailability.limited => (
          AppColors.limite,
          'Limitée',
          AppColors.limite,
          const Color(0xFFFEF3C7),
        ),
      StockAvailability.unavailable => (
          AppColors.indisponible,
          'Indisponible',
          AppColors.indisponible,
          AppColors.rougeLight,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: dot, filled: availability == StockAvailability.available,
              half: availability == StockAvailability.limited),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Point de statut : plein / demi / vide.
class AvailabilityDot extends StatelessWidget {
  const AvailabilityDot({super.key, required this.availability, this.size = 14});

  final StockAvailability availability;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Dot(
      color: switch (availability) {
        StockAvailability.available => AppColors.disponible,
        StockAvailability.limited => AppColors.limite,
        StockAvailability.unavailable => AppColors.indisponible,
      },
      filled: availability == StockAvailability.available,
      half: availability == StockAvailability.limited,
      size: size,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    required this.filled,
    required this.half,
    this.size = 14,
  });

  final Color color;
  final bool filled;
  final bool half;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        gradient: half
            ? LinearGradient(
                stops: const [0.5, 0.5],
                colors: [color, color.withValues(alpha: 0.15)],
              )
            : null,
      ),
    );
  }
}

/// Chip de priorité : Vitale / Élevée / Normale.
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (priority) {
      Priority.vital => (
          'Vitale',
          AppColors.priorityVital,
          AppColors.rougeLight,
        ),
      Priority.elevated => (
          'Élevée',
          AppColors.priorityElevated,
          const Color(0xFFFEF3C7),
        ),
      Priority.normal => (
          'Normale',
          AppColors.priorityNormal,
          const Color(0xFFF1F1EF),
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Chip de statut de demande : En attente / En cours / etc.
class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg, icon) = switch (status) {
      RequestStatus.pending => (
          'En attente',
          const Color(0xFF92400E),
          const Color(0xFFFEF3C7),
          Icons.schedule_outlined,
        ),
      RequestStatus.routing => (
          'En cours',
          AppColors.bleu,
          AppColors.bleuLight,
          Icons.sync_outlined,
        ),
      RequestStatus.fulfilled => (
          'Confirmée',
          AppColors.disponible,
          const Color(0xFFDCFCE7),
          Icons.check_outlined,
        ),
      RequestStatus.partiallyFulfilled => (
          'Partielle',
          AppColors.limite,
          const Color(0xFFFEF3C7),
          Icons.pie_chart_outline,
        ),
      RequestStatus.oriented => (
          'Orientée',
          const Color(0xFF6D28D9),
          const Color(0xFFF3E8FF),
          Icons.redo_outlined,
        ),
      RequestStatus.cancelled => (
          'Refusée',
          AppColors.rouge,
          AppColors.rougeLight,
          Icons.close_outlined,
        ),
      RequestStatus.expired => (
          'Expirée',
          AppColors.gris,
          const Color(0xFFF1F1EF),
          Icons.history_outlined,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// État vide illustré : icône, titre, message, action optionnelle.
class BcEmptyState extends StatelessWidget {
  const BcEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.ivoire,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.gris, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gris,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rouge,
                side: const BorderSide(color: AppColors.rouge),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// « il y a 6 min », « il y a 1 h », « hier »…
String formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays == 1) return 'hier';
  return 'il y a ${diff.inDays} j';
}

/// « Samedi 17 octobre · 8h00 – 14h00 » (locale FR via intl).
String formatCampaignRange(DateTime start, DateTime end) {
  final day = DateFormat('EEEE d MMMM', 'fr').format(start);
  final capitalized = day[0].toUpperCase() + day.substring(1);
  String hm(DateTime d) =>
      '${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  return '$capitalized · ${hm(start)} – ${hm(end)}';
}

/// « 25/10 », « 20/09/2026 »…
String formatShortDate(DateTime date, {bool withYear = false}) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return withYear ? '$d/$m/${date.year}' : '$d/$m';
}

/// Jours restants avant expiration (négatif si périmé).
int daysUntil(DateTime expiry) =>
    expiry.difference(DateTime.now()).inDays;

/// Libellé FR d'un type de produit sanguin.
String productLabel(ProductType type) => switch (type) {
      ProductType.wholeBlood => 'Sang total',
      ProductType.plasma => 'Plasma',
      ProductType.platelets => 'Plaquettes',
      ProductType.redCells => 'Concentré de globules rouges',
    };
