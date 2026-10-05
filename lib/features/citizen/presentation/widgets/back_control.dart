import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Flèche de retour des en-têtes d'écran.
///
/// La barre système Android est masquée par l'AppBar sur ces écrans, donc le
/// retour a besoin d'un contrôle explicite : il doit être visible au même
/// endroit que sur les écrans qui utilisent l'en-tête du module.
class BackControl extends StatelessWidget {
  const BackControl({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retour',
      child: InkResponse(
        onTap: onBack,
        radius: 24,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.encre,
          ),
        ),
      ),
    );
  }
}
