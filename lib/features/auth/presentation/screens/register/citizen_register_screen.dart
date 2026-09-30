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
import '../../../../../shared/data/repositories/user_repository_impl.dart';
import '../../../../../shared/domain/entities/app_user.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../widgets/register_form_fields.dart';

// Interface 5 — Formulaire citoyen (badge CITOYEN, actif immédiat).
class CitizenRegisterScreen extends StatefulWidget {
  const CitizenRegisterScreen({super.key});

  @override
  State<CitizenRegisterScreen> createState() => _CitizenRegisterScreenState();
}

class _CitizenRegisterScreenState extends State<CitizenRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  CountryInfo _country = AppLocations.countries.first;
  String? _city;
  String? _commune;
  BloodType? _bloodType;
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    // Mode simulation : délai + entrée directe dans l'espace citoyen.
    if (BackendConfig.simulate) {
      await Future.delayed(BackendConfig.simulatedDelay);
      if (!mounted) return;
      setState(() => _submitting = false);
      context.go(AppRoutes.citizenHome);
      return;
    }
    try {
      final authUser = await AuthRepositoryImpl().signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
      final now = DateTime.now();
      await UserRepositoryImpl().save(
        AppUser(
          id: authUser.id,
          email: _email.text.trim(),
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          phone:
              '${_country.dialCode}${_phone.text.replaceAll(RegExp(r'\D'), '')}',
          role: UserRole.citizen,
          bloodType: _bloodType,
          city: _city,
          commune: _commune,
          createdAt: now,
          updatedAt: now,
        ),
      );
      // RouterNotifier bascule vers /citizen/home tout seul.
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
                        color: AppColors.bleuLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: AppColors.bleu,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'CITOYEN',
                            style: TextStyle(
                              color: AppColors.bleu,
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
                  'Créer mon compte citoyen',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle('IDENTITÉ'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'Nom',
                        child: TextFormField(
                          controller: _lastName,
                          textInputAction: TextInputAction.next,
                          decoration:
                              const InputDecoration(hintText: 'Koné'),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'Requis.' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: 'Prénom',
                        child: TextFormField(
                          controller: _firstName,
                          textInputAction: TextInputAction.next,
                          decoration:
                              const InputDecoration(hintText: 'Aya'),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'Requis.' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FieldLabel('Téléphone'),
                const SizedBox(height: 8),
                PhoneField(
                  controller: _phone,
                  country: _country,
                  onCountryChanged: _syncCountry,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Email',
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'nom@exemple.com',
                    ),
                    validator: Validators.email,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('OÙ HABITEZ-VOUS ?'),
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
                  helper: 'Utilisé pour vous proposer les donneurs, '
                      'centres et collectes les plus proches.',
                ),
                const SizedBox(height: 24),
                const SectionTitle('GROUPE SANGUIN'),
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
                      onPressed: () => setState(() => _bloodType = type),
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
                          color:
                              selected ? AppColors.rouge : AppColors.ligne,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(type.firestoreValue),
                    );
                  },
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _bloodType = null),
                  child: const Text(
                    'Je ne connais pas mon groupe',
                    style: TextStyle(
                      color: AppColors.bleu,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
                      : const Text(
                          'Créer mon compte',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'En créant un compte, vous acceptez les conditions '
                    'd’utilisation et la politique de confidentialité.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gris, fontSize: 13),
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
