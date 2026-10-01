import 'package:flutter/material.dart';

import '../constants/app_colors.dart';


/// Chevron retour aligné au bord du contenu.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.encre,
          ),
        ),
      ),
    );
  }
}
