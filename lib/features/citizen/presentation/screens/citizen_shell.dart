import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.bleuLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.bleu),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppColors.bleu),
            label: 'Donneurs',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop, color: AppColors.rouge),
            label: 'Sang',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: AppColors.rouge),
            label: 'Donner',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.bleu),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
