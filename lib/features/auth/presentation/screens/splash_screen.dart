import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.rouge,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop, size: 72, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'BloodCollect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Donner. Trouver. Sauver.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
