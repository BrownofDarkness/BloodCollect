import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/blood_stock_lot.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_shared_widgets.dart';
import '../widgets/bc_stepper.dart';

// Formulaire lot (créer / modifier).
// Save/delete via LotsNotifier : dashboard + stocks recalculent aussitôt.
class BcLotFormScreen extends ConsumerStatefulWidget {
  const BcLotFormScreen({super.key, this.lotId, this.initialType});

  final String? lotId;
  final String? initialType;

  @override
  ConsumerState<BcLotFormScreen> createState() => _BcLotFormScreenState();
}

class _BcLotFormScreenState extends ConsumerState<BcLotFormScreen> {
  static const _provenances = [
    'Collecte au centre',
    'Don spontané',
    'Campagne',
    'Autre',
  ];

  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();
  final _noteController = TextEditingController();

  bool get _editing => widget.lotId != null;
  bool _initDone = false;

  BloodType _bloodType = BloodType.oNeg;
  ProductType _product = ProductType.wholeBlood;
  int _quantity = 1;
  DateTime? _collectedAt;
  DateTime? _expiresAt;
  String? _provenance;
  String? _datesError;
  bool _submitting = false;

  @override
  void dispose() {
    _refController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initFromProviders() {
    if (_initDone) return;
    _initDone = true;
    if (_editing) {
      final lots = ref.read(bcStockLotsProvider);
      final lot = lots.where((l) => l.id == widget.lotId).firstOrNull;
      if (lot != null) {
        _bloodType = lot.bloodType;
        _product = lot.productType;
        _quantity = lot.quantity;
        _collectedAt = lot.collectionDate;
        _expiresAt = lot.expiryDate;
        _provenance = lot.provenance;
        _refController.text = lot.lotReference;
        _noteController.text = lot.internalNote ?? '';
      }
    } else {
      _bloodType =
          BloodType.fromString(widget.initialType) ?? BloodType.oNeg;
      _refController.text =
          'LOT-${DateTime.now().year}-${(1000 + DateTime.now().millisecond % 9000)}';
    }
  }

  String _fmt(DateTime? d) => d == null
      ? 'JJ/MM/AAAA'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) onPicked(picked);
  }

  bool _validateDates() {
    if (_collectedAt == null || _expiresAt == null) {
      _datesError = 'Sélectionnez les deux dates.';
      return false;
    }
    if (!_expiresAt!.isAfter(_collectedAt!)) {
      _datesError = 'La péremption doit être après la collecte.';
      return false;
    }
    _datesError = null;
    return true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateDates()) {
      setState(() {});
      return;
    }
    setState(() => _submitting = true);
    final now = DateTime.now();
    final lots = ref.read(bcStockLotsProvider);
    final existing =
        _editing ? lots.where((l) => l.id == widget.lotId).firstOrNull : null;
    final lot = BloodStockLot(
      id: existing?.id ?? 'lot-${now.millisecondsSinceEpoch}',
      bloodCenterId: 'bc-a',
      bloodType: _bloodType,
      productType: _product,
      lotReference: _refController.text.trim(),
      quantity: _quantity,
      expiryDate: _expiresAt!,
      collectionDate: _collectedAt!,
      provenance: _provenance,
      internalNote:
          _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      status: existing?.status ?? StockLotStatus.available,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    ref.read(bcStockLotsProvider.notifier).upsert(lot);
    if (mounted) context.go('/bc/stocks');
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Supprimer ${_refController.text.isEmpty ? 'ce lot' : _refController.text} ?'),
        content: const Text(
          'Le lot sera définitivement retiré des stocks.',
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
      ref.read(bcStockLotsProvider.notifier).remove(widget.lotId!);
      if (mounted) context.go('/bc/stocks');
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFromProviders();
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBackButton(
                      onPressed: () => context.go('/bc/stocks'),
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
                  _editing
                      ? 'Modifier le lot ${_refController.text}'
                      : 'Nouveau lot ${_bloodType.label}',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Les disponibilités publiques se mettent à jour '
                  'automatiquement.',
                  style: TextStyle(color: AppColors.gris, fontSize: 14),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('GROUPE SANGUIN'),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: BloodType.values.length,
                  itemBuilder: (context, i) {
                    final type = BloodType.values[i];
                    final selected = type == _bloodType;
                    return OutlinedButton(
                      onPressed: () =>
                          setState(() => _bloodType = type),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            selected ? AppColors.rouge : Colors.white,
                        foregroundColor:
                            selected ? Colors.white : AppColors.encre,
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.rouge
                              : AppColors.ligne,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(type.label),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _SectionTitle('LOT'),
                const SizedBox(height: 12),
                const _FieldLabel('Produit'),
                const SizedBox(height: 8),
                DropdownButtonFormField<ProductType>(
                  initialValue: _product,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  items: ProductType.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            productLabel(p),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _product = v ?? _product),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Référence du lot'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _refController,
                            decoration: const InputDecoration(
                              hintText: 'LOT-2026-0000',
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Requise.'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Quantité'),
                          const SizedBox(height: 8),
                          BcStepper(
                            display:
                                '$_quantity poche${_quantity > 1 ? 's' : ''}',
                            minusEnabled: _quantity > 1,
                            plusEnabled: _quantity < 999,
                            onMinus: () =>
                                setState(() => _quantity--),
                            onPlus: () =>
                                setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Date de collecte',
                        value: _collectedAt,
                        display: _fmt(_collectedAt),
                        onTap: () => _pickDate(
                          initial: _collectedAt,
                          onPicked: (d) => setState(() {
                            _collectedAt = d;
                            _validateDates();
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: 'Date de péremption',
                        value: _expiresAt,
                        display: _fmt(_expiresAt),
                        onTap: () => _pickDate(
                          initial: _expiresAt,
                          onPicked: (d) => setState(() {
                            _expiresAt = d;
                            _validateDates();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_datesError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _datesError!,
                    style: const TextStyle(
                      color: AppColors.rouge,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const _SectionTitle('ORIGINE'),
                const SizedBox(height: 12),
                const _FieldLabel('Provenance'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _provenance,
                  isExpanded: true,
                  hint: const Text('Sélectionnez une origine'),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  items: _provenances
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _provenance = v),
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Note interne'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Information réservée au personnel du centre',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _save,
                  style: ElevatedButton.styleFrom(
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
                            const Icon(Icons.check_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _editing
                                  ? 'Enregistrer les modifications'
                                  : 'Créer le lot',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
                if (_editing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(
                      Icons.delete_outlined,
                      color: AppColors.rouge,
                    ),
                    label: const Text(
                      'Supprimer ce lot',
                      style: TextStyle(
                        color: AppColors.rouge,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppColors.rouge),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.gris,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.encre,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.display,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final String display;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = value == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.ligne),
            ),
            child: Text(
              display,
              style: TextStyle(
                fontSize: 15,
                color: empty
                    ? AppColors.gris.withValues(alpha: 0.7)
                    : AppColors.encre,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
