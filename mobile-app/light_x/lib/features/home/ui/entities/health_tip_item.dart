import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class HealthTipItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  HealthTipItem({required this.title, required this.description, required this.icon, required this.iconColor});

  static List<HealthTipItem> get items => [
    HealthTipItem(
      title: 'Stay Hydrated',
      description: 'Drink at least 8 glasses of water daily to keep your body functioning optimally.',
      icon: Icons.local_fire_department_outlined,
      iconColor: AppColors.orange,
    ),
    HealthTipItem(
      title: 'Move More',
      description: 'Aim for 30 minutes of moderate activity each day to boost your energy and mood.',
      icon: Icons.directions_walk_outlined,
      iconColor: AppColors.blue,
    ),
  ];
}
