import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

// Liste de réglages / raccourcis de l'onglet « Profil ».
//
// Un groupe = un sur-titre en capitales + une carte blanche de lignes
// séparées par un filet. Chaque ligne porte une icône, un titre, un sous-titre
// optionnel, un compteur éventuel et une chevron de navigation.

/// Sur-titre de groupe : « MON COMPTE », « MON ACTIVITÉ », « PARAMÈTRES ».
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.gris,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.3,
      ),
    );
  }
}

/// Carte blanche regroupant des lignes de profil.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.rows});

  final List<ProfileRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: AppColors.ligne,
              ),
            rows[index],
          ],
        ],
      ),
    );
  }
}

/// Une ligne de profil.
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.count,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Compteur affiché en pastille rose sur la droite.
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.slate),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (count != null) ...[
            CountBadge(count: count!),
            const SizedBox(width: 12),
          ],
          const Icon(Icons.chevron_right, color: AppColors.gris),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

/// Pastille de compteur rose.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.rouge,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
