// Validateurs de formulaires partagés.
abstract final class Validators {
  static final RegExp _email =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _special =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];'"'"'+=~` ]');

  // Référence interne sans espace : empêche de saisir un nom de patient.
  static final RegExp _patientReference =
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]{1,29}$');

  /// Référence de dossier patient : 2 à 30 caractères, sans espace.
  static String? patientReference(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'La référence du dossier est requise.';
    if (!_patientReference.hasMatch(v)) {
      return 'Référence invalide (ex. DOS-2291, sans espace ni nom).';
    }
    return null;
  }

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'L’adresse email est requise.';
    if (!isEmail(v)) return 'Adresse email invalide.';
    return null;
  }

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  /// Numéro local : chiffres uniquement (espaces ignorés), 8 à 12 chiffres.
  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Le numéro de téléphone est requis.';
    if (digits.length < 8 || digits.length > 12) {
      return 'Numéro invalide (8 à 12 chiffres).';
    }
    return null;
  }

  /// Mot de passe fort : 8 caractères min, majuscule, chiffre, spécial.
  static String? passwordStrong(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Le mot de passe est requis.';
    if (v.length < 8) return '8 caractères minimum.';
    if (!_upper.hasMatch(v)) return 'Ajoutez au moins une majuscule.';
    if (!_digit.hasMatch(v)) return 'Ajoutez au moins un chiffre.';
    if (!_special.hasMatch(v)) return 'Ajoutez au moins un caractère spécial.';
    return null;
  }
}
