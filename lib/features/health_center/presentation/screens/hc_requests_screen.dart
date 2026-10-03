import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../providers/hc_providers.dart';
import '../widgets/blood_request_card.dart';
import '../widgets/hc_role_badge.dart';

enum _RequestsTab {
  ongoing('En cours', 'Aucune demande en cours'),
  processed('Traitées', 'Aucune demande traitée'),
  history('Historique', 'Aucune demande annulée ou expirée');

  const _RequestsTab(this.label, this.emptyTitle);

  final String label;
  final String emptyTitle;

  bool contains(BloodRequest request) {
    final progress = request.progress;
    return switch (this) {
      // Une demande orientée reste à suivre : le besoin n'est pas couvert.
      _RequestsTab.ongoing => progress.isOngoing,
      _RequestsTab.processed => progress.isProcessed,
      _RequestsTab.history => progress == RequestProgress.cancelled ||
          progress == RequestProgress.expired,
    };
  }
}

// Onglet « Demandes » — Mes demandes de sang.
// Suivi en temps réel des demandes du centre de santé connecté :
// Transmise → Reçue → En cours de traitement → Décision.
class HcRequestsScreen extends ConsumerStatefulWidget {
  const HcRequestsScreen({super.key});

  @override
  ConsumerState<HcRequestsScreen> createState() => _HcRequestsScreenState();
}

class _HcRequestsScreenState extends ConsumerState<HcRequestsScreen> {
  _RequestsTab _tab = _RequestsTab.ongoing;
  // Carte dépliée. Tant que l'utilisateur n'a rien touché, c'est la 1re.
  String? _expandedId;
  bool _expansionChosen = false;

  void _selectTab(_RequestsTab tab) => setState(() {
        _tab = tab;
        _expandedId = null;
        _expansionChosen = false;
      });

  void _toggle(String requestId, {required bool expanded}) => setState(() {
        _expandedId = expanded ? null : requestId;
        _expansionChosen = true;
      });

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(healthCenterRequestsProvider);
    final ongoingCount = requestsAsync.value
            ?.where(_RequestsTab.ongoing.contains)
            .length ??
        0;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HcRoleBadge(),
              const SizedBox(height: 12),
              const Text(
                'Mes demandes de sang',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              _TabBar(
                selected: _tab,
                ongoingCount: ongoingCount,
                onSelected: _selectTab,
              ),
              const SizedBox(height: 16),
              requestsAsync.when(
                // Une mise à jour ne doit pas faire clignoter la liste.
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.rouge),
                  ),
                ),
                error: (_, _) => _Message(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chargement impossible',
                  body: 'Vérifiez votre connexion puis réessayez.',
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(healthCenterRequestsProvider),
                ),
                data: (requests) {
                  final items = requests.where(_tab.contains).toList();
                  if (items.isEmpty) {
                    final ongoing = _tab == _RequestsTab.ongoing;
                    return _Message(
                      icon: Icons.inbox_outlined,
                      title: _tab.emptyTitle,
                      body: ongoing
                          ? 'Trouvez un centre de transfusion pour '
                              'transmettre un besoin.'
                          : 'Les demandes concernées apparaîtront ici.',
                      actionLabel: ongoing ? 'Trouver du sang' : null,
                      onAction: ongoing
                          ? () => context.go(AppRoutes.hcBlood)
                          : null,
                    );
                  }
                  final expandedId =
                      _expansionChosen ? _expandedId : items.first.id;
                  return Column(
                    children: [
                      for (final request in items) ...[
                        BloodRequestCard(
                          request: request,
                          expanded: request.id == expandedId,
                          onTap: () => _toggle(
                            request.id,
                            expanded: request.id == expandedId,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.selected,
    required this.ongoingCount,
    required this.onSelected,
  });

  final _RequestsTab selected;
  final int ongoingCount;
  final ValueChanged<_RequestsTab> onSelected;

  String _label(_RequestsTab tab) =>
      tab == _RequestsTab.ongoing && ongoingCount > 0
          ? '${tab.label} · $ongoingCount'
          : tab.label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ligne.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final tab in _RequestsTab.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: tab == selected,
                child: Material(
                  color:
                      tab == selected ? AppColors.encre : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelected(tab),
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              _label(tab),
                              style: TextStyle(
                                color: tab == selected
                                    ? Colors.white
                                    : AppColors.slate,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

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
          if (actionLabel != null) ...[
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
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
