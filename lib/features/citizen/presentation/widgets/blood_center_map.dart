import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Emplacement du centre, dessiné localement.
///
/// ─────────────────────────────────────────────────────────────────────────
/// À REMPLACER — bandeau de localisation.
/// Aucune dépendance carte n'est utilisée ici : le fond, les tracés et le
/// marqueur sont peints par [CustomPainter], sans clé API ni service tiers.
/// Ce n'est qu'une représentation de l'emplacement, pas une carte interactive.
///
/// Pour brancher une vraie carte (google_maps_flutter, flutter_map, Mapbox),
/// remplacer le corps de ce widget par la vue cartographique en gardant le
/// même nom, la même taille et le même positionnement dans la fiche centre,
/// afin que seul le contenu change. Aucune autre modification n'est nécessaire :
/// aucun écran ne dépend de l'implémentation interne de ce widget.
/// ─────────────────────────────────────────────────────────────────────────
class BloodCenterMapBanner extends StatelessWidget {
  const BloodCenterMapBanner({
    super.key,
    this.height = 210,
    this.caption = 'Carte · emplacement du centre',
  });

  final double height;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapBackdropPainter())),
          const _CenterPin(),
          Positioned(
            top: height * 0.52,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                caption,
                style: const TextStyle(
                  color: AppColors.encre,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tracé de rue stylisé : quelques voies larges croisées sur le fond beige.
class _MapBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.carteFond);

    final road = Paint()
      ..color = AppColors.surface
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Deux voies principales en diagonale et une transversale, décalées pour
    // éviter une géométrie centrée et donner une lecture de carrefours.
    canvas.drawPath(
      Path()
        ..moveTo(-size.width * 0.15, size.height * 0.62)
        ..lineTo(size.width * 0.55, -size.height * 0.1),
      road,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 1.1, size.height * 0.15)
        ..lineTo(size.width * 0.35, size.height * 1.1),
      road,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.05, size.height * 1.02)
        ..lineTo(size.width * 0.95, size.height * 0.78),
      road..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(_MapBackdropPainter oldDelegate) => false;
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.rouge,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 26),
    );
  }
}
