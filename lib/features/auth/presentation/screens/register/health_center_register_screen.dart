import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/backend_config.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/errors/auth_error_messages.dart';
import '../../../../../core/errors/auth_exceptions.dart';
import '../../../../../core/widgets/app_back_button.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/constants/app_locations.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/data/repositories/center_repository_impl.dart';
import '../../../../../shared/data/repositories/user_repository_impl.dart';
import '../../../../../shared/domain/entities/app_user.dart';
import '../../../../../shared/domain/entities/geo_location.dart';
import '../../../../../shared/domain/entities/health_center.dart';
import '../../../../../shared/domain/entities/validation_request.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../widgets/register_form_fields.dart';

// Interface 6 — Formulaire centre de santé (badge beige, CTA rouge,
// justificatif uploadé, compte pending + popup succès).
class HealthCenterRegisterScreen extends StatefulWidget {
  const HealthCenterRegisterScreen({super.key});

  @override
  State<HealthCenterRegisterScreen> createState() =>
      _HealthCenterRegisterScreenState();
}

class _HealthCenterRegisterScreenState
    extends State<HealthCenterRegisterScreen> {
  static const _maxBytes = 10 * 1024 * 1024;
  static const _establishmentTypes = [
    'Centre de santé communautaire',
    'Clinique',
    'CHU',
    'CHR',
    'Hôpital général',
    'Dispensaire',
    'Centre médical',
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _authNumber = TextEditingController();
  final _address = TextEditingController();
  final _contactName = TextEditingController();
  final _contactFunction = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _establishmentType;
  CountryInfo _country = AppLocations.countries.first;
  String? _city;
  String? _commune;
  PlatformFile? _document;
  String? _documentError;
  bool _obscurePassword = true;
  bool _picking = false;
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _name.dispose();
    _authNumber.dispose();
    _address.dispose();
    _contactName.dispose();
    _contactFunction.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _syncCountry(CountryInfo c) => setState(() {
        _country = c;
        _city = null;
        _commune = null;
      });

  Future<void> _pickDocument() async {
    setState(() {
      _picking = true;
      _documentError = null;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null) return;
      final size = file.lengthSync() ?? await file.length();
      if (size == null || size > _maxBytes) {
        setState(
          () => _documentError =
              'Document trop lourd (10 Mo maximum).',
        );
        return;
      }
      setState(() => _document = file);
    } catch (_) {
      setState(
        () => _documentError = 'Sélection impossible. Réessayez.',
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _serverError = null;
      _documentError =
          (BackendConfig.storageEnabled && _document == null)
              ? 'Ajoutez votre justificatif d’autorisation.'
              : null;
    });
    if (!_formKey.currentState!.validate()) return;
    if (BackendConfig.storageEnabled && _document == null) return;

    setState(() => _submitting = true);
    // Mode simulation : délai + popup succès (sans Firebase).
    if (BackendConfig.simulate) {
      await Future.delayed(BackendConfig.simulatedDelay);
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSuccess();
      return;
    }
    try {
      final authUser = await AuthRepositoryImpl().signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
      final uid = authUser.id;
      final now = DateTime.now();
      final centerRepo = CenterRepositoryImpl();

      final bytes = _document == null
          ? null
          : await _document!.readAsBytes();
      final docUrl = (BackendConfig.storageEnabled && bytes != null)
          ? await centerRepo.uploadValidationDoc(
              uid: uid,
              fileName:
                  '${now.millisecondsSinceEpoch}_${_document!.name}',
              bytes: bytes.toList(),
            )
          : null;

      final centerId = await centerRepo.createHealthCenter(
        HealthCenter(
          id: '',
          userId: uid,
          name: _name.text.trim(),
          address: _address.text.trim(),
          city: _city!,
          commune: _commune!,
          // TODO Blood Route : sélecteur carte pour la position GPS réelle.
          location: const GeoLocation(latitude: 0, longitude: 0),
          phone:
              '${_country.dialCode}${_phone.text.replaceAll(RegExp(r'\D'), '')}',
          establishmentType: _establishmentType!,
          authorizationNumber: _authNumber.text.trim(),
          contactFunction: _contactFunction.text.trim(),
          verificationStatus: VerificationStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await centerRepo.createValidationRequest(
        ValidationRequest(
          id: '',
          structureId: centerId,
          structureType: StructureType.healthCenter,
          userId: uid,
          documentUrls: docUrl == null ? [] : [docUrl],
          status: VerificationStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await UserRepositoryImpl().save(
        AppUser(
          id: uid,
          email: _email.text.trim(),
          firstName: _contactName.text.trim(),
          lastName: _contactName.text.trim(),
          phone:
              '${_country.dialCode}${_phone.text.replaceAll(RegExp(r'\D'), '')}',
          role: UserRole.healthCenter,
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (mounted) {
        // Le router a pu déjà basculer vers /pending-verification via les
        // streams temps réel : dans ce cas la popup est inutile.
        final loc = GoRouterState.of(context).matchedLocation;
        if (loc.startsWith('/register')) _showSuccess();
      }
    } on AuthException catch (e) {
      setState(() => _serverError = authErrorMessage(e));
    } catch (_) {
      setState(
        () => _serverError =
            'Inscription impossible. Vérifiez votre connexion puis réessayez.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccess() {
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
                  Icons.verified_user_outlined,
                  color: AppColors.bleu,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Demande envoyée',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre compte est créé. Suivez l’état de la vérification '
                'ici — l’accès s’ouvrira dès validation par l’équipe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gris,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Pop via le contexte du dialogue (toujours valide),
                  // puis naviguer seulement si le formulaire existe encore
                  // (le router a pu déjà basculer vers pending via streams).
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    context.go(AppRoutes.pendingVerification);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Voir mon statut',
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
                    AppBackButton(
                      onPressed: () => context.go(AppRoutes.registerChoice),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ligne.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            color: AppColors.encre,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'CENTRE DE SANTÉ',
                            style: TextStyle(
                              color: AppColors.encre,
                              fontSize: 12,
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
                const Text(
                  'Inscrire un centre de santé',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle('ÉTABLISSEMENT'),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Nom de l’établissement',
                  child: TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'CSCom de Treichville',
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Requis.' : null,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Type d’établissement',
                  child: DropdownButtonFormField<String>(
                    initialValue: _establishmentType,
                    isExpanded: true,
                    hint: const Text('Sélectionnez un type'),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    items: _establishmentTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _establishmentType = v),
                    validator: (v) =>
                        v == null ? 'Sélectionnez un type.' : null,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Numéro d’autorisation',
                  child: TextFormField(
                    controller: _authNumber,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'N° délivré par l’autorité sanitaire',
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Requis.' : null,
                  ),
                ),
                const SizedBox(height: 16),
                const FieldLabel(
                  'Justificatif d’autorisation (facultatif)',
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _picking ? null : _pickDocument,
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: const Radius.circular(16),
                      color: _documentError != null
                          ? AppColors.rouge
                          : AppColors.gris,
                      strokeWidth: 1.5,
                      dashPattern: const [8, 6],
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                      children: [
                        if (_picking)
                          const CircularProgressIndicator(
                            color: AppColors.bleu,
                          )
                        else if (_document != null) ...[
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.bleu,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Text(
                              _document!.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.encre,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toucher pour changer',
                            style: TextStyle(
                              color: AppColors.bleu,
                              fontSize: 14,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.file_upload_outlined,
                            color: AppColors.bleu,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ajouter un document',
                            style: TextStyle(
                              color: AppColors.bleu,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'PDF ou photo · 10 Mo max',
                            style: TextStyle(
                              color: AppColors.gris,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                ),
                if (_documentError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _documentError!,
                    style: const TextStyle(
                      color: AppColors.rouge,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const SectionTitle('LOCALISATION'),
                const SizedBox(height: 12),
                LocationSelector(
                  country: _country,
                  city: _city,
                  commune: _commune,
                  onCountryChanged: _syncCountry,
                  onCityChanged: (v) => setState(() {
                    _city = v;
                    _commune = null;
                  }),
                  onCommuneChanged: (v) => setState(() => _commune = v),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Adresse (facultatif)',
                  child: TextFormField(
                    controller: _address,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Rue, quartier, repère',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('RESPONSABLE DU COMPTE'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'Nom complet',
                        child: TextFormField(
                          controller: _contactName,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Dr Kouadio Yao',
                          ),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'Requis.' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: 'Fonction',
                        child: TextFormField(
                          controller: _contactFunction,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Médecin-chef',
                          ),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'Requis.' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FieldLabel('Téléphone professionnel'),
                const SizedBox(height: 8),
                PhoneField(
                  controller: _phone,
                  country: _country,
                  onCountryChanged: _syncCountry,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Email professionnel',
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'contact@centre.ci',
                    ),
                    validator: Validators.email,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('SÉCURITÉ'),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Mot de passe',
                  child: TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••••',
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        color: AppColors.gris,
                      ),
                    ),
                    validator: Validators.passwordStrong,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.ligne.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.encre,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vérification avant activation',
                              style: TextStyle(
                                color: AppColors.encre,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'L’équipe BloodCollect vérifie l’autorisation '
                              'de votre établissement. Vous êtes notifié '
                              'dès que le compte est actif.',
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
                ),
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
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
                            Icon(Icons.send_outlined, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Envoyer ma demande d’inscription',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
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
