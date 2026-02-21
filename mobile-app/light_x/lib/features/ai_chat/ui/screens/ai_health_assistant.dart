import 'package:flutter/material.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/ai_health_chat_ui.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/chat_footer.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';

class AiHealthAssistant extends StatelessWidget {
  const AiHealthAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: const SizedBox(),
      appBarPadding: (a) => EdgeInsets.zero,
      appBar: _buildAppBar(),
      viewPadding: EdgeInsets.symmetric(horizontal: 0),

      body: Column(
        children: [
          Container(height: 1, width: double.infinity, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // AI message with context card
                            AiMessageBubble(
                              children: [
                                Text(
                                  "I've finished analyzing your sleep patterns and heart rate "
                                  "from last night. Your recovery score is 85%.",
                                  style: AppTextStyles.messageBody,
                                ),
                                const SizedBox(height: 12),
                                const AnalysisContextCard(
                                  title: 'Sleep Quality Report',
                                  subtitle: 'Last night · 7h 42m',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Would you like to dive deeper into any specific area or '
                                  'adjust your goals for today?',
                                  style: AppTextStyles.messageBody,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // User message
                            const UserMessageBubble(
                              text:
                                  "Yes, let's focus on my deep sleep percentage. "
                                  "It felt like I woke up tired.",
                            ),

                            const SizedBox(height: 24),

                            // AI thinking state
                            const AiThinkingBubble(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,

                  child: ChatFooter(
                    suggestedActions: suggestedActions,
                    onSubmitted: (text) {
                      // Handle message submission
                      debugPrint('User sent: $text');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: const SizedBox(),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App name
          Text(
            "Pulse8 Ai",
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
              AppText(
                "Analyzing Data".toUpperCase(),
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
