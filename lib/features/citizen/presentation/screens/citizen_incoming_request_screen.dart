import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/launchers.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/domain/entities/match_requester.dart';
import '../../../../shared/presentation/providers/repository_providers.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../providers/citizen_request_providers.dart';

// Côté donneur — Demande reçue.
// Le citoyen sollicité voit qui le demande (un centre est nommé, un
// particulier reste anonyme) et répond. Accepter n'engage pas à donner sur
// place : le don se fait toujours en centre agréé.
class CitizenIncomingRequestScreen extends ConsumerStatefulWidget {
  const CitizenIncomingRequestScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<CitizenIncomingRequestScreen> createState() =>
      _CitizenIncomingRequestScreenState();
}

class _CitizenIncomingRequestScreenState
    extends ConsumerState<CitizenIncomingRequestScreen> {
  bool _responding = false;

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.citizenHome);

  Future<void> _respond(DonorMatchStatus status) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _responding = true);
    try {
      await ref
          .read(donorMatchRepositoryProvider)
          .respond(widget.requestId, status);
      // L'écran passe de lui-même à l'état « répondu » : la demande est
      // suivie en temps réel.
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Réponse non enregistrée. Vérifiez votre connexion puis '
            'réessayez.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _responding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync =
        ref.watch(incomingDonorRequestProvider(widget.requestId));

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
                    label: 'Vous êtes donneur',
                    icon: Icons.person_outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Demande reçue',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              requestAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.bleu),
                  ),
                ),
                error: (_, _) => _Message(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chargement impossible',
                  body: 'Vérifiez votre connexion puis réessayez.',
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(
                    incomingDonorRequestProvider(widget.requestId),
                  ),
                ),
                data: (request) => request == null
                    ? _Message(
                        icon: Icons.search_off_outlined,
                        title: 'Demande introuvable',
                        body: 'Cette demande n’existe plus.',
                        actionLabel: 'Retour',
                        onAction: _back,
                      )
                    : _RequestBody(
                        request: request,
                        responding: _responding,
                        onRespond: _respond,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestBody extends ConsumerWidget {
  const _RequestBody({
    required this.request,
    required this.responding,
    required this.onRespond,
  });

  final DonorMatchRequest request;
  final bool responding;
  final ValueChanged<DonorMatchStatus> onRespond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requester =
        ref.watch(matchRequesterProvider(request.requesterId)).value;
    final status = request.statusAt(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequestCard(request: request, requester: requester),
        const SizedBox(height: 16),
        const _AcceptanceNotice(),
        const SizedBox(height: 16),
        const _NearestCenterCard(),
        const SizedBox(height: 16),
        if (status == DonorMatchStatus.pending)
          _ResponseButtons(responding: responding, onRespond: onRespond)
        else
          _Outcome(
            status: status,
            // Coordonnées montrées seulement après acceptation, et si le
            // demandeur a autorisé leur partage.
            requester: status == DonorMatchStatus.accepted &&
                    request.shareContact
                ? requester
                : null,
          ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.requester});

  final DonorMatchRequest request;

  /// null tant que l'identité du demandeur charge.
  final MatchRequester? requester;

  @override
  Widget build(BuildContext context) {
    final byCenter = requester?.isHealthCenter ?? false;
    final bloodType = request.bloodType.label;
    final commune = requester?.commune ?? '';
    final message = request.message?.trim() ?? '';
    final urgency = switch (request.priority) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.ivoire,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.encart,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    byCenter ? Icons.business_outlined : Icons.person_outline,
                    color: AppColors.encre,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        byCenter
                            ? 'DEMANDE SOUMISE PAR UN CENTRE DE SANTÉ'
                            : 'DEMANDE SOUMISE PAR UN PARTICULIER',
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        byCenter
                            ? requester?.centerName ?? 'Centre de santé'
                            : 'Identité non communiquée',
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
          const SizedBox(height: 14),
          Text(
            byCenter
                ? 'Un centre de santé recherche un donneur $bloodType pour '
                    'un patient.'
                : 'Une personne recherche un donneur $bloodType, votre '
                    'groupe sanguin.',
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          if (commune.isNotEmpty)
            _InfoLine(icon: Icons.location_on_outlined, text: commune),
          _InfoLine(icon: Icons.warning_amber_outlined, text: urgency),
          _InfoLine(
            icon: Icons.schedule_outlined,
            text: 'Reçue ${Formatters.relative(request.createdAt)}',
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bleuSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '« $message »',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.slate, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.slate, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// Règle fondamentale du projet, rappelée avant la réponse.
class _AcceptanceNotice extends StatelessWidget {
  const _AcceptanceNotice();

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
                  'Accepter ne veut pas dire donner tout de suite.',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Le don se fait uniquement dans un centre de transfusion '
                  'agréé, après vérification de votre éligibilité.',
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

/// Centre de transfusion où se rendre pour donner. Masqué si aucun centre
/// vérifié n'est connu dans la ville du citoyen.
class _NearestCenterCard extends ConsumerWidget {
  const _NearestCenterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final center = ref.watch(nearestBloodCenterProvider).value;
    if (center == null) return const SizedBox.shrink();

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.ligne),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('${AppRoutes.citizenBlood}/${center.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.roseLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.rouge,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Centre le plus proche',
                      style: TextStyle(color: AppColors.gris, fontSize: 13),
                    ),
                    Text(
                      '${center.name} · ${center.commune}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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

class _ResponseButtons extends StatelessWidget {
  const _ResponseButtons({required this.responding, required this.onRespond});

  final bool responding;
  final ValueChanged<DonorMatchStatus> onRespond;

  @override
  Widget build(BuildContext context) {
    // Le modèle n'a qu'un statut de refus : « indisponible » et « refuser »
    // enregistrent tous deux `declined`.
    VoidCallback? respond(DonorMatchStatus status) =>
        responding ? null : () => onRespond(status);

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: respond(DonorMatchStatus.accepted),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bleu,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: responding
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.check, size: 20),
          label: const Text('Accepter'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: respond(DonorMatchStatus.declined),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.encre,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.ligne),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text(
            'Je suis indisponible pour le moment',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: respond(DonorMatchStatus.declined),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.rouge,
            minimumSize: const Size(double.infinity, 48),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Refuser'),
        ),
      ],
    );
  }
}

/// État d'une demande à laquelle on ne peut plus répondre.
class _Outcome extends StatelessWidget {
  const _Outcome({required this.status, required this.requester});

  final DonorMatchStatus status;

  /// Demandeur dont les coordonnées peuvent être affichées, sinon null.
  final MatchRequester? requester;

  Future<void> _call(BuildContext context, String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await Launchers.call(phone)) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Appel impossible depuis cet appareil.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (title, body, color, background, icon) = switch (status) {
      DonorMatchStatus.accepted => (
          'Vous avez accepté cette demande',
          'Rendez-vous dans un centre de transfusion agréé pour '
              'l’évaluation et le don.',
          AppColors.disponible,
          AppColors.disponibleLight,
          Icons.check_circle_outline,
        ),
      DonorMatchStatus.declined => (
          'Vous avez décliné cette demande',
          'Le demandeur en est informé. Merci d’avoir répondu.',
          AppColors.slate,
          AppColors.encart,
          Icons.block,
        ),
      DonorMatchStatus.completed => (
          'Don effectué',
          'Merci : votre don a été validé en centre agréé.',
          AppColors.disponible,
          AppColors.disponibleLight,
          Icons.volunteer_activism_outlined,
        ),
      // `pending` n'arrive pas ici : l'écran affiche alors les boutons.
      DonorMatchStatus.expired || DonorMatchStatus.pending => (
          'Cette demande a expiré',
          'Le délai de réponse est dépassé.',
          AppColors.slate,
          AppColors.encart,
          Icons.timer_off_outlined,
        ),
    };
    final requester = this.requester;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
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
          if (requester != null && requester.hasPhone) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _call(context, requester.phone!),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.disponible,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.disponible),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: Text('Appeler le demandeur · ${requester.phone}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

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
          Icon(icon, color: AppColors.gris, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gris,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.encre,
              minimumSize: const Size(0, 44),
              side: const BorderSide(color: AppColors.ligne),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
