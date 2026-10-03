import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';
import '../providers/hc_providers.dart';
import '../widgets/availability_level_style.dart';
import '../widgets/blood_request_form_fields.dart';
import '../widgets/hc_role_badge.dart';

// Onglet « Sang » — Demande de sang.
// Le centre de santé transmet un besoin au centre de transfusion choisi.
// Côté patient, seule la référence interne du dossier est envoyée.
class HcBloodRequestScreen extends ConsumerStatefulWidget {
  const HcBloodRequestScreen({super.key, this.bloodCenterId, this.bloodType});

  /// Centre de transfusion destinataire (null : à choisir via la recherche).
  final String? bloodCenterId;

  /// Groupe présélectionné depuis la recherche ou la fiche centre.
  final BloodType? bloodType;

  @override
  ConsumerState<HcBloodRequestScreen> createState() =>
      _HcBloodRequestScreenState();
}

class _HcBloodRequestScreenState extends ConsumerState<HcBloodRequestScreen> {
  static const _maxQuantity = 20;
  static const _maxNotesLength = 500;

  final _formKey = GlobalKey<FormState>();
  final _patientReference = TextEditingController();
  final _notes = TextEditingController();

  late BloodType _bloodType = widget.bloodType ?? BloodType.oPos;
  int _quantity = 1;
  Priority _priority = Priority.normal;
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _patientReference.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.hcBlood);

  Future<void> _submit(BloodCenter center) async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final healthCenter = await ref.read(currentHealthCenterProvider.future);
      if (!mounted) return;
      if (healthCenter == null) {
        setState(
          () => _serverError =
              'Fiche de votre centre de santé introuvable. Reconnectez-vous.',
        );
        return;
      }
      final now = DateTime.now();
      final notes = _notes.text.trim();
      await ref.read(bloodRequestRepositoryProvider).create(
            BloodRequest(
              id: '',
              healthCenterId: healthCenter.id,
              bloodType: _bloodType,
              // La maquette ne propose pas de choix du produit.
              productType: ProductType.wholeBlood,
              quantityNeeded: _quantity,
              patientReference: _patientReference.text.trim().toUpperCase(),
              priority: _priority,
              status: RequestStatus.pending,
              bloodRouteStep: BloodRouteStep.searchingStock,
              matchedBloodCenterId: center.id,
              notes: notes.isEmpty ? null : notes,
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (mounted) _showSuccess(center);
    } catch (_) {
      if (mounted) {
        setState(
          () => _serverError =
              'Envoi impossible. Vérifiez votre connexion puis réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccess(BloodCenter center) {
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
                  color: AppColors.rougeLight,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Icon(
                  Icons.near_me_outlined,
                  color: AppColors.rouge,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Demande transmise',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre demande est transmise à ${center.name}. Suivez sa '
                'réponse dans l’onglet Demandes.',
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
                  // Referme le formulaire : l'onglet repart de la recherche.
                  if (mounted) context.go(AppRoutes.hcBlood);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Retour à la recherche',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
    final centerId = widget.bloodCenterId;
    final center = centerId == null
        ? null
        : ref.watch(bloodCenterProvider(centerId)).value;
    // Gardé actif : relu à l'envoi pour renseigner le centre demandeur.
    ref.watch(currentHealthCenterProvider);

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
                  'Demande de sang',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Transmise au centre de transfusion choisi.',
                  style: TextStyle(color: AppColors.gris, fontSize: 15),
                ),
                const SizedBox(height: 16),
                _TargetCenterCard(
                  centerId: centerId,
                  bloodType: _bloodType,
                  onChange: () => context.go(AppRoutes.hcBlood),
                ),
                const SizedBox(height: 24),
                const SectionTitle('PATIENT'),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Référence du dossier patient',
                  child: TextFormField(
                    controller: _patientReference,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'DOS-2291'),
                    validator: Validators.patientReference,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ni nom, ni données médicales détaillées : seule la '
                  'référence interne est transmise.',
                  style: TextStyle(
                    color: AppColors.gris,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('BESOIN'),
                const SizedBox(height: 12),
                BloodTypeGridSelector(
                  value: _bloodType,
                  onChanged: (v) => setState(() => _bloodType = v),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Quantité nécessaire',
                  child: QuantityStepper(
                    value: _quantity,
                    max: _maxQuantity,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Niveau d’urgence',
                  child: PrioritySelector(
                    value: _priority,
                    onChanged: (v) => setState(() => _priority = v),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Informations nécessaires',
                  child: TextFormField(
                    controller: _notes,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxNotesLength),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Délai souhaité, conditions particulières…',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _VitalEmergencyNotice(),
                if (_serverError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _serverError!,
                      style: const TextStyle(
                        color: AppColors.rouge,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: center == null || _submitting
                      ? null
                      : () => _submit(center),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.near_me_outlined, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Transmettre la demande',
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
            ),
          ),
        ),
      ),
    );
  }
}

/// Centre destinataire et statut déclaré du groupe demandé.
class _TargetCenterCard extends ConsumerWidget {
  const _TargetCenterCard({
    required this.centerId,
    required this.bloodType,
    required this.onChange,
  });

  final String? centerId;
  final BloodType bloodType;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = centerId;
    final centerAsync = id == null ? null : ref.watch(bloodCenterProvider(id));
    final center = centerAsync?.value;
    final availability = id == null
        ? null
        : ref
            .watch(bloodCenterAvailabilitiesProvider(id))
            .value
            ?.where((item) => item.bloodType == bloodType)
            .firstOrNull;

    final String title;
    if (center != null) {
      title = center.name;
    } else if (centerAsync != null && centerAsync.isLoading) {
      title = 'Chargement…';
    } else if (id == null) {
      title = 'Aucun centre choisi';
    } else {
      title = 'Centre introuvable';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.indisponibleLight,
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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (availability != null) ...[
                  const SizedBox(height: 4),
                  _AvailabilityPill(availability: availability),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.bleu,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
            child: Text(center == null ? 'Choisir' : 'Changer'),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.availability});

  final BloodAvailability availability;

  @override
  Widget build(BuildContext context) {
    final level = availability.level;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: level.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, color: level.color, size: 10),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${availability.bloodType.label} · ${level.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: level.color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalEmergencyNotice extends StatelessWidget {
  const _VitalEmergencyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.limiteLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: AppColors.limite,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgence vitale ?',
                  style: TextStyle(
                    color: AppColors.limite,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Appelez aussi directement le centre de transfusion : la '
                  'réponse dans l’application n’est pas instantanée.',
                  style: TextStyle(
                    color: AppColors.encre,
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
