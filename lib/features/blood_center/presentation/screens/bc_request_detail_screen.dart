import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../domain/blood_center_stats.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_shared_widgets.dart';
import '../widgets/bc_stepper.dart';

// Détail d'une demande + décision du centre.
// Écrit via RequestsNotifier (mock) ; étape 2 = repository Firestore.
class BcRequestDetailScreen extends ConsumerStatefulWidget {
  const BcRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<BcRequestDetailScreen> createState() =>
      _BcRequestDetailScreenState();
}

enum _Decision { approve, partial, refuse, orient }

class _BcRequestDetailScreenState
    extends ConsumerState<BcRequestDetailScreen> {
  _Decision? _decision;
  int? _granted;
  final _messageController = TextEditingController();
  String? _decisionError;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Borne du partiel : min(demandé - 1, stock du centre).
  int _maxPartial(BloodRequest request, int stockUnits) {
    final demandBound =
        request.quantityNeeded > 1 ? request.quantityNeeded - 1 : 1;
    return min(demandBound, max(stockUnits, 1));
  }

  /// Dernière étape avant l'enregistrement : rappelle la décision choisie et
  /// prévient qu'elle est définitive.
  Future<bool> _confirm(BloodRequest request, int granted) async {
    final summary = switch (_decision!) {
      _Decision.approve =>
        'Approuver la demande : ${request.quantityNeeded} '
            'poche${request.quantityNeeded > 1 ? 's' : ''} '
            '${request.bloodType.label}.',
      _Decision.partial =>
        'Approuver partiellement : $granted poche${granted > 1 ? 's' : ''} '
            'sur ${request.quantityNeeded} ${request.bloodType.label}.',
      _Decision.refuse => 'Refuser la demande.',
      _Decision.orient => 'Orienter la demande vers un autre centre.',
    };
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.rouge,
          size: 32,
        ),
        title: const Text('Décision irréversible'),
        content: Text(
          '$summary\n\n'
          'Une fois validée, cette décision ne pourra plus être modifiée ni '
          'annulée. Le centre de santé en sera informé.',
          style: const TextStyle(
            color: AppColors.encre,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Revenir'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.rouge),
            child: const Text(
              'Confirmer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _validate() async {
    if (_decision == null) {
      setState(() => _decisionError = 'Choisissez une décision.');
      return;
    }
    final requests =
        ref.read(bcBloodRequestsProvider).asData?.value ?? const [];
    final request =
        requests.where((r) => r.id == widget.requestId).firstOrNull;
    if (request == null) return;

    // Garde-fous stock du centre de transfusion.
    final lots =
        ref.read(bcStockLotsProvider).asData?.value ?? const [];
    final stockUnits =
        unitsByBloodType(lots)[request.bloodType] ?? 0;
    final centerId =
        ref.read(myBloodCenterProvider).asData?.value?.id;
    if (centerId == null) {
      setState(
        () => _decisionError = 'Centre introuvable.',
      );
      return;
    }
    if (_decision == _Decision.approve &&
        stockUnits < request.quantityNeeded) {
      setState(
        () => _decisionError =
            'Stock insuffisant ($stockUnits poche${stockUnits > 1 ? 's' : ''} '
            'disponibles). Choisissez partiel, refus ou orientation.',
      );
      return;
    }
    if (_decision == _Decision.partial && stockUnits < 1) {
      setState(
        () => _decisionError =
            'Stock épuisé pour ce groupe : aucun accord possible.',
      );
      return;
    }

    // Une demande déjà traitée ne se rejoue pas (écran resté ouvert, etc.).
    if (!request.isAwaitingDecision) {
      setState(() => _decisionError = 'Cette demande a déjà été traitée.');
      return;
    }
    final granted = (_granted ?? _maxPartial(request, stockUnits))
        .clamp(1, _maxPartial(request, stockUnits));
    final confirmed = await _confirm(request, granted);
    if (!confirmed || !mounted) return;

    final message = _messageController.text.trim();
    final repo = ref.read(bloodCenterDataRepositoryProvider);
    BloodRequest decide({
      required RequestStatus status,
      int? quantityGranted,
      int? quantityFulfilled,
    }) {
      return BloodRequest(
        id: request.id,
        healthCenterId: request.healthCenterId,
        bloodType: request.bloodType,
        productType: request.productType,
        quantityNeeded: request.quantityNeeded,
        quantityFulfilled: quantityFulfilled ?? request.quantityFulfilled,
        patientReference: request.patientReference,
        priority: request.priority,
        status: status,
        bloodRouteStep: BloodRouteStep.completed,
        mobilizationRadius: request.mobilizationRadius,
        matchedBloodCenterId: centerId,
        quantityGranted: quantityGranted,
        responseMessage: message.isEmpty ? null : message,
        notes: request.notes,
        createdAt: request.createdAt,
        updatedAt: DateTime.now(),
        receivedAt: request.receivedAt,
        processedAt: DateTime.now(),
        expiresAt: request.expiresAt,
      );
    }

    try {
      switch (_decision!) {
        case _Decision.approve:
          await repo.updateBloodRequest(
            decide(
              status: RequestStatus.fulfilled,
              quantityGranted: request.quantityNeeded,
              quantityFulfilled: request.quantityNeeded,
            ),
          );
        case _Decision.partial:
          await repo.updateBloodRequest(
            decide(
              status: RequestStatus.partiallyFulfilled,
              quantityGranted: granted,
              quantityFulfilled: granted,
            ),
          );
        case _Decision.refuse:
          await repo.updateBloodRequest(
            decide(status: RequestStatus.cancelled),
          );
        case _Decision.orient:
          await repo.updateBloodRequest(
            decide(status: RequestStatus.oriented),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _decisionError = 'Enregistrement impossible ($e).',
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Décision enregistrée.')),
      );
      context.go('/bc/requests');
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(bcBloodRequestsProvider);
    final requests = requestsAsync.asData?.value ?? const <BloodRequest>[];
    final request =
        requests.where((r) => r.id == widget.requestId).firstOrNull;
    if (request == null) {
      return Scaffold(
        backgroundColor: AppColors.ivoire,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackButton(
                  onPressed: () => context.go('/bc/requests'),
                ),
                const SizedBox(height: 16),
                Text(
                  requestsAsync.isLoading
                      ? 'Chargement de la demande…'
                      : 'Demande introuvable.',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final names =
        ref.watch(bcHealthCenterNamesProvider).asData?.value ?? const {};
    final phones =
        ref.watch(bcHealthCenterPhonesProvider).asData?.value ?? const {};
    final lots =
        ref.watch(bcStockLotsProvider).asData?.value ?? const [];
    final low = ref.watch(bcLowThresholdProvider);
    final unavailable = ref.watch(bcUnavailableThresholdProvider);
    final byType = unitsByBloodType(lots);
    final stockUnits = byType[request.bloodType] ?? 0;
    final stockAvailability = availabilityFor(
      units: stockUnits,
      low: low,
      unavailable: unavailable,
    );

    // Partiel borné par le stock DU CENTRE DE TRANSFUSION : jamais plus que le demandé - 1, jamais plus que le stock.
    final maxGranted = _maxPartial(request, stockUnits);
    final stockBound = stockUnits <=
        (request.quantityNeeded > 1 ? request.quantityNeeded - 1 : 1);
    final canPartial = stockUnits >= 1;
    final canApprove = stockUnits >= request.quantityNeeded;

    // Choix utilisateur clampé, défaut = max. Dérivé pur : pas de mutation pendant le build, le stock peut baisser sans corruption.
    final granted = (_granted ?? maxGranted).clamp(1, maxGranted);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(
                    onPressed: () => context.go('/bc/requests'),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.rouge,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'CENTRE DE TRANSFUSION',
                          style: TextStyle(
                            color: AppColors.rouge,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Demande ${request.id}',
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ligne),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${request.bloodType.label} · '
                            '${request.quantityNeeded} '
                            'poche${request.quantityNeeded > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: AppColors.encre,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        PriorityChip(priority: request.priority),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.ivoire,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _Info(
                                  label: 'Demandeur',
                                  value: names[request.healthCenterId] ??
                                      'Centre de santé',
                                ),
                              ),
                              Expanded(
                                child: _Info(
                                  label: 'Référence',
                                  value: request.patientReference ?? '—',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _Info(
                                  label: 'Reçue',
                                  value: formatTimeAgo(
                                    request.createdAt,
                                  ).replaceFirst(
                                    'il y a ',
                                    'Il y a ',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _Info(
                                  label: 'Contact',
                                  value: phones[request.healthCenterId] ??
                                      '—',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (request.notes?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        request.notes!,
                        style: const TextStyle(
                          color: AppColors.encre,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.ligne,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Stock ${request.bloodType.label} actuel : '
                        '$stockUnits poches',
                        style: const TextStyle(
                          color: AppColors.encre,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    AvailabilityChip(availability: stockAvailability),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Demande déjà traitée : la décision est affichée en lecture seule.
              if (!request.isAwaitingDecision)
                _DecisionSummary(request: request)
              else ...[
              const Text(
                'DÉCISION',
                style: TextStyle(
                  color: AppColors.gris,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _DecisionCard(
                selected: _decision == _Decision.approve,
                color: AppColors.disponible,
                title: 'Approuver',
                description:
                    'Les ${request.quantityNeeded} poches sont réservées '
                    'pour le demandeur.',
                enabled: canApprove,
                warning: canApprove
                    ? null
                    : 'Stock insuffisant : $stockUnits poche${stockUnits > 1 ? 's' : ''} '
                        'disponible${stockUnits > 1 ? 's' : ''} au centre.',
                onTap: () => setState(() {
                  _decision = _Decision.approve;
                  _decisionError = null;
                }),
              ),
              const SizedBox(height: 12),
              _DecisionCard(
                selected: _decision == _Decision.partial,
                color: AppColors.limite,
                title: 'Approuver partiellement',
                description:
                    'Accorder une quantité inférieure à la demande, '
                    'dans la limite du stock du centre.',
                enabled: canPartial,
                warning: canPartial
                    ? null
                    : 'Stock épuisé pour ce groupe : aucun accord possible.',
                onTap: () => setState(() {
                  _decision = _Decision.partial;
                  _decisionError = null;
                }),
                child: _decision == _Decision.partial
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'Quantité accordée',
                            style: TextStyle(
                              color: AppColors.encre,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Une seule valeur possible : affichage fixe honnête
                          // qui dit POURQUOI (demande ou stock limitant).
                          if (maxGranted <= 1)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ivoire,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.ligne,
                                ),
                              ),
                              child: Text(
                                stockBound
                                    ? 'Stock ${request.bloodType.label} : '
                                        '$stockUnits poche${stockUnits > 1 ? 's' : ''} '
                                        'disponible${stockUnits > 1 ? 's' : ''} au centre'
                                    : '${request.quantityNeeded} poches '
                                        'demandées : $granted poche = '
                                        'accord partiel',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            else
                              BcStepper(
                                display:
                                    '$granted poche${granted > 1 ? 's' : ''}',
                                minusEnabled: granted > 1,
                                plusEnabled: granted < maxGranted,
                                onMinus: () =>
                                    setState(() => _granted = granted - 1),
                                onPlus: () =>
                                    setState(() => _granted = granted + 1),
                              ),
                        ],
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              _DecisionCard(
                selected: _decision == _Decision.refuse,
                color: AppColors.rouge,
                title: 'Refuser · indisponible',
                description:
                    'Le demandeur est notifié et peut être orienté.',
                onTap: () => setState(() {
                  _decision = _Decision.refuse;
                  _decisionError = null;
                }),
              ),
              const SizedBox(height: 12),
              _DecisionCard(
                selected: _decision == _Decision.orient,
                color: const Color(0xFF6D28D9),
                title: 'Orienter vers un autre centre',
                description:
                    'Transférer la demande à un centre disposant du stock.',
                onTap: () => setState(() {
                  _decision = _Decision.orient;
                  _decisionError = null;
                }),
              ),
              if (_decisionError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _decisionError!,
                  style: const TextStyle(
                    color: AppColors.rouge,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Message au centre de santé',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Ex. : 1 poche prête au retrait, 2e dans l’après-midi',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _validate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_outlined, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Valider la décision',
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Décision déjà rendue, en lecture seule : une demande traitée n'est plus
/// modifiable par le centre de transfusion.
class _DecisionSummary extends StatelessWidget {
  const _DecisionSummary({required this.request});

  final BloodRequest request;

  @override
  Widget build(BuildContext context) {
    final (title, color) = switch (request.progress) {
      RequestProgress.approved => ('Demande approuvée', AppColors.disponible),
      RequestProgress.partial => (
          'Demande approuvée partiellement',
          AppColors.limite,
        ),
      RequestProgress.refused => ('Demande refusée', AppColors.rouge),
      RequestProgress.oriented => (
          'Demande orientée vers un autre centre',
          AppColors.violet,
        ),
      RequestProgress.cancelled => (
          'Demande annulée par le centre de santé',
          AppColors.gris,
        ),
      _ => ('Demande expirée', AppColors.gris),
    };
    final granted = request.quantityGranted;
    final message = request.responseMessage;
    final decidedAt = request.decidedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DÉCISION RENDUE',
          style: TextStyle(
            color: AppColors.gris,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (decidedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Le ${Formatters.longDay(decidedAt)} à '
                  '${Formatters.hour(decidedAt)}',
                  style: const TextStyle(color: AppColors.gris, fontSize: 14),
                ),
              ],
              if (granted != null) ...[
                const SizedBox(height: 12),
                _Info(
                  label: 'Quantité accordée',
                  value: '$granted poche${granted > 1 ? 's' : ''} '
                      'sur ${request.quantityNeeded}',
                ),
              ],
              if (message != null && message.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Info(label: 'Message au centre de santé', value: message),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, color: AppColors.gris, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cette demande est traitée : la décision n’est plus '
                'modifiable.',
                style: TextStyle(color: AppColors.gris, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.gris, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.encre,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.selected,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
    this.child,
    this.enabled = true,
    this.warning,
  });

  final bool selected;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Widget? child;
  final bool enabled;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    final ink = enabled ? color : AppColors.gris;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.ligne,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    child == null && warning == null ? 16 : 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ink, width: 2),
                        ),
                        child: selected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ink,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              description,
                              style: const TextStyle(
                                color: AppColors.gris,
                                fontSize: 14,
                              ),
                            ),
                            if (warning != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                warning!,
                                style: const TextStyle(
                                  color: AppColors.rouge,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Hors de l'InkWell : les taps du stepper ne concurrencent
              // plus la sélection de la carte.
              if (child != null && enabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 16, 16),
                  child: child,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
