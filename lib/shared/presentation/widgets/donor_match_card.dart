import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/launchers.dart';
import '../../domain/entities/donor_match_request.dart';
import '../providers/donor_search_providers.dart';
import 'donor_match_status_style.dart';

/// Sollicitation envoyée à un donneur et sa réponse. Le donneur reste
/// anonyme ; la référence interne permet au centre de retrouver le dossier.
class DonorMatchCard extends StatelessWidget {
  const DonorMatchCard({super.key, required this.match, required this.now});

  final DonorMatchRequest match;
  final DateTime now;

  String get _outcome {
    final respondedAt = match.respondedAt;
    final answered = respondedAt == null
        ? ''
        : ' ${Formatters.timeOrDate(respondedAt, now: now)}';
    return switch (match.statusAt(now)) {
      DonorMatchStatus.pending =>
        'Réponse attendue avant '
            '${Formatters.timeOrDate(match.expiresAt, now: now)}',
      DonorMatchStatus.accepted => 'A accepté$answered',
      DonorMatchStatus.declined => 'A décliné$answered',
      DonorMatchStatus.expired => 'Sans réponse dans le délai',
      DonorMatchStatus.completed => 'Don validé en centre agréé',
    };
  }

  @override
  Widget build(BuildContext context) {
    final status = match.statusAt(now);
    final reference = match.internalReference;
    final urgency = switch (match.priority) {
      Priority.normal => 'Urgence normale',
      Priority.elevated => 'Urgence élevée',
      Priority.vital => 'Urgence vitale',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          _header(status, reference, urgency),
          // Coordonnées lues seulement une fois la demande acceptée.
          if (status == DonorMatchStatus.accepted ||
              status == DonorMatchStatus.completed) ...[
            const SizedBox(height: 12),
            _DonorContactSection(donorId: match.donorId),
          ],
        ],
      ),
    );
  }

  Widget _header(DonorMatchStatus status, String? reference, String urgency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.bleuLight,
            shape: BoxShape.circle,
          ),
          child: Text(
            match.bloodType.label,
            style: const TextStyle(
              color: AppColors.bleu,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  'Donneur potentiel',
                  if (reference != null && reference.isNotEmpty) reference,
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
                '$urgency · envoyée '
                '${Formatters.relative(match.createdAt, now: now)}',
                style: const TextStyle(color: AppColors.gris, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, color: status.color, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        status.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: status.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _outcome,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Nom et téléphone du donneur, avec un bouton d'appel.
class _DonorContactSection extends ConsumerWidget {
  const _DonorContactSection({required this.donorId});

  final String donorId;

  Future<void> _call(BuildContext context, String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await Launchers.call(phone)) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Appel impossible depuis cet appareil.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(donorContactProvider(donorId));
    final contact = contactAsync.value;

    final failed = contact == null && contactAsync.hasError;
    final String title;
    final String detail;
    if (contact != null) {
      title = contact.fullName.isEmpty ? 'Donneur' : contact.fullName;
      detail = contact.hasPhone ? contact.phone! : 'Téléphone non renseigné';
    } else if (failed) {
      title = 'Coordonnées non chargées';
      detail = 'Vérifiez votre connexion, puis réessayez.';
    } else if (contactAsync.isLoading) {
      title = 'Coordonnées du donneur';
      detail = 'Chargement…';
    } else {
      // Lecture réussie, mais aucun profil ne correspond.
      title = 'Donneur introuvable';
      detail = 'Son compte n’existe plus ou n’est plus accessible.';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.disponibleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            color: AppColors.disponible,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(color: AppColors.slate, fontSize: 13),
                ),
              ],
            ),
          ),
          if (contact != null && contact.hasPhone)
            TextButton.icon(
              onPressed: () => _call(context, contact.phone!),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.disponible,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('Appeler'),
            ),
          if (failed)
            TextButton(
              onPressed: () => ref.invalidate(donorContactProvider(donorId)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.disponible,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }
}
