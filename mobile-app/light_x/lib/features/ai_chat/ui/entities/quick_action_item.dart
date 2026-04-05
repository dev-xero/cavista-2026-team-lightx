import 'package:flutter/material.dart';

class QuickActionItem {
  final IconData icon;
  final String label;

  const QuickActionItem({required this.icon, required this.label});
}

const defaultAiQuickActions = <QuickActionItem>[
  QuickActionItem(icon: Icons.bar_chart_rounded, label: 'View Deep Sleep'),
  QuickActionItem(icon: Icons.favorite_rounded, label: 'Heart Rate Zones'),
  QuickActionItem(icon: Icons.flag_rounded, label: 'Set Goals'),
];
