import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(title: const Text('Connexion')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: AppColors.rouge),
            SizedBox(height: 16),
            Text('Écran de connexion — à implémenter'),
          ],
        ),
      ),
    );
  }
}
