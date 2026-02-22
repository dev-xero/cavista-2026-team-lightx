import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:light_x/features/ai_chat/providers/ai_health_ass_provider.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/ai_health_chat_ui.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/chat_footer.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:provider/provider.dart';

class AiHealthAssistant extends StatelessWidget {
  const AiHealthAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => AiHealthAssProvider(), child: const _AiHealthAssistantView());
  }
}

class _AiHealthAssistantView extends StatelessWidget {
  const _AiHealthAssistantView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiHealthAssProvider>();

    return AppScaffold(
      appBarPadding: (a) => EdgeInsets.zero,
      appBar: _buildAppBar(provider),
      viewPadding: const EdgeInsets.symmetric(horizontal: 0),
      body: Column(
        children: [
          Container(height: 1, width: double.infinity, color: const Color(0xFFE2E8F0)),

          Expanded(
            child: Stack(
              children: [
                // ── Message list ───────────────────────────────────
                ListView.separated(
                  controller: provider.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
                  itemCount: provider.messages.length + (provider.showThinking ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, i) {
                    // Thinking bubble appended after real messages
                    if (provider.showThinking && i == provider.messages.length) {
                      return const AiThinkingBubble();
                    }

                    final msg = provider.messages[i];

                    if (msg.role == MessageRole.user) {
                      return UserMessageBubble(text: msg.content);
                    }

                    // AI bubble — streams content token by token
                    return AiMessageBubble(
                      children: [
                        // Context cards (e.g. sleep report card)
                        ...msg.contextWidgets,
                        if (msg.contextWidgets.isNotEmpty) const SizedBox(height: 12),

                        // Markdown content — grows as tokens arrive
                        if (msg.content.isNotEmpty)
                          MarkdownBody(
                            data: msg.content,
                            styleSheet: MarkdownStyleSheet(
                              p: AppTextStyles.messageBody,
                              strong: AppTextStyles.messageBody.copyWith(fontWeight: FontWeight.w700),
                              em: AppTextStyles.messageBody.copyWith(fontStyle: FontStyle.italic),
                              h1: AppTextStyles.messageBody.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                              h2: AppTextStyles.messageBody.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                              h3: AppTextStyles.messageBody.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                              listBullet: AppTextStyles.messageBody,
                              code: AppTextStyles.messageBody.copyWith(
                                fontFamily: 'monospace',
                                backgroundColor: const Color(0xFFF1F5F9),
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              blockquoteDecoration: BoxDecoration(
                                border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
                              ),
                              blockquotePadding: const EdgeInsets.only(left: 12),
                              pPadding: EdgeInsets.zero,
                              listIndent: 16,
                            ),
                            softLineBreak: true,
                          ),

                        // Blinking cursor while streaming and no content yet
                        if (msg.isStreaming && msg.content.isEmpty) const _StreamingCursor(),
                      ],
                    );
                  },
                ),

                // ── Error banner ───────────────────────────────────
                if (provider.errorMessage != null)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _ErrorBanner(message: provider.errorMessage!, onRetry: provider.retryLast),
                  ),

                // ── Footer pinned to bottom ────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ChatFooter(
                    suggestedActions: provider.quickActions
                        .map((a) => QuickAction(icon: a.icon, label: a.label, onTap: () => provider.sendQuickAction(a)))
                        .toList(),
                    inputController: provider.inputController,
                    isLoading: provider.isLoading,
                    onSubmitted: provider.sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AiHealthAssProvider provider) {
    return AppBar(
      leading: Padding(padding: const EdgeInsets.only(left: 8), child: AppBackButton()),
      centerTitle: true,
      backgroundColor: Colors.white,
      actions: [
        // Clear conversation button
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: AppColors.textMuted,
          tooltip: 'Clear chat',
          onPressed: provider.clearConversation,
        ),
      ],
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            "Pulse Ai",
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 22 / 18,
            letterSpacing: -0.45,
            color: AppColors.brandBlue,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: provider.isLoading ? AppColors.primary : AppColors.statusGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              AppText(
                provider.isLoading ? "Thinking..." : "Analyzing Data",
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.5,
                letterSpacing: 0.5,
                color: AppColors.subtleText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Streaming cursor ───────────────────────────────────────────────────────────

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor();

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _ctrl,
    child: Container(
      width: 2,
      height: 16,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), fontFamily: 'Manrope'),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
                fontFamily: 'Manrope',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
