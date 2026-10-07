import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Interrupteur « Partager mes coordonnées après acceptation » d'une demande
/// de mise en relation. [description] précise quel numéro est transmis.
class ShareContactSwitch extends StatelessWidget {
  const ShareContactSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.description,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String description;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Partager mes coordonnées après acceptation',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.gris,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.bleu,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
