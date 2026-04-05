import 'package:light_x/features/ai_chat/providers/entities/ai_chat_message.dart';

class AiHealthAssState {
  final List<AiChatMessage> messages;
  final bool isLoading;
  final bool showThinking;
  final String? errorMessage;

  const AiHealthAssState({
    this.messages = const [],
    this.isLoading = false,
    this.showThinking = false,
    this.errorMessage,
  });

  AiHealthAssState copyWith({
    List<AiChatMessage>? messages,
    bool? isLoading,
    bool? showThinking,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiHealthAssState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      showThinking: showThinking ?? this.showThinking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory AiHealthAssState.d() {
    return AiHealthAssState(
      messages: [
        AiChatMessage.aiStatic(
          content:
              "I've finished analyzing your sleep patterns and heart rate from last night. "
              "Your recovery score is 85%.\n\n"
              "Would you like to dive deeper into any specific area or adjust your goals for today?",
        ),
      ],
    );
  }
}
