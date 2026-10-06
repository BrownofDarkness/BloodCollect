import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/campaign_registration.dart';
import '../../../../shared/presentation/providers/repository_providers.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/citizen_donate_providers.dart';
import '../providers/citizen_home_providers.dart';
import '../widgets/campaign_summary_card.dart';

// Onglet « Donner » — Je veux donner mon sang.
// Don volontaire : le citoyen s'inscrit aux collectes ouvertes et repère les
// centres de transfusion de sa ville. L'éligibilité est toujours vérifiée
// sur place, jamais dans l'application.
class CitizenDonateScreen extends ConsumerStatefulWidget {
  const CitizenDonateScreen({super.key});

  @override
  ConsumerState<CitizenDonateScreen> createState() =>
      _CitizenDonateScreenState();
}

class _CitizenDonateScreenState extends ConsumerState<CitizenDonateScreen> {
  // Collectes dont l'inscription ou l'annulation est en cours.
  final _busy = <String>{};

  Future<void> _run(
    String campaignId,
    Future<void> Function() action, {
    required String success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(campaignId));
    String message;
    try {
      await action();
      message = success;
    } catch (_) {
      message = 'Action impossible. Vérifiez votre connexion puis réessayez.';
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    if (mounted) setState(() => _busy.remove(campaignId));
  }

  void _showDetails(Campaign campaign) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      // Toute la largeur : sans cela la feuille se réduit à son contenu.
      builder: (sheetContext) => SizedBox(
        width: double.infinity,
        child: _CampaignDetailsSheet(
          campaign: campaign,
          onViewCenter: () {
            Navigator.of(sheetContext).pop();
            context.go('${AppRoutes.citizenBlood}/${campaign.bloodCenterId}');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider).value;
    // Les règles imposent donorId == UID du compte connecté.
    final donorId = ref.watch(authStateProvider).value?.id;
    final registrations = {
      for (final registration
          in ref.watch(myCampaignRegistrationsProvider).value ??
              const <CampaignRegistration>[])
        registration.campaignId: registration,
    };
    final registrationRepository =
        ref.watch(campaignRegistrationRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(
                    onPressed: () => context.go(AppRoutes.citizenHome),
                  ),
                  const Spacer(),
                  const BloodBadge(
                    label: 'Don volontaire',
                    icon: Icons.favorite_outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Je veux donner mon sang',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              _DonorProfileCard(
                user: user,
                onEdit: () => context.go(AppRoutes.citizenProfile),
              ),
              const SizedBox(height: 24),
              const Text('Collectes à venir', style: _headingStyle),
              const SizedBox(height: 12),
              ref.watch(upcomingCampaignsProvider).when(
                    skipLoadingOnReload: true,
                    loading: () => const _Loading(),
                    error: (_, _) => _Notice(
                      text: 'Collectes indisponibles. Vérifiez votre '
                          'connexion.',
                      actionLabel: 'Réessayer',
                      onAction: () => ref.invalidate(openCampaignsProvider),
                    ),
                    data: (campaigns) => campaigns.isEmpty
                        ? const _Notice(
                            text: 'Aucune collecte annoncée pour le moment.',
                          )
                        : Column(
                            children: [
                              for (final campaign in campaigns) ...[
                                CampaignSummaryCard(
                                  campaign: campaign,
                                  footer: _CampaignActions(
                                    registration: registrations[campaign.id],
                                    busy: _busy.contains(campaign.id),
                                    onJoin: donorId == null
                                        ? null
                                        : () => _run(
                                              campaign.id,
                                              () => registrationRepository
                                                  .register(
                                                campaignId: campaign.id,
                                                bloodCenterId:
                                                    campaign.bloodCenterId,
                                                donorId: donorId,
                                              ),
                                              success:
                                                  'Participation enregistrée.',
                                            ),
                                    onCancel: (registration) => _run(
                                      campaign.id,
                                      () => registrationRepository
                                          .cancel(registration.id),
                                      success: 'Participation annulée.',
                                    ),
                                    onDetails: () => _showDetails(campaign),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                  ),
              const SizedBox(height: 12),
              const Text(
                'Centres de transfusion à proximité',
                style: _headingStyle,
              ),
              const SizedBox(height: 12),
              ref.watch(nearbyBloodCentersProvider).when(
                    skipLoadingOnReload: true,
                    loading: () => const _Loading(),
                    error: (_, _) => const _Notice(
                      text: 'Centres indisponibles. Vérifiez votre connexion.',
                    ),
                    data: (centers) => centers.isEmpty
                        ? const _Notice(
                            text: 'Aucun centre de transfusion vérifié dans '
                                'votre ville.',
                          )
                        : Column(
                            children: [
                              for (final center in centers) ...[
                                _CenterTile(
                                  center: center,
                                  onTap: () => context.go(
                                    '${AppRoutes.citizenBlood}/${center.id}',
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                  ),
              const SizedBox(height: 6),
              const _EligibilityNotice(),
            ],
          ),
        ),
      ),
    );
  }

  static const _headingStyle = TextStyle(
    color: AppColors.encre,
    fontSize: 19,
    fontWeight: FontWeight.w800,
  );
}

/// « Mon profil donneur » : groupe et commune déclarés.
class _DonorProfileCard extends StatelessWidget {
  const _DonorProfileCard({required this.user, required this.onEdit});

  final AppUser? user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final commune = user?.commune ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mon profil donneur',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.bleu,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProfileTile(
                  label: 'Groupe',
                  value: user?.bloodType?.label ?? '—',
                  color: AppColors.rouge,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileTile(
                  label: 'Commune',
                  value: commune.isEmpty ? 'Non renseignée' : commune,
                  color: AppColors.encre,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ivoire,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gris, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Actions d'une collecte : s'inscrire, ou rappel de l'inscription avec
/// possibilité d'annuler.
class _CampaignActions extends StatelessWidget {
  const _CampaignActions({
    required this.registration,
    required this.busy,
    required this.onJoin,
    required this.onCancel,
    required this.onDetails,
  });

  final CampaignRegistration? registration;
  final bool busy;
  final VoidCallback? onJoin;
  final ValueChanged<CampaignRegistration> onCancel;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final registration = this.registration;
    final detailsButton = OutlinedButton(
      onPressed: onDetails,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.encre,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        side: const BorderSide(color: AppColors.ligne),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('Voir les détails', maxLines: 1),
      ),
    );

    if (registration != null && registration.isActive) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
            decoration: BoxDecoration(
              color: AppColors.disponibleLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.check, color: AppColors.disponible, size: 18),
                const SizedBox(width: 8),
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
                TextButton(
                  onPressed: busy ? null : () => onCancel(registration),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.disponible,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: detailsButton),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: busy ? null : onJoin,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.favorite_outline, size: 18),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Je participe', maxLines: 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: detailsButton),
      ],
    );
  }
}

class _CenterTile extends StatelessWidget {
  const _CenterTile({required this.center, required this.onTap});

  final BloodCenter center;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final opening = center.openingAt(DateTime.now());
    final closes = opening?.closesAtMinutes;
    // Horaires illisibles : on les affiche tels que le centre les a saisis.
    final String openingLabel;
    if (opening == null) {
      openingLabel = 'Lun – Ven · ${center.openingHoursWeekdays}';
    } else if (opening.isOpen && closes != null) {
      openingLabel = 'Ouvert · jusqu’à '
          '${closes ~/ 60}h${(closes % 60).toString().padLeft(2, '0')}';
    } else {
      openingLabel = 'Fermé actuellement';
    }
    final open = opening?.isOpen ?? false;
    final color = open ? AppColors.disponible : AppColors.slate;

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.roseLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.rouge,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      center.commune,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined, color: color, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            openingLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.encre),
            ],
          ),
        ),
      ),
    );
  }
}

// Règle fondamentale : l'application n'évalue jamais l'aptitude au don.
class _EligibilityNotice extends StatelessWidget {
  const _EligibilityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.encart,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.encre,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'L’éligibilité est vérifiée sur place.',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Le personnel du centre s’assure que vous pouvez donner '
                  'avant tout prélèvement.',
                  style: TextStyle(
                    color: AppColors.slate,
                    fontSize: 14,
                    height: 1.4,
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

/// Détails d'une collecte, en lecture seule.
class _CampaignDetailsSheet extends StatelessWidget {
  const _CampaignDetailsSheet({
    required this.campaign,
    required this.onViewCenter,
  });

  final Campaign campaign;
  final VoidCallback onViewCenter;

  @override
  Widget build(BuildContext context) {
    final commune = campaign.commune ?? '';
    final place = [campaign.locationName, commune]
        .where((part) => part.isNotEmpty)
        .join(', ');
    final description = campaign.description.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.title,
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
            for (final (label, value) in [
              ('Lieu', place),
              (
                'Date',
                Formatters.schedule(campaign.startDate, campaign.endDate),
              ),
              ('Objectif', '${campaign.targetUnits} dons'),
            ])
              if (value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.gris,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.encre,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onViewCenter,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.encre,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.ligne),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Voir le centre organisateur'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.rouge),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gris, fontSize: 14),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: AppColors.bleu),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
