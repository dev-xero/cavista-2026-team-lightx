import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/core/base/src/absorber.dart';
import 'package:light_x/features/ai_chat/providers/ai_health_ass_provider.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_chat_message.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_health_ass_state.dart';
import 'package:light_x/features/ai_chat/providers/src/ai_health_ass_notifier.dart';
import 'package:light_x/features/ai_chat/ui/entities/quick_action_item.dart';
import 'package:light_x/features/ai_chat/ui/entities/topic_card.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/ai_health_chat_ui.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/chat_footer.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/src/streaming_cursor.dart';
import 'package:light_x/shared/components/banners/error_banner.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';

class AiHealthAssistant extends StatelessWidget {
  const AiHealthAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorberRead(
      listenable: AiHealthAssProvider.asPro,
      builder: (context, aiChatProvider, ref, _) {
        final aiChatStateProvider = aiChatProvider.state;
        final notifier = aiChatStateProvider.self(ref);

        return AppScaffold(
          appBarPadding: (a) => EdgeInsets.zero,
          appBar: _buildAppBar(aiChatStateProvider, notifier.clearConversation),
          viewPadding: const EdgeInsets.symmetric(horizontal: 0),
          body: Column(
            children: [
              Container(height: 1, width: double.infinity, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Stack(
                  children: [
                    AbsorberSelect<AiHealthAssState, ({List<AiChatMessage> messages, bool showThinking})>(
                      listenable: aiChatStateProvider,
                      selector: (s) => (messages: s.messages, showThinking: s.showThinking),
                      builder: (_, data, __, ___) {
                        final messages = data.messages;
                        final showThinking = data.showThinking;

                        return ListView.separated(
                          controller: notifier.scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
                          itemCount: messages.length + (showThinking ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 24),
                          itemBuilder: (context, i) {
                            if (showThinking && i == messages.length) {
                              return const AiThinkingBubble();
                            }

                            final msg = messages[i];
                            if (msg.role == AiMessageRole.user) {
                              return UserMessageBubble(text: msg.content);
                            }

                            final cards = msg.contextTopics
                                .map((topic) => topicCatalog[topic])
                                .whereType<TopicCard>()
                                .map(
                                  (card) => AnalysisContextCard(
                                    title: card.title,
                                    subtitle: card.subtitle,
                                    icon: card.icon,
                                    route: card.route,
                                  ),
                                )
                                .toList(growable: false);

                            return AiMessageBubble(
                              children: [
                                ...cards,
                                if (cards.isNotEmpty) const SizedBox(height: 12),
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
                                if (msg.isStreaming && msg.content.isEmpty) const StreamingCursor(),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    AbsorberSelect<AiHealthAssState, String?>(
                      listenable: aiChatStateProvider,
                      selector: (s) => s.errorMessage,
                      builder: (_, errorMessage, __, ___) {
                        if (errorMessage == null) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          top: 12,
                          left: 16,
                          right: 16,
                          child: ErrorBanner(message: errorMessage, onRetry: notifier.retryLast),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AbsorberSelect<AiHealthAssState, bool>(
                        listenable: aiChatStateProvider,
                        selector: (s) => s.isLoading,
                        builder: (_, isLoading, __, ___) {
                          return ChatFooter(
                            suggestedActions: defaultAiQuickActions,
                            inputController: notifier.inputController,
                            isLoading: isLoading,
                            onSubmitted: notifier.sendMessage,
                            onQuickActionTap: (action) => notifier.sendQuickAction(action.label),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(NotifierProvider<AiHealthAssNotifier, AiHealthAssState> stateProvider, VoidCallback onClear) {
    return AppBar(
      leading: const Padding(padding: EdgeInsets.only(left: 8), child: AppBackButton()),
      centerTitle: true,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: AppColors.textMuted,
          tooltip: 'Clear chat',
          onPressed: onClear,
        ),
      ],
      title: AbsorberSelect<AiHealthAssState, bool>(
        listenable: stateProvider,
        selector: (s) => s.isLoading,
        builder: (_, isLoading, __, ___) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                'Pulse Ai',
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
                      color: isLoading ? AppColors.primary : AppColors.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    isLoading ? 'Thinking...' : 'Analyzing Data',
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 1.5,
                    letterSpacing: 0.5,
                    color: AppColors.subtleText,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
