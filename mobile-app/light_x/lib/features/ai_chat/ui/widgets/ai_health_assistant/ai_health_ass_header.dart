import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: AppColors.subtleText),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Brand / logo center column
// ─────────────────────────────────────────────

class _BrandCenter extends StatelessWidget {
  final String appName;
  final String statusLabel;

  const _BrandCenter({required this.appName, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App name
        Text(
          appName,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 22 / 18,
            letterSpacing: -0.45,
            color: AppColors.brandBlue,
          ),
        ),

        const SizedBox(height: 0),

        // Status row: green dot + label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green dot
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.statusGreen, shape: BoxShape.circle),
            ),

            const SizedBox(width: 6),

            // Status text
            Text(
              statusLabel.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.5,
                letterSpacing: 0.5,
                color: AppColors.subtleText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Public header widget
// ─────────────────────────────────────────────

class AiHealthAssHeader extends StatelessWidget implements PreferredSizeWidget {
  final String appName;
  final String statusLabel;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const AiHealthAssHeader({
    super.key,
    this.appName = 'PulseAid Ai',
    this.statusLabel = 'AI Active',
    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(73);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 73,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.headerBackground,
          border: Border(bottom: BorderSide(color: AppColors.headerBorder, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: menu / hamburger button
            _HeaderIconButton(icon: Icons.menu, onTap: onMenuTap),

            // Center: brand + status
            _BrandCenter(appName: appName, statusLabel: statusLabel),

            // Right: notification / bell button
            _HeaderIconButton(icon: Icons.notifications_outlined, onTap: onNotificationTap),
          ],
        ),
      ),
    );
  }
}
