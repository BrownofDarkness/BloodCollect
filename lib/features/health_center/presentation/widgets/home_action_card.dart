import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Grande carte d'action de l'accueil. Code couleur du projet :
/// bleu = personnes (carte claire), rouge = sang (carte pleine, [filled]).
class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.overline,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String overline;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accent = filled ? AppColors.rouge : AppColors.bleu;
    final titleColor = filled ? Colors.white : AppColors.encre;
    final bodyColor = filled ? Colors.white : AppColors.gris;

    return Material(
      color: filled ? AppColors.rouge : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: filled ? AppColors.rouge : AppColors.ligne),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: filled ? Colors.white : AppColors.bleuLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: TextStyle(
                        color: filled ? AppColors.indisponibleLight : accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: bodyColor,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: titleColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
