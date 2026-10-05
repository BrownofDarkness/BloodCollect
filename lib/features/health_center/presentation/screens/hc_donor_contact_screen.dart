import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_candidate.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/domain/entities/donor_search_criteria.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';
import '../providers/hc_providers.dart';
import '../widgets/blood_request_form_fields.dart';
import '../widgets/hc_role_badge.dart';

/// Donneurs cochés sur l'écran de résultats, transmis à la mise en relation.
class DonorContactSelection {
  const DonorContactSelection({
    required this.criteria,
    required this.candidates,
  });

  final DonorSearchCriteria criteria;
  final List<DonorCandidate> candidates;
}

// Onglet « Donneurs » — Demande de mise en relation (par un centre de santé).
// Chaque donneur coché reçoit une donor_match_request (flux recherche
// directe, sans bloodRequestId). La référence interne n'est jamais montrée
// au donneur ; le numéro du centre ne lui est transmis qu'après acceptation,
// et seulement si le centre l'autorise.
class HcDonorContactScreen extends ConsumerStatefulWidget {
  const HcDonorContactScreen({super.key, required this.selection});

  /// null si l'écran est ouvert sans passer par la sélection.
  final DonorContactSelection? selection;

  @override
  ConsumerState<HcDonorContactScreen> createState() =>
      _HcDonorContactScreenState();
}

class _HcDonorContactScreenState extends ConsumerState<HcDonorContactScreen> {
  // Délai laissé au donneur pour répondre avant expiration.
  static const _responseWindow = Duration(hours: 24);
  static const _maxMessageLength = 300;

  final _formKey = GlobalKey<FormState>();
  final _reference = TextEditingController();
  final _message = TextEditingController();

  late Priority _priority =
      widget.selection?.criteria.priority ?? Priority.normal;
  bool _shareContact = true;
  bool _submitting = false;

  @override
  void dispose() {
    _reference.dispose();
    _message.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.hcDonors);

  Future<void> _send(String requesterId, DonorContactSelection selection) async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final message = _message.text.trim();
    setState(() => _submitting = true);
    try {
      final now = DateTime.now();
      await ref.read(donorMatchRepositoryProvider).createAll([
        for (final candidate in selection.candidates)
          DonorMatchRequest(
            id: '',
            requesterId: requesterId,
            donorId: candidate.donorId,
            bloodType: candidate.bloodType,
            priority: _priority,
            status: DonorMatchStatus.pending,
            shareContact: _shareContact,
            message: message.isEmpty ? null : message,
            internalReference: _reference.text.trim().toUpperCase(),
            notifiedAt: now,
            expiresAt: now.add(_responseWindow),
            createdAt: now,
          ),
      ]);
      if (mounted) {
        setState(() => _submitting = false);
        _showSuccess(selection.candidates.length);
      }
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

  Future<void> _showSuccess(int count) {
    final plural = count > 1;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.bleuLight,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Icon(
                  Icons.near_me_outlined,
                  color: AppColors.bleu,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                plural ? 'Demandes envoyées' : 'Demande envoyée',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count donneur${plural ? 's ont' : ' a'} été '
                'sollicité${plural ? 's' : ''}. Les coordonnées ne sont '
                'échangées qu’après acceptation.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.gris,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Referme résultats et formulaire : retour à la recherche.
                  if (mounted) context.go(AppRoutes.hcDonors);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleu,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Terminer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    // Les règles imposent requesterId == UID du compte connecté.
    final requesterId = ref.watch(authStateProvider).value?.id;
    final healthCenter = ref.watch(currentHealthCenterProvider).value;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBackButton(onPressed: _back),
                    const Spacer(),
                    const HcRoleBadge(),
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
                if (selection == null || selection.candidates.isEmpty)
                  _LostSelection(onBack: () => context.go(AppRoutes.hcDonors))
                else ...[
                  _SelectionSummary(selection: selection),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: 'Référence interne (non visible par le donneur)',
                    child: TextFormField(
                      controller: _reference,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      decoration: const InputDecoration(hintText: 'DOS-2291'),
                      validator: Validators.patientReference,
                    ),
                  ),
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
                  _ShareContactSwitch(
                    value: _shareContact,
                    onChanged: (v) => setState(() => _shareContact = v),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: _message,
                    builder: (context, message, _) => _DonorPreview(
                      centerName: healthCenter?.name,
                      zone: healthCenter?.commune,
                      bloodType: selection.criteria.bloodType,
                      priority: _priority,
                      message: message.text.trim(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: requesterId == null || _submitting
                        ? null
                        : () => _send(requesterId, selection),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.near_me_outlined, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  selection.candidates.length > 1
                                      ? 'Envoyer les demandes'
                                      : 'Envoyer la demande',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
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
      ),
    );
  }
}

/// « 2 donneurs O+ · Treichville · 1,2 km et 2,5 km ».
class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.selection});

  final DonorContactSelection selection;

  static const _maxAvatars = 3;

  static String _joinFr(List<String> parts) => parts.length < 2
      ? parts.join()
      : '${parts.take(parts.length - 1).join(', ')} et ${parts.last}';

  @override
  Widget build(BuildContext context) {
    final candidates = selection.candidates;
    final count = candidates.length;
    final bloodType = selection.criteria.bloodType.label;
    final communes = candidates
        .map((c) => c.commune)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    final distances = [
      for (final c in candidates)
        if (c.distanceKm != null) Formatters.distanceKm(c.distanceKm!),
    ];
    final details = [
      if (communes.isNotEmpty) communes.join(', '),
      if (distances.isNotEmpty) _joinFr(distances),
    ].join(' · ');
    // Au-delà de 3, la dernière pastille résume le reste (« +2 »).
    final circles = count > _maxAvatars ? _maxAvatars : count;
    final shown = count > _maxAvatars ? _maxAvatars - 1 : count;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48.0 + 34 * (circles - 1),
            height: 48,
            child: Stack(
              children: [
                for (var i = 0; i < shown; i++)
                  Positioned(left: 34.0 * i, child: _Avatar(label: bloodType)),
                if (count > _maxAvatars)
                  Positioned(
                    left: 34.0 * shown,
                    child: _Avatar(label: '+${count - shown}'),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count donneur${count > 1 ? 's' : ''} $bloodType',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: const TextStyle(
                      color: AppColors.gris,
                      fontSize: 14,
                      height: 1.3,
                    ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bleuLight,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.bleu,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ShareContactSwitch extends StatelessWidget {
  const _ShareContactSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partager mes coordonnées après acceptation',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Le numéro du centre est transmis seulement si le donneur '
                  'accepte.',
                  style: TextStyle(
                    color: AppColors.gris,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.bleu,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Aperçu de la sollicitation telle que le donneur la recevra.
/// La référence interne n'y figure jamais.
class _DonorPreview extends StatelessWidget {
  const _DonorPreview({
    required this.centerName,
    required this.zone,
    required this.bloodType,
    required this.priority,
    required this.message,
  });

  final String? centerName;
  final String? zone;
  final BloodType bloodType;
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
        color: AppColors.bleuLight,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.ligne.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    color: AppColors.encre,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEMANDE SOUMISE PAR UN CENTRE DE SANTÉ',
                        style: TextStyle(
                          color: AppColors.slate,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        centerName ?? 'Votre centre de santé',
                        style: const TextStyle(
                          color: AppColors.encre,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Un centre de santé recherche un donneur ${bloodType.label} '
            'pour un patient.',
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
          const Icon(Icons.person_search_outlined, color: AppColors.gris, size: 40),
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
            'Relancez une recherche et cochez les donneurs à solliciter.',
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
