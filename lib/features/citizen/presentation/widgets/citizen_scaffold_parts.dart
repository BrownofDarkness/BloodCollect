import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// En-tête commun aux écrans du module Citoyen : flèche de retour optionnelle
/// et pastille de contexte (« Sang · Centres agréés », « Don volontaire »…).
///
/// La pastille rappelle le code couleur du design system : rouge pour le sang,
/// bleu pour les personnes.
class CitizenScreenHeader extends StatelessWidget {
  const CitizenScreenHeader({
    super.key,
    required this.contextLabel,
    required this.contextIcon,
    this.onBack,
  });

  final String contextLabel;
  final IconData contextIcon;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          _BackButton(onTap: onBack!),
          const SizedBox(width: 12),
        ],
        _ContextPill(label: contextLabel, icon: contextIcon),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retour',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
    );
  }
}

class _ContextPill extends StatelessWidget {
  const _ContextPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.rouge),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.rouge,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titre de page. Grande chasse renforcée, interligne serré.
class CitizenPageTitle extends StatelessWidget {
  const CitizenPageTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.encre,
        fontSize: 30,
        height: 1.06,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.9,
      ),
    );
  }
}

/// Titre de section dans le corps de page.
class CitizenSectionTitle extends StatelessWidget {
  const CitizenSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 20,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Sur-titre en capitales espacées : « GROUPE SANGUIN », « MON COMPTE »…
class CitizenLabelCaps extends StatelessWidget {
  const CitizenLabelCaps(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.slate,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Encart explicatif sur fond beige, précédé d'une icône de bouclier.
///
/// Porte les garde-fous du parcours : lecture seule du stock, éligibilité
/// vérifiée sur place, jamais de donneur présenté comme du sang disponible.
class CitizenInfoBanner extends StatelessWidget {
  const CitizenInfoBanner({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.encart,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: AppColors.encre),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
