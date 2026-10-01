import 'package:flutter/material.dart';

import 'register/blood_center_register_screen.dart';
import 'register/citizen_register_screen.dart';
import 'register/health_center_register_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return switch (role) {
      'health_center' => const HealthCenterRegisterScreen(),
      'blood_center' => const BloodCenterRegisterScreen(),
      _ => const CitizenRegisterScreen(),
    };
  }
}
