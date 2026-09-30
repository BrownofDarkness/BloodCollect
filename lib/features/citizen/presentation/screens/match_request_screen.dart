import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import '../../../../shared/presentation/models/enum_labels.dart';
import '../../../../shared/presentation/widgets/app_snackbar.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../../shared/presentation/widgets/urgency_selector.dart';
import '../providers/donor_providers.dart';

/// Écran 5 — "Demande de mise en relation". Reçoit le DonorSearchCandidate
/// sélectionné à l'écran précédent. Retourne `true` au pop si l'envoi a
/// réussi (la DonorMatchRequest créée elle-même n'est pas nécessaire côté
/// UI ici, mais reste dispo via le repository si besoin plus tard).
class MatchRequestScreen extends ConsumerStatefulWidget {
  const MatchRequestScreen({super.key, required this.candidate});

  final DonorSearchCandidate candidate;

  @override
  ConsumerState<MatchRequestScreen> createState() => _MatchRequestScreenState();
}

class _MatchRequestScreenState extends ConsumerState<MatchRequestScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = matchRequestFormProvider(widget.candidate.donorId);
    final form = ref.watch(formProvider);
    final notifier = ref.read(formProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ivoire,
        elevation: 0,
        title: const PersonBadge(label: 'Personne'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demande de mise en\nrelation',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ligne),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.bleuLight,
                    child: Text(
                      widget.candidate.bloodType.label,
                      style: const TextStyle(
                        color: AppColors.bleu,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donneur potentiel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${widget.candidate.commune} · ${widget.candidate.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Label("NIVEAU D'URGENCE"),
            const SizedBox(height: 8),
            UrgencySelector(
              value: form.priority,
              onChanged: notifier.setPriority,
            ),
            const SizedBox(height: 20),
            const _Label('MESSAGE AU DONNEUR (FACULTATIF)'),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              onChanged: notifier.setMessage,
              decoration: InputDecoration(
                hintText:
                    'Ex. : merci de vous présenter au centre de transfusion le plus proche',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.ligne),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.ligne),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ligne),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Partager mes coordonnées après acceptation',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Le numéro du demandeur est transmis seulement si le donneur accepte.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: form.shareContact,
                    onChanged: notifier.setShareContact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bleuLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: AppColors.bleu,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'CE QUE VERRA LE DONNEUR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bleu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Une personne recherche un donneur ${widget.candidate.bloodType.label}, votre groupe sanguin.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.candidate.commune} · Urgence ${form.priority.label.toLowerCase()} · '
                    'Don dans un centre agréé uniquement',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: form.isSubmitting
                    ? null
                    : () async {
                        try {
                          await notifier.submit(widget.candidate.donorId);
                          if (!context.mounted) return;
                          context.pop(true);
                        } catch (e) {
                          if (!context.mounted) return;
                          AppSnackbar.error(
                            context,
                            "Échec de l'envoi. Réessayez.",
                          );
                        }
                      },
                icon: form.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(
                  form.isSubmitting ? 'Envoi en cours…' : 'Envoyer la demande',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}
