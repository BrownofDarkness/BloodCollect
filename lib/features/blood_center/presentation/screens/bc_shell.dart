import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class BloodCenterShell extends StatelessWidget {
  const BloodCenterShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.rougeLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.rouge),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.rouge),
            label: 'Stocks',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt, color: AppColors.rouge),
            label: 'Demandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign, color: AppColors.rouge),
            label: 'Collectes',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop, color: AppColors.rouge),
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
