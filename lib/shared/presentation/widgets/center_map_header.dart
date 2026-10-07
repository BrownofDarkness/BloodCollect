import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// En-tête « carte » de la fiche centre, avec le bouton retour.
// TODO Blood Route : remplacer le fond dessiné par une vraie carte
// centrée sur la position GPS du centre.
class CenterMapHeader extends StatelessWidget {
  const CenterMapHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 190 + topInset,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.ligne,
              child: CustomPaint(painter: _StreetsPainter()),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: topInset),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.rouge,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Carte · emplacement du centre',
                      style: TextStyle(
                        color: AppColors.slate,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: topInset + 12,
            left: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: AppColors.encre,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Quelques rues stylisées : simple habillage, sans valeur géographique.
class _StreetsPainter extends CustomPainter {
  const _StreetsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final street = Paint()
      ..color = AppColors.ivoire
      ..strokeCap = StrokeCap.square;
    final w = size.width;
    final h = size.height;

    canvas
      ..drawLine(
        Offset(0, h * 0.70),
        Offset(w, h * 0.42),
        street..strokeWidth = 14,
      )
      ..drawLine(
        Offset(w * 0.32, 0),
        Offset(w * 0.45, h),
        street..strokeWidth = 12,
      )
      ..drawLine(
        Offset(w * 0.67, 0),
        Offset(w * 0.76, h),
        street..strokeWidth = 6,
      );
  }

  @override
  bool shouldRepaint(_StreetsPainter oldDelegate) => false;
}
