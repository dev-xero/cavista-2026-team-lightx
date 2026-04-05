import 'package:light_x/features/ai_chat/providers/entities/ai_chat_message.dart';

const aiChatTopicKeywords = <AiChatTopic, List<String>>{
  AiChatTopic.sleep: ['sleep', 'deep sleep', 'rem', 'recovery', 'rest'],
  AiChatTopic.heartRate: ['heart', 'heart rate', 'hrv', 'pulse', 'cardio'],
  AiChatTopic.goals: ['goal', 'goals', 'target', 'plan', 'habit'],
};
