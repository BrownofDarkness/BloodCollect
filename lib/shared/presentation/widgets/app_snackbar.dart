import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Centralise l'affichage des snackbars pour un style cohérent sur les 5 écrans.
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.check_circle,
      iconColor: AppColors.disponible,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.error_outline,
      iconColor: AppColors.indisponible,
    );
  }

  static void info(BuildContext context, String message) {
    _show(context, message, icon: Icons.info_outline, iconColor: Colors.white);
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
