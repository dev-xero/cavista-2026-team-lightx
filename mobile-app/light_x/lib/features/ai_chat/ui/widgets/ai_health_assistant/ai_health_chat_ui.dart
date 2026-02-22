import 'package:flutter/material.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';

// ─────────────────────────────────────────────
// Reusable Widgets
// ─────────────────────────────────────────────

/// Circular avatar with a white icon, used for the AI sender.
class AiAvatar extends StatelessWidget {
  const AiAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: AppColors.primaryShadowStrong, blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: AppColors.primaryShadowSoft, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: const Center(child: Icon(Icons.auto_awesome, color: AppColors.white, size: 16)),
    );
  }
}

/// Circular avatar used for the human sender.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.userAvatarBg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.userAvatarBorder, width: 2),
      ),
      child: const Center(child: Icon(Icons.person, color: AppColors.white, size: 20)),
    );
  }
}

/// A small card embedded inside an AI message bubble, e.g. a report reference.
/// Tap it to navigate — pass either [onTap] for full control or [route] for
/// a simple push via named routes.
class AnalysisContextCard extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Custom icon for the leading tile. Defaults to [Icons.bedtime].
  final IconData icon;

  /// Called when the card is tapped. Takes priority over [route].
  final VoidCallback? onTap;

  /// Named route to push when tapped (used if [onTap] is null).
  final String? route;

  /// Arguments forwarded to [route] via [Navigator.pushNamed].
  final Object? routeArguments;

  const AnalysisContextCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.bedtime,
    this.onTap,
    this.route,
    this.routeArguments,
  });

  bool get _tappable => onTap != null || route != null;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    if (route != null) {
      context.push(route!, extra: routeArguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tappable ? () => _handleTap(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
              child: Center(child: Icon(icon, color: AppColors.primary, size: 18)),
            ),
            const SizedBox(width: 12),
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.cardSubtitle),
                ],
              ),
            ),
            // Chevron — highlighted when tappable
            Icon(Icons.chevron_right, color: _tappable ? AppColors.primary : AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Bubble + sender label for an AI message. Accepts arbitrary child content.
class AiMessageBubble extends StatelessWidget {
  final List<Widget> children;

  const AiMessageBubble({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AiAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender label with left padding
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('PulseAid AI', style: AppTextStyles.senderLabel),
              ),
              const SizedBox(height: 8),
              // Bubble
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14.75, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bubble + sender label for a user message.
class UserMessageBubble extends StatelessWidget {
  final String text;

  const UserMessageBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text('You', style: AppTextStyles.senderLabel),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 284),
                padding: const EdgeInsets.fromLTRB(16, 16, 19, 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: const [
                    BoxShadow(color: AppColors.primaryShadowStrong, blurRadius: 15, offset: Offset(0, 10)),
                    BoxShadow(color: AppColors.primaryShadowSoft, blurRadius: 6, offset: Offset(0, 4)),
                  ],
                ),
                child: Text(text, style: AppTextStyles.messageBodyWhite),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const UserAvatar(),
      ],
    );
  }
}

/// Three animated dots shown while the AI is generating a response.
class AiThinkingBubble extends StatefulWidget {
  const AiThinkingBubble({super.key});

  @override
  State<AiThinkingBubble> createState() => _AiThinkingBubbleState();
}

class _AiThinkingBubbleState extends State<AiThinkingBubble> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
        ..repeat(reverse: true, period: Duration(milliseconds: 1200 + i * 200));
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    // Stagger starts
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AiAvatar(),
        const SizedBox(width: 12),
        Container(
          width: 60,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              return FadeTransition(
                opacity: _animations[i],
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.thinkingDot, shape: BoxShape.circle),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
