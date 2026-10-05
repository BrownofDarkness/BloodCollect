import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';

// Squelettes de chargement : miroirs ternes du contenu réel
// (mêmes radius, espacements, hauteurs — pas de « saut » à l'arrivée).
// Enfants en Container purs (consigne perf du package shimmer).
class BcShimmer extends StatelessWidget {
  const BcShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.ligne,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// Bloc gris arrondi de base.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Squelette des 4 cartes stats 2×2 du dashboard.
class StatsShimmer extends StatelessWidget {
  const StatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BcShimmer(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: List.generate(
          4,
          (_) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 48, height: 28),
                SizedBox(height: 8),
                ShimmerBox(width: 110, height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 80, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Squelette de la grille 8 groupes du dashboard.
class GroupGridShimmer extends StatelessWidget {
  const GroupGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BcShimmer(
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.68,
        children: List.generate(
          8,
          (_) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 30, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 26, height: 20),
                SizedBox(height: 4),
                ShimmerBox(width: 44, height: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Squelette de N cartes listes (stocks, demandes, collectes).
class ListShimmer extends StatelessWidget {
  const ListShimmer({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return BcShimmer(
      child: Column(
        children: List.generate(
          count,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerBox(width: 90, height: 14),
                    Spacer(),
                    ShimmerBox(width: 64, height: 20, radius: 20),
                  ],
                ),
                SizedBox(height: 10),
                ShimmerBox(width: 150, height: 22),
                SizedBox(height: 8),
                ShimmerBox(width: 200, height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Erreur de chargement + réessayer (timeout, réseau, permissions).
class BcErrorState extends StatelessWidget {
  const BcErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.rougeLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.rouge,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chargement impossible',
            style: TextStyle(
              color: AppColors.encre,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gris,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Réessayer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.rouge,
              side: const BorderSide(color: AppColors.rouge),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
