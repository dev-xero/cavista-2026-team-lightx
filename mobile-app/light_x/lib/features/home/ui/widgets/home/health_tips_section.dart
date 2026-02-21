import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

class HealthTipItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const HealthTipItem({required this.title, required this.description, required this.icon, required this.iconColor});
}

// ─────────────────────────────────────────────
// Icon badge (colored rounded square)
// ─────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _IconBadge({required this.icon, required this.iconColor});

  // bg is the icon color at 10 % opacity
  Color get _bg => iconColor.withOpacity(0.1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(16)),
      child: Center(child: Icon(icon, color: iconColor, size: 22)),
    );
  }
}

// ─────────────────────────────────────────────
// Single tip card row
// ─────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final HealthTipItem item;

  const _TipCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          _IconBadge(icon: item.icon, iconColor: item.iconColor),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.headingText,
                  ),
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.bodyText,
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

// ─────────────────────────────────────────────
// Public section widget
// ─────────────────────────────────────────────

class HealthTipsSection extends StatelessWidget {
  final String sectionTitle;
  final List<HealthTipItem> tips;

  const HealthTipsSection({super.key, this.sectionTitle = 'Daily Health Tips for You', required this.tips});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 342,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 28 / 18,
                color: AppColors.headingText,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tip cards
          Column(
            children: tips
                .map(
                  (tip) => Padding(
                    padding: EdgeInsets.only(bottom: tip != tips.last ? 16 : 0),
                    child: _TipCard(item: tip),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
