import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/back_control.dart';
import '../../../../core/constants/app_enums.dart';
import '../../data/mock/commune_distances.dart';
import '../../../../shared/presentation/models/enum_labels.dart';
import '../../../../shared/presentation/widgets/app_snackbar.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../providers/donor_providers.dart';

/// Écran "Demande reçue" — vue du DONNEUR qui répond à une DonorMatchRequest.
/// Route suggérée : /citizen/match-request/:requestId
///
/// NOTE MODÈLE : DonorMatchStatus n'a pas de valeur "indisponible" distincte
/// de "refusée". Les boutons "Je suis indisponible" et "Refuser" écrivent
/// donc tous les deux `declined` côté repository — seul le texte du
/// snackbar diffère. À trancher avec l'équipe si la distinction doit être
/// tracée (ajout d'une valeur d'enum ou d'un champ `declineReason`).
class MatchRequestReceivedScreen extends ConsumerStatefulWidget {
  const MatchRequestReceivedScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<MatchRequestReceivedScreen> createState() =>
      _MatchRequestReceivedScreenState();
}

enum _Action { accept, unavailable, decline }

class _MatchRequestReceivedScreenState
    extends ConsumerState<MatchRequestReceivedScreen> {
  _Action? _pendingAction;

  Future<void> _respond(_Action action) async {
    setState(() => _pendingAction = action);
    final status = switch (action) {
      _Action.accept => DonorMatchStatus.accepted,
      _Action.unavailable =>
        DonorMatchStatus.declined, // cf. note modèle ci-dessus
      _Action.decline => DonorMatchStatus.declined,
    };
    try {
      await ref
          .read(donorSearchRepositoryProvider)
          .respondToRequest(widget.requestId, status);
      if (!mounted) return;
      final label = switch (action) {
        _Action.accept => 'Réponse envoyée : vous avez accepté.',
        _Action.unavailable => 'Réponse envoyée : indisponible pour le moment.',
        _Action.decline => 'Demande refusée.',
      };
      AppSnackbar.success(context, label);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, "Échec de l'envoi. Réessayez.");
    } finally {
      if (mounted) setState(() => _pendingAction = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(
      incomingMatchRequestProvider(widget.requestId),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ivoire,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: BackControl(onBack: () => context.go(AppRoutes.citizenHome)),
        title: const PersonBadge(label: 'Vous êtes donneur'),
      ),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: 'Impossible de charger la demande.',
          onRetry: () =>
              ref.invalidate(incomingMatchRequestProvider(widget.requestId)),
        ),
        data: (request) {
          final requesterAsync = ref.watch(
            requesterInfoProvider(request.requesterId),
          );
          final isBusy = _pendingAction != null;

          return requesterAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ErrorState(
              message: "Impossible de charger l'émetteur de la demande.",
              onRetry: () =>
                  ref.invalidate(requesterInfoProvider(request.requesterId)),
            ),
            data: (requester) {
              final distanceKm = CommuneDistances.forCommune(
                requester.commune,
                seedKey: request.id,
              );
              final nearestCenterAsync = ref.watch(
                nearestCenterProvider(requester.commune),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demande reçue',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.ligne),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ivoire,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  requester.isHealthCenter
                                      ? 'DEMANDE SOUMISE PAR UN CENTRE DE SANTÉ'
                                      : 'DEMANDE SOUMISE PAR UN PARTICULIER',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  requester.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            requester.isHealthCenter
                                ? 'Un centre de santé recherche un donneur ${request.bloodType.label} pour un patient.'
                                : 'Une personne recherche un donneur ${request.bloodType.label}.',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text:
                                '${requester.commune} · à environ ${distanceKm.toStringAsFixed(1)} km',
                          ),
                          _InfoRow(
                            icon: Icons.priority_high,
                            text:
                                'Urgence ${request.priority.label.toLowerCase()}',
                          ),
                          _InfoRow(
                            icon: Icons.schedule,
                            text:
                                'Reçue il y a ${DateTime.now().difference(request.notifiedAt).inMinutes} min',
                          ),
                          if (request.message != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bleuLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '« ${request.message} »',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.ligne.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Accepter ne veut pas dire donner tout de suite. Le don se fait "
                              "uniquement dans un centre de transfusion agréé, après vérification "
                              "de votre éligibilité.",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    nearestCenterAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (center) {
                        if (center == null) return const SizedBox.shrink();
                        final centerDistance = CommuneDistances.forCommune(
                          center.commune,
                          seedKey: center.id,
                        );
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.ligne),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.apartment_outlined,
                                color: AppColors.rouge,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Centre le plus proche',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${center.name} · ${centerDistance.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isBusy
                            ? null
                            : () => _respond(_Action.accept),
                        icon: _pendingAction == _Action.accept
                            ? const _ButtonSpinner()
                            : const Icon(Icons.check),
                        label: const Text('Accepter'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () => _respond(_Action.unavailable),
                        child: _pendingAction == _Action.unavailable
                            ? const _ButtonSpinner(color: AppColors.encre)
                            : const Text('Je suis indisponible pour le moment'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: isBusy
                            ? null
                            : () => _respond(_Action.decline),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.rouge,
                        ),
                        child: _pendingAction == _Action.decline
                            ? const _ButtonSpinner(color: AppColors.rouge)
                            : const Text('Refuser'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({this.color = Colors.white});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.indisponible,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
