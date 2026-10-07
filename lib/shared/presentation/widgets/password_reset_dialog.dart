import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/auth_error_messages.dart';
import '../../../core/errors/auth_exceptions.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';

/// « Mot de passe et sécurité » des profils : demande confirmation, envoie
/// le lien de réinitialisation à [email] et annonce le résultat.
Future<void> confirmPasswordReset(
  BuildContext context,
  WidgetRef ref,
  String email,
) async {
  final messenger = ScaffoldMessenger.of(context);
  // Lu avant tout `await` : l'écran peut être fermé entre-temps.
  final auth = ref.read(authRepositoryProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Changer le mot de passe'),
      content: Text('Un lien de réinitialisation sera envoyé à $email.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Envoyer le lien'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  String message;
  try {
    await auth.sendPasswordResetEmail(email);
    message = 'Lien envoyé à $email.';
  } on AuthException catch (e) {
    message = authErrorMessage(e);
  } catch (_) {
    message = 'Envoi impossible. Vérifiez votre connexion puis réessayez.';
  }
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
