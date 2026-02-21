import 'package:flutter/material.dart';
import 'package:light_x/shared/components/inputs/app_text_form_field.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:remixicon/remixicon.dart';

const suggestedActions = [
  QuickAction(icon: Icons.bar_chart_rounded, label: 'View Deep Sleep'),
  QuickAction(icon: Icons.favorite_rounded, label: 'Heart Rate Zones'),
  QuickAction(icon: Icons.flag_rounded, label: 'Set Goals'),
];
// ─────────────────────────────────────────────
// Footer Widgets
// ─────────────────────────────────────────────

/// Model for a quick-action chip shown above the input bar.
class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickAction({required this.icon, required this.label, this.onTap});
}

/// A single pill-shaped quick-action chip.
class QuickActionChip extends StatelessWidget {
  final QuickAction action;

  const QuickActionChip({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          border: Border.all(color: AppColors.chipBorder),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: AppColors.primary, size: 15),
            const SizedBox(width: 8),
            Text(action.label, style: AppTextStyles.chipLabel),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of [QuickActionChip]s.
class SuggestedActionsRow extends StatelessWidget {
  final List<QuickAction> actions;

  const SuggestedActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (context, i) => QuickActionChip(action: actions[i]),
      ),
    );
  }
}

/// The send button inside the input bar.
class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SendButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.sendBtnBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.sendBtnShadowStrong, blurRadius: 15, offset: Offset(0, 10)),
            BoxShadow(color: AppColors.sendBtnShadowStrong, blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        child: const Center(child: Icon(Icons.send_rounded, color: AppColors.white, size: 18)),
      ),
    );
  }
}

/// The text field + send button row.
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String>? onSubmitted;

  const ChatInputBar({super.key, this.onSubmitted});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted?.call(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: _controller,
      fillColor: AppColors.inputBg,
      borderColor: AppColors.border,

      contentPadding: EdgeInsets.symmetric(vertical: 8),
      hintText: 'Ask Pulse8 anything...',
      onFieldSubmitted: (_) => _submit(),

      prefixIcon: SizedBox(
        width: 40,
        height: 40,
        child: Icon(RemixIcons.attachment_2, color: AppColors.iconMuted, size: 20),
      ),
      suffix: SizedBox(
        width: 56,
        child: Row(
          children: [
            const SizedBox(width: 4),
            // Send button
            _SendButton(onTap: _submit),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// The full frosted-glass footer: suggested actions + input bar.
class ChatFooter extends StatelessWidget {
  final List<QuickAction> suggestedActions;
  final ValueChanged<String>? onSubmitted;

  const ChatFooter({super.key, required this.suggestedActions, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ColorFilter.mode(AppColors.footerBg, BlendMode.srcOver),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.footerBg,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SuggestedActionsRow(actions: suggestedActions),
              const SizedBox(height: 16),
              ChatInputBar(onSubmitted: onSubmitted),
            ],
          ),
        ),
      ),
    );
  }
}
