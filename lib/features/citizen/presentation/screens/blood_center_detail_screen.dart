import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../domain/usecases/get_blood_center_details_usecase.dart';
import '../providers/citizen_providers.dart';
import '../widgets/blood_center_map.dart';
import '../widgets/blood_status_widgets.dart';
import '../widgets/campaign_card.dart';
import '../widgets/citizen_scaffold_parts.dart';

/// Fiche d'un centre de transfusion, poussée depuis l'onglet « Sang ».
///
/// Tout y est en lecture seule : le citoyen consulte les disponibilités
/// déclarées, les horaires et les collectes du centre. Il ne réserve pas de
/// poche — seul un centre de santé porte une demande.
class BloodCenterDetailScreen extends ConsumerWidget {
  const BloodCenterDetailScreen({super.key, required this.centerId});

  final String centerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(bloodCenterDetailsProvider(centerId));

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: detailsAsync.when(
        loading: () => const _CenterSkeleton(),
        error: (error, _) => _DetailError(centerId: centerId),
        data: (details) {
          if (details == null) return _DetailError(centerId: centerId);
          return _CenterDetailsBody(details: details);
        },
      ),
    );
  }
}

class _CenterDetailsBody extends ConsumerWidget {
  const _CenterDetailsBody({required this.details});

  final BloodCenterDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final center = details.center;
    final campaign = details.nearestCampaign;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            const BloodCenterMapBanner(),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 6,
              left: 10,
              child: _CircularBackButton(
                onTap: () => context.go(AppRoutes.citizenBlood),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CitizenLabelCaps('Centre de transfusion agréé'),
              const SizedBox(height: 10),
              Text(
                center.name,
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${center.commune}, ${center.city} $middleDot ${formatDistanceKm(details.distanceKm)}',
                style: const TextStyle(color: AppColors.gris, fontSize: 14.5),
              ),
              const SizedBox(height: 22),

              _ContactBlock(details: details),
              const SizedBox(height: 22),

              CitizenSectionTitle(
                'Disponibilités déclarées',
                trailing: Text(
                  formatLastUpdateLabel(details.updatedAt),
                  style: const TextStyle(color: AppColors.gris, fontSize: 12.5),
                ),
              ),
              const SizedBox(height: 14),
              BloodAvailabilityGrid(availability: details.availability),
              const SizedBox(height: 26),

              const CitizenSectionTitle('Comment se passe votre don'),
              const SizedBox(height: 14),
              const DonationSteps(),
              const SizedBox(height: 26),

              if (campaign != null) ...[
                CampaignSummaryCard(campaign: campaign),
                const SizedBox(height: 22),
              ],

              _DonateCallToAction(centerId: center.id),
              const SizedBox(height: 12),
              const _SecondaryActions(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Les 5 étapes du don, identiques pour tout centre agréé.
class DonationSteps extends StatelessWidget {
  const DonationSteps({super.key});

  static const List<String> _steps = [
    'Accueil et identification',
    "Vérification de l'éligibilité",
    'Procédures médicales',
    'Don',
    'Enregistrement du don',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < _steps.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _StepNumber(index: index + 1),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _steps[index],
                    style: const TextStyle(
                      color: AppColors.encre,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          color: AppColors.rouge,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({required this.details});

  final BloodCenterDetails details;

  @override
  Widget build(BuildContext context) {
    final center = details.center;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value: center.address,
          ),
          const Divider(height: 1, indent: 56, color: AppColors.ligne),
          _ContactRow(
            icon: Icons.schedule,
            label: 'Horaires',
            value: _openingHours(
              center.openingHoursWeekdays,
              center.openingHoursSaturday,
            ),
          ),
          const Divider(height: 1, indent: 56, color: AppColors.ligne),
          _ContactRow(
            icon: Icons.call_outlined,
            label: 'Téléphone',
            value: center.phone,
          ),
        ],
      ),
    );
  }

  String _openingHours(String weekdays, String? saturday) =>
      'Lun $enDash Ven $middleDot $weekdays\n'
              '${saturday == null ? '' : 'Sam $middleDot $saturday'}'
          .trimRight();
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.slate),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.gris, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonateCallToAction extends ConsumerWidget {
  const _DonateCallToAction({required this.centerId});

  final String centerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => context.go(AppRoutes.citizenDonate),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rouge,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.favorite_border, size: 19),
        label: const Text(
          'Je souhaite donner mon sang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Text(
              'Appeler',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: _secondaryStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text(
              'Itinéraire',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: _secondaryStyle,
          ),
        ),
      ],
    );
  }

  static final _secondaryStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.encre,
    minimumSize: const Size(0, 52),
    side: const BorderSide(color: AppColors.ligne, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class _CircularBackButton extends StatelessWidget {
  const _CircularBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(11),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
    );
  }
}

class _CenterSkeleton extends StatelessWidget {
  const _CenterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BloodCenterMapBanner(),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(width: 180, height: 12),
                SizedBox(height: 14),
                _Bar(width: 240, height: 26),
                SizedBox(height: 10),
                _Bar(width: 160, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.centerId});

  final String centerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 36, color: AppColors.gris),
                const SizedBox(height: 12),
                const Text(
                  'Ce centre n\'est pas disponible.',
                  style: TextStyle(color: AppColors.slate, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Centre non vérifié ou introuvable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gris, fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.citizenBlood),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.rouge,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retour aux centres'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
