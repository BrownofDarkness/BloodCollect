import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/geo_location.dart';
import '../providers/bc_dashboard_providers.dart';
import '../widgets/bc_stepper.dart';

//Formulaire collecte (créer / modifier).
// Save via CampaignsNotifier ; étape 2 = repository Firestore.
class BcCampaignFormScreen extends ConsumerStatefulWidget {
  const BcCampaignFormScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  ConsumerState<BcCampaignFormScreen> createState() =>
      _BcCampaignFormScreenState();
}

class _BcCampaignFormScreenState
    extends ConsumerState<BcCampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();

  bool get _editing => widget.campaignId != null;
  bool _initDone = false;

  CountryInfo _country = AppLocations.countries.first;
  String? _city;
  String? _commune;
  DateTime? _day;
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 14, minute: 0);
  final Set<BloodType> _bloodTypes = {};
  int _targetUnits = 80;
  final Set<String> _communes = {};
  bool _notifyDonors = true;
  String? _selectionError;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _initFromProviders() {
    if (_initDone) return;
    _initDone = true;
    if (!_editing) return;
    final campaigns =
        ref.read(bcCampaignsProvider).asData?.value ?? const [];
    final campaign =
        campaigns.where((c) => c.id == widget.campaignId).firstOrNull;
    if (campaign == null) return;
    _titleController.text = campaign.title;
    _descriptionController.text = campaign.description;
    _placeController.text = campaign.locationName;
    _day = DateTime(
      campaign.startDate.year,
      campaign.startDate.month,
      campaign.startDate.day,
    );
    _start = TimeOfDay(
      hour: campaign.startDate.hour,
      minute: campaign.startDate.minute,
    );
    _end = TimeOfDay(
      hour: campaign.endDate.hour,
      minute: campaign.endDate.minute,
    );
    _bloodTypes.addAll(campaign.targetBloodTypes);
    _targetUnits = campaign.targetUnits;
    _communes.addAll(campaign.targetCommunes);
    _notifyDonors = campaign.notifyDonors;
  }

  bool get _timesValid =>
      _start.hour * 60 + _start.minute <
      _end.hour * 60 + _end.minute;

  bool _validateSelections() {
    if (_city == null || _commune == null) {
      _selectionError = 'Sélectionnez la ville et la commune.';
      return false;
    }
    if (_bloodTypes.isEmpty) {
      _selectionError = 'Sélectionnez au moins un groupe sanguin.';
      return false;
    }
    if (_notifyDonors && _communes.isEmpty) {
      _selectionError =
          'Sélectionnez au moins une commune à notifier.';
      return false;
    }
    if (_day == null) {
      _selectionError = 'Sélectionnez la date de la collecte.';
      return false;
    }
    _selectionError = null;
    return true;
  }

  String _fmtDay(DateTime? d) => d == null
      ? 'JJ/MM/AAAA'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour}h${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save(CampaignStatus status) async {
    setState(() => _selectionError = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_validateSelections()) {
      setState(() {});
      return;
    }
    setState(() => _submitting = true);
    final centerId =
        ref.read(myBloodCenterProvider).asData?.value?.id;
    if (centerId == null) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Centre introuvable.')),
        );
      }
      return;
    }
      final now = DateTime.now();
      final campaigns =
          ref.read(bcCampaignsProvider).asData?.value ?? const [];
      final existing = _editing
          ? campaigns
              .where((c) => c.id == widget.campaignId)
              .firstOrNull
          : null;
      final start = DateTime(
      _day!.year,
      _day!.month,
      _day!.day,
      _start.hour,
      _start.minute,
    );
    final end = DateTime(
      _day!.year,
      _day!.month,
      _day!.day,
      _end.hour,
      _end.minute,
    );
    try {
      await ref.read(bloodCenterDataRepositoryProvider).saveCampaign(
            Campaign(
              id: existing?.id ?? '',
              bloodCenterId: centerId,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              location: const GeoLocation(latitude: 0, longitude: 0),
              locationName: _placeController.text.trim(),
              commune: _commune,
              startDate: start,
              endDate: end,
              targetBloodTypes: _bloodTypes.toList(),
              targetCommunes: _communes.toList(),
              targetUnits: _targetUnits,
              collectedUnits: existing?.collectedUnits ?? 0,
              notifyDonors: _notifyDonors,
              status: status,
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enregistrement impossible ($e).')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == CampaignStatus.published
                ? 'Collecte publiée.'
                : 'Brouillon enregistré.',
          ),
        ),
      );
      context.go('/bc/campaigns');
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(bcCampaignsProvider);
    final campaigns = campaignsAsync.asData?.value ?? const <Campaign>[];
    final found =
        !_editing || campaigns.any((c) => c.id == widget.campaignId);
    if (_editing && !found) {
      return Scaffold(
        backgroundColor: AppColors.ivoire,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackButton(
                  onPressed: () => context.go('/bc/campaigns'),
                ),
                const SizedBox(height: 16),
                Text(
                  campaignsAsync.isLoading
                      ? 'Chargement de la collecte…'
                      : 'Collecte introuvable.',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (campaignsAsync.isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      );
    }
    _initFromProviders();
    final communesOfCity = _city == null
        ? <String>[]
        : _country.cities[_city] ?? [];
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
                      onPressed: () => context.go('/bc/campaigns'),
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
                  _editing ? 'Modifier la collecte' : 'Nouvelle collecte',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Les citoyens des communes ciblées sont notifiés '
                  'à la publication.',
                  style: TextStyle(color: AppColors.gris, fontSize: 14),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('CAMPAGNE'),
                const SizedBox(height: 12),
                const _FieldLabel('Titre'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Collecte mobile de Treichville',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Requis.' : null,
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Pourquoi cette collecte, conditions pour '
                        'donner, ce qu’il faut apporter…',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Requise.' : null,
                ),
                const SizedBox(height: 20),
                const _SectionTitle('LIEU ET DATE'),
                const SizedBox(height: 12),
                _LabeledDropdown(
                  label: 'Pays',
                  value:
                      '${_country.name} (${_country.dialCode})',
                  hint: 'Pays',
                  items: AppLocations.countries
                      .map((c) => '${c.name} (${c.dialCode})')
                      .toList(),
                  onChanged: (v) => setState(() {
                    _country = AppLocations.countries.firstWhere(
                      (c) => '${c.name} (${c.dialCode})' == v,
                      orElse: () => AppLocations.countries.first,
                    );
                    _city = null;
                    _commune = null;
                    _communes.clear();
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledDropdown(
                        label: 'Ville',
                        value: _city,
                        hint: 'Ville',
                        items: _country.cities.keys.toList(),
                        onChanged: (v) => setState(() {
                          _city = v;
                          _commune = null;
                          _communes.clear();
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledDropdown(
                        label: 'Commune',
                        value: _commune,
                        hint: 'Commune',
                        items: communesOfCity,
                        onChanged: (v) =>
                            setState(() => _commune = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Lieu précis'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _placeController,
                  decoration: const InputDecoration(
                    hintText: 'Place de la mairie',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Requis.' : null,
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Date'),
                const SizedBox(height: 8),
                _PickerBox(
                  display: _fmtDay(_day),
                  empty: _day == null,
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _day ?? now,
                      firstDate: now.subtract(
                        const Duration(days: 1),
                      ),
                      lastDate:
                          now.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _day = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimeChip(
                        label: 'Début',
                        display: _fmtTime(_start),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _start,
                            builder: (context, child) =>
                                MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                alwaysUse24HourFormat: true,
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setState(() => _start = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeChip(
                        label: 'Fin',
                        display: _fmtTime(_end),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _end,
                            builder: (context, child) =>
                                MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                alwaysUse24HourFormat: true,
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setState(() => _end = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (!_timesValid) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'La fin doit être après le début.',
                    style: TextStyle(
                      color: AppColors.rouge,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const _SectionTitle('BESOINS'),
                const SizedBox(height: 12),
                const _FieldLabel('Groupes recherchés'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in BloodType.values)
                      _CheckChip(
                        label: type.label,
                        selected:
                            _bloodTypes.contains(type),
                        onTap: () => setState(() {
                          if (_bloodTypes.contains(type)) {
                            _bloodTypes.remove(type);
                          } else {
                            _bloodTypes.add(type);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Objectif de donneurs'),
                const SizedBox(height: 8),
                BcStepper(
                  display: '$_targetUnits donneurs',
                  minusEnabled: _targetUnits > 10,
                  plusEnabled: _targetUnits < 1000,
                  onMinus: () =>
                      setState(() => _targetUnits -= 10),
                  onPlus: () =>
                      setState(() => _targetUnits += 10),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('DIFFUSION'),
                const SizedBox(height: 12),
                const _FieldLabel('Communes à notifier'),
                const SizedBox(height: 8),
                if (communesOfCity.isEmpty)
                  const Text(
                    'Sélectionnez d’abord une ville.',
                    style: TextStyle(
                      color: AppColors.gris,
                      fontSize: 14,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in communesOfCity)
                        _CheckChip(
                          label: c,
                          selected: _communes.contains(c),
                          onTap: () => setState(() {
                            if (_communes.contains(c)) {
                              _communes.remove(c);
                            } else {
                              _communes.add(c);
                            }
                          }),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifier les donneurs disponibles',
                            style: TextStyle(
                              color: AppColors.encre,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Envoi d’une alerte aux donneurs potentiels '
                            'des groupes recherchés.',
                            style: TextStyle(
                              color: AppColors.gris,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notifyDonors,
                      activeThumbColor: AppColors.rouge,
                      onChanged: (v) =>
                          setState(() => _notifyDonors = v),
                    ),
                  ],
                ),
                if (_selectionError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _selectionError!,
                    style: const TextStyle(
                      color: AppColors.rouge,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () => _save(CampaignStatus.published),
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Publier la collecte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => _save(CampaignStatus.draft),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.encre,
                    minimumSize:
                        const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side:
                        const BorderSide(color: AppColors.ligne),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Enregistrer en brouillon'),
                ),
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

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          hint: Text(hint),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
          items: items
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.display,
    required this.empty,
    required this.icon,
    required this.onTap,
  });

  final String display;
  final bool empty;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Row(
          children: [
            Expanded(
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
            Icon(icon, color: AppColors.gris, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.display,
    required this.onTap,
  });

  final String label;
  final String display;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        _PickerBox(
          display: display,
          empty: false,
          icon: Icons.schedule_outlined,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _CheckChip extends StatelessWidget {
  const _CheckChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.rougeLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.rouge : AppColors.ligne,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check_outlined,
                  color: AppColors.rouge,
                  size: 16,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.rouge : AppColors.encre,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
