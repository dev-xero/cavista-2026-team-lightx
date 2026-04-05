import 'package:flutter/material.dart';
import 'package:light_x/features/ai_chat/ui/entities/quick_action_item.dart';
import 'package:light_x/shared/components/inputs/app_text_form_field.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:remixicon/remixicon.dart';

// ─────────────────────────────────────────────
// Quick action chip
// ─────────────────────────────────────────────

class QuickActionChip extends StatelessWidget {
  final QuickActionItem action;
  final VoidCallback? onTap;

  const QuickActionChip({super.key, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

// ─────────────────────────────────────────────
// Suggested actions row
// ─────────────────────────────────────────────

class SuggestedActionsRow extends StatelessWidget {
  final List<QuickActionItem> actions;
  final ValueChanged<QuickActionItem>? onActionTap;

  const SuggestedActionsRow({super.key, required this.actions, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (context, i) {
          final action = actions[i];
          return QuickActionChip(action: action, onTap: onActionTap == null ? null : () => onActionTap!(action));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Send button
// ─────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _SendButton({this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 40,
        decoration: BoxDecoration(
          color: isLoading ? AppColors.sendBtnBg.withValues(alpha: 0.5) : AppColors.sendBtnBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(color: AppColors.sendBtnShadowStrong, blurRadius: 15, offset: Offset(0, 10)),
                  BoxShadow(color: AppColors.sendBtnShadowStrong, blurRadius: 6, offset: Offset(0, 4)),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded, color: AppColors.white, size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Chat input bar
// ─────────────────────────────────────────────

class ChatInputBar extends StatelessWidget {
  /// Owned by the ai chat notifier — do not create locally.
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final bool isLoading;

  const ChatInputBar({super.key, required this.controller, this.onSubmitted, this.isLoading = false});

  void _submit() {
    final text = controller.text.trim();
    if (text.isNotEmpty && !isLoading) {
      onSubmitted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      fillColor: AppColors.inputBg,
      borderColor: AppColors.border,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      hintText: 'Ask PulseAI anything...',
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
            _SendButton(onTap: _submit, isLoading: isLoading),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Chat footer
// ─────────────────────────────────────────────

class ChatFooter extends StatelessWidget {
  final List<QuickActionItem> suggestedActions;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<QuickActionItem>? onQuickActionTap;

  /// Pass notifier-owned [TextEditingController] here.
  final TextEditingController inputController;

  /// Loading flag from chat state.
  final bool isLoading;

  const ChatFooter({
    super.key,
    required this.suggestedActions,
    this.onSubmitted,
    this.onQuickActionTap,
    required this.inputController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.footerBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SuggestedActionsRow(actions: suggestedActions, onActionTap: onQuickActionTap),
          const SizedBox(height: 16),
          ChatInputBar(controller: inputController, onSubmitted: onSubmitted, isLoading: isLoading),
        ],
      ),
    );
  }
}
