import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(title: const Text('Inscription')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add_outlined,
              size: 48,
              color: AppColors.rouge,
            ),
            const SizedBox(height: 16),
            Text('Inscription ($role) — à implémenter'),
          ],
        ),
      ),
    );
  }
}
