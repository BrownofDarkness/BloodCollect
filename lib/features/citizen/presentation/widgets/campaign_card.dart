import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../domain/usecases/get_donation_dashboard_usecase.dart';
import 'citizen_scaffold_parts.dart';

/// Carte d'une collecte de sang.
///
/// Utilisée telle quelle sur l'onglet « Donner » (avec actions) et sur la
/// fiche d'un centre (version compacte, sans actions).
class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.entry,
    this.showActions = true,
    this.onJoin,
    this.onCancel,
    this.onOpenDetails,
  });

  final RegisteredCampaign entry;
  final bool showActions;
  final VoidCallback? onJoin;
  final VoidCallback? onCancel;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final campaign = entry.campaign;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CampaignGlyph(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collecte de sang',
                      style: TextStyle(
                        color: AppColors.rouge,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      campaign.title,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MetaRow(
            icon: Icons.location_on_outlined,
            text: campaign.locationName,
          ),
          const SizedBox(height: 8),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            text: formatCampaignPeriodFr(campaign.startDate, campaign.endDate),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Groupes recherchés',
                style: TextStyle(color: AppColors.gris, fontSize: 13),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _TargetBloodTypes(campaign: campaign),
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            if (entry.isRegistered)
              _ConfirmedBanner(onCancel: onCancel)
            else
              _JoinRow(onJoin: onJoin, onOpenDetails: onOpenDetails),
            if (entry.isRegistered && onOpenDetails != null) ...[
              const SizedBox(height: 12),
              _SecondaryButton(label: 'Voir les détails', onTap: onOpenDetails),
            ],
          ],
        ],
      ),
    );
  }
}

class _CampaignGlyph extends StatelessWidget {
  const _CampaignGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.campaign_outlined,
        color: AppColors.rouge,
        size: 24,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.slate),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Groupes recherchés, ou « Tous groupes » quand la collecte est ouverte à tous.
class _TargetBloodTypes extends StatelessWidget {
  const _TargetBloodTypes({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    if (campaign.targetBloodTypes.length == BloodType.values.length) {
      return const _TargetPill(label: 'Tous groupes');
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final bloodType in campaign.targetBloodTypes)
          _TargetPill(label: bloodType.label),
      ],
    );
  }
}

class _TargetPill extends StatelessWidget {
  const _TargetPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.rouge,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bandeau vert « Participation confirmée », avec annulation.
class _ConfirmedBanner extends StatelessWidget {
  const _ConfirmedBanner({this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.disponibleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check, size: 18, color: AppColors.disponible),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Participation confirmée',
              style: TextStyle(
                color: AppColors.disponible,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onCancel != null)
            InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: AppColors.disponible,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.disponible,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _JoinRow extends StatelessWidget {
  const _JoinRow({this.onJoin, this.onOpenDetails});

  final VoidCallback? onJoin;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onJoin,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.rouge,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.favorite_border, size: 18),
            label: const Text(
              'Je participe',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SecondaryButton(
            label: 'Voir les détails',
            onTap: onOpenDetails,
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.encre,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.ligne, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

/// Exposé pour la fiche centre, qui n'affiche que le résumé de la collecte.
class CampaignSummaryCard extends StatelessWidget {
  const CampaignSummaryCard({super.key, required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return CampaignCard(entry: RegisteredCampaign(campaign: campaign));
  }
}

/// Titre de section « Collectes à venir » réutilisé par l'onglet « Donner ».
class UpcomingCampaignsTitle extends StatelessWidget {
  const UpcomingCampaignsTitle({super.key});

  @override
  Widget build(BuildContext context) =>
      const CitizenSectionTitle('Collectes à venir');
}
