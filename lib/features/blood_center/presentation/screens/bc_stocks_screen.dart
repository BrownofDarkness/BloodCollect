import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/blood_stock_lot.dart';
import '../../domain/blood_center_stats.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_shared_widgets.dart';
import '../widgets/bc_shimmer.dart';

// Stocks : groupes repliables + lots, filtres, seuils éditables.
// Mock mutable via StateProviders ; étape 2 = streams Firestore.
class BcStocksScreen extends ConsumerStatefulWidget {
  const BcStocksScreen({super.key});

  @override
  ConsumerState<BcStocksScreen> createState() => _BcStocksScreenState();
}

class _BcStocksScreenState extends ConsumerState<BcStocksScreen> {
  static const _order = [
    BloodType.oPos,
    BloodType.oNeg,
    BloodType.aPos,
    BloodType.aNeg,
    BloodType.bPos,
    BloodType.bNeg,
    BloodType.abPos,
    BloodType.abNeg,
  ];

  int _tab = 0;
  // Aucune carte dépliée par défaut : l'utilisateur déplie au besoin.
  final Set<BloodType> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final lotsAsync = ref.watch(bcStockLotsProvider);
    final low = ref.watch(bcLowThresholdProvider);
    final unavailable = ref.watch(bcUnavailableThresholdProvider);
    final loading = lotsAsync.isLoading;
    final Object? error =
        lotsAsync.hasError ? lotsAsync.error : null;
    final lots = lotsAsync.asData?.value ?? const <BloodStockLot>[];
    final byType = unitsByBloodType(lots);
    final total = totalUnits(byType);
    final alertCount = byType.entries
        .where(
          (e) =>
              availabilityFor(
                units: e.value,
                low: low,
                unavailable: unavailable,
              ) !=
              StockAvailability.available,
        )
        .length;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.rouge,
          onRefresh: () => refreshBcData(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/bc/stocks/new'),
                    icon: const Icon(Icons.add_outlined, size: 20),
                    label: const Text(
                      'Ajouter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Stocks',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total poches · statut calculé selon les seuils définis '
                'par le centre',
                style: const TextStyle(
                  color: AppColors.gris,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.ligne.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _Tab(
                      label: 'Tous',
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    _Tab(
                      label: 'En alerte · $alertCount',
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                    _Tab(
                      label: 'Péremption',
                      selected: _tab == 2,
                      onTap: () => setState(() => _tab = 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BcErrorState(
                    message: '$error',
                    onRetry: () => refreshBcData(ref),
                  ),
                ),
              if (error == null)
                if (loading)
                  const ListShimmer()
              else if (_tab == 2)
                _ExpiryList(lots: lots)
              else
                for (final type in _order)
                  if (_tab == 0 ||
                      availabilityFor(
                            units: byType[type] ?? 0,
                            low: low,
                            unavailable: unavailable,
                          ) !=
                          StockAvailability.available)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GroupCard(
                        type: type,
                        units: byType[type] ?? 0,
                        low: low,
                        unavailable: unavailable,
                        lots: lots
                            .where((l) => l.bloodType == type)
                            .toList(),
                        expanded: _expanded.contains(type),
                        onToggle: () => setState(() {
                          if (_expanded.contains(type)) {
                            _expanded.remove(type);
                          } else {
                            _expanded.add(type);
                          }
                        }),
                        onDelete: (lot) => _confirmDelete(lot),
                      ),
                    ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ligne.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seuils d’alerte',
                            style: TextStyle(
                              color: AppColors.encre,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Ex. : limitée sous $low poches, '
                            'indisponible sous $unavailable',
                            style: const TextStyle(
                              color: AppColors.gris,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _editThresholds,
                      icon: const Icon(
                        Icons.tune_outlined,
                        color: AppColors.encre,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BloodStockLot lot) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Supprimer ${lot.lotReference} ?'),
        content: Text(
          'Le lot (${lot.quantity} poches) sera définitivement retiré '
          'des stocks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.rouge,
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref
            .read(bloodCenterDataRepositoryProvider)
            .deleteStockLot(lot.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Suppression impossible ($e).')),
          );
        }
      }
    }
  }

  Future<void> _editThresholds() async {
    final lowCtrl = TextEditingController(
      text: ref.read(bcLowThresholdProvider).toString(),
    );
    final unavCtrl = TextEditingController(
      text: ref.read(bcUnavailableThresholdProvider).toString(),
    );
    var error = '';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Seuils d’alerte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: lowCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Disponibilité limitée sous',
                  suffixText: 'poches',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unavCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Indisponible sous',
                  suffixText: 'poches',
                ),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  error,
                  style: const TextStyle(
                    color: AppColors.rouge,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final low = int.tryParse(lowCtrl.text) ?? -1;
                final unav = int.tryParse(unavCtrl.text) ?? -1;
                if (low <= 0 || unav < 0 || unav >= low) {
                  setDialogState(
                    () => error =
                        'Valeurs invalides (ex. limitée sous 20, '
                        'indisponible sous 5).',
                  );
                  return;
                }
                final centerId = ref
                    .read(myBloodCenterProvider)
                    .asData
                    ?.value
                    ?.id;
                if (centerId == null) {
                  setDialogState(
                    () => error = 'Centre introuvable.',
                  );
                  return;
                }
                try {
                  await ref
                      .read(bloodCenterDataRepositoryProvider)
                      .updateCenterThresholds(
                        centerId: centerId,
                        low: low,
                        unavailable: unav,
                      );
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } catch (e) {
                  setDialogState(
                    () => error = 'Enregistrement impossible ($e).',
                  );
                }
              },
              child: const Text(
                'Enregistrer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
    lowCtrl.dispose();
    unavCtrl.dispose();
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seuils mis à jour.')),
      );
    }
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.encre : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.encre,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  const _GroupCard({
    required this.type,
    required this.units,
    required this.low,
    required this.unavailable,
    required this.lots,
    required this.expanded,
    required this.onToggle,
    required this.onDelete,
  });

  final BloodType type;
  final int units;
  final int low;
  final int unavailable;
  final List<BloodStockLot> lots;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<BloodStockLot> onDelete;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _size;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _size = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
    );
    if (widget.expanded) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_GroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availability = availabilityFor(
      units: widget.units,
      low: widget.low,
      unavailable: widget.unavailable,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.type.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.rouge,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.units} poches',
                          style: const TextStyle(
                            color: AppColors.encre,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AvailabilityChip(availability: availability),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_outlined,
                      color: AppColors.gris,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _size,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const Divider(height: 1, color: AppColors.ligne),
                    for (final lot in widget.lots) ...[
                      _LotRow(
                        lot: lot,
                        onEdit: () => context.go('/bc/stocks/${lot.id}'),
                        onDelete: () => widget.onDelete(lot),
                      ),
                      const Divider(
                        height: 1,
                        color: AppColors.ligne,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(
                          '/bc/stocks/new?type=${Uri.encodeComponent(widget.type.label)}',
                        ),
                        icon: const Icon(Icons.add_outlined),
                        label: Text(
                          'Ajouter un lot ${widget.type.label}',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.encre,
                          minimumSize:
                              const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: AppColors.ligne,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({
    required this.lot,
    required this.onEdit,
    required this.onDelete,
  });

  final BloodStockLot lot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lot ${lot.lotReference} · ${lot.quantity} poches',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${productLabel(lot.productType)} · collecté '
                  '${formatShortDate(lot.collectionDate)} · expire '
                  '${formatShortDate(lot.expiryDate)}',
                  style: const TextStyle(
                    color: AppColors.gris,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.encre,
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppColors.ligne),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outlined, size: 20),
            color: AppColors.rouge,
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppColors.rouge),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Péremption : lots triés par expiration croissante.
class _ExpiryList extends StatelessWidget {
  const _ExpiryList({required this.lots});

  final List<BloodStockLot> lots;

  @override
  Widget build(BuildContext context) {
    final sorted = lots
        .where((l) => l.status == StockLotStatus.available)
        .toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    if (sorted.isEmpty) {
      return const BcEmptyState(
        icon: Icons.hourglass_empty_outlined,
        title: 'Aucun lot disponible',
        message: 'Ajoutez votre premier lot pour suivre les péremptions.',
      );
    }
    return Column(
      children: [
        for (final lot in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ligne),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      lot.bloodType.label,
                      style: const TextStyle(
                        color: AppColors.rouge,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lot ${lot.lotReference} · ${lot.quantity} poches',
                          style: const TextStyle(
                            color: AppColors.encre,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Expire ${formatShortDate(lot.expiryDate)}'
                          ' · dans ${daysUntil(lot.expiryDate)} j',
                          style: TextStyle(
                            color: daysUntil(lot.expiryDate) <= 7
                                ? AppColors.rouge
                                : AppColors.gris,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
