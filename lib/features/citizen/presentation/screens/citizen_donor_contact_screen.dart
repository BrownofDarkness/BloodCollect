import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_candidate.dart';
import '../../../../shared/domain/entities/donor_contact_selection.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/presentation/providers/repository_providers.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../../shared/presentation/widgets/request_form_fields.dart';
import '../../../../shared/presentation/widgets/share_contact_switch.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';

// Onglet « Donneurs » — Demande de mise en relation (par un citoyen).
// Le citoyen sollicite le donneur choisi : une donor_match_request est créée
// (flux recherche directe, sans bloodRequestId). Son numéro n'est transmis
// au donneur qu'après acceptation, et seulement s'il l'autorise.
class CitizenDonorContactScreen extends ConsumerStatefulWidget {
  const CitizenDonorContactScreen({super.key, required this.selection});

  /// null si l'écran est ouvert sans passer par les résultats.
  final DonorContactSelection? selection;

  @override
  ConsumerState<CitizenDonorContactScreen> createState() =>
      _CitizenDonorContactScreenState();
}

class _CitizenDonorContactScreenState
    extends ConsumerState<CitizenDonorContactScreen> {
  static const _maxMessageLength = 300;

  final _message = TextEditingController();

  late Priority _priority =
      widget.selection?.criteria.priority ?? Priority.normal;
  bool _shareContact = true;
  bool _submitting = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  // Retour aux résultats, où la carte du donneur affiche l'état de la demande.
  void _back() => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.citizenDonors);

  Future<void> _send(String requesterId, DonorCandidate candidate) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = _message.text.trim();
    setState(() => _submitting = true);
    try {
      final now = DateTime.now();
      await ref.read(donorMatchRepositoryProvider).createAll([
        DonorMatchRequest(
          id: '',
          requesterId: requesterId,
          donorId: candidate.donorId,
          bloodType: candidate.bloodType,
          priority: _priority,
          status: DonorMatchStatus.pending,
          shareContact: _shareContact,
          message: message.isEmpty ? null : message,
          notifiedAt: now,
          expiresAt: now.add(DonorMatchRequest.responseWindow),
          createdAt: now,
        ),
      ]);
      messenger.showSnackBar(
        const SnackBar(content: Text('Demande envoyée au donneur.')),
      );
      if (mounted) _back();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Envoi impossible. Vérifiez votre connexion puis réessayez.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final candidate = selection == null || selection.candidates.isEmpty
        ? null
        : selection.candidates.first;
    // Les règles imposent requesterId == UID du compte connecté.
    final requesterId = ref.watch(authStateProvider).value?.id;
    final requesterCommune = ref.watch(currentAppUserProvider).value?.commune;

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
                  AppBackButton(onPressed: _back),
                  const Spacer(),
                  const PersonBadge(
                    label: 'Personne',
                    icon: Icons.person_outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Demande de mise en relation',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              if (candidate == null)
                _LostSelection(
                  onBack: () => context.go(AppRoutes.citizenDonors),
                )
              else ...[
                _DonorSummary(candidate: candidate),
                const SizedBox(height: 24),
                const SectionTitle('NIVEAU D’URGENCE'),
                const SizedBox(height: 12),
                PrioritySelector(
                  value: _priority,
                  accent: AppColors.bleu,
                  onChanged: (v) => setState(() => _priority = v),
                ),
                const SizedBox(height: 20),
                LabeledField(
                  label: 'Message au donneur (facultatif)',
                  child: TextFormField(
                    controller: _message,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxMessageLength),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Ex. : merci de vous présenter au centre de '
                          'transfusion le plus proche',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShareContactSwitch(
                  value: _shareContact,
                  onChanged: (v) => setState(() => _shareContact = v),
                  description: 'Le numéro du demandeur est transmis '
                      'seulement si le donneur accepte.',
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder(
                  valueListenable: _message,
                  builder: (context, message, _) => _DonorPreview(
                    bloodType: candidate.bloodType,
                    zone: requesterCommune,
                    priority: _priority,
                    message: message.text.trim(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: requesterId == null || _submitting
                      ? null
                      : () => _send(requesterId, candidate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bleu,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.near_me_outlined, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Envoyer la demande',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DonorSummary extends StatelessWidget {
  const _DonorSummary({required this.candidate});

  final DonorCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final distance = candidate.distanceKm;
    final place = [
      if (candidate.commune.isNotEmpty) candidate.commune,
      if (distance != null) Formatters.distanceKm(distance),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.bleuSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              candidate.bloodType.label,
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
                const Text(
                  'Donneur potentiel',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    place,
                    style: const TextStyle(color: AppColors.gris, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aperçu de la demande telle que le donneur la recevra. Le demandeur y
/// reste anonyme : « une personne », située par sa seule commune.
class _DonorPreview extends StatelessWidget {
  const _DonorPreview({
    required this.bloodType,
    required this.zone,
    required this.priority,
    required this.message,
  });

  final BloodType bloodType;
  final String? zone;
  final Priority priority;
  final String message;

  @override
  Widget build(BuildContext context) {
    final urgency = switch (priority) {
      Priority.normal => 'Urgence normale',
      Priority.elevated => 'Urgence élevée',
      Priority.vital => 'Urgence vitale',
    };
    final zone = this.zone;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bleuSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.bleu, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'CE QUE VERRA LE DONNEUR',
                  style: TextStyle(
                    color: AppColors.bleu,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Une personne recherche un donneur ${bloodType.label}, votre '
            'groupe sanguin.',
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '« $message »',
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            [
              if (zone != null && zone.isNotEmpty) zone,
              urgency,
              'Don dans un centre agréé uniquement',
            ].join(' · '),
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LostSelection extends StatelessWidget {
  const _LostSelection({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_outlined,
            color: AppColors.gris,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun donneur sélectionné',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Relancez une recherche et choisissez le donneur à contacter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gris, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.encre,
              minimumSize: const Size(0, 44),
              side: const BorderSide(color: AppColors.ligne),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Chercher un donneur'),
          ),
        ],
      ),
    );
  }
}
