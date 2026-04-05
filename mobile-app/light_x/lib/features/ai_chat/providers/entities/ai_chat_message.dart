enum AiMessageRole { ai, user }

enum AiChatTopic { sleep, heartRate, goals }

class AiChatMessage {
  final String id;
  final AiMessageRole role;
  final String content;
  final bool isStreaming;
  final DateTime timestamp;
  final List<AiChatTopic> contextTopics;

  AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.isStreaming = false,
    this.contextTopics = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  AiChatMessage copyWith({
    String? id,
    AiMessageRole? role,
    String? content,
    bool? isStreaming,
    List<AiChatTopic>? contextTopics,
    DateTime? timestamp,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      isStreaming: isStreaming ?? this.isStreaming,
      contextTopics: contextTopics ?? this.contextTopics,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory AiChatMessage.user(String text) => AiChatMessage(id: _uid(), role: AiMessageRole.user, content: text);

  factory AiChatMessage.aiThinking() =>
      AiChatMessage(id: _uid(), role: AiMessageRole.ai, content: '', isStreaming: true);

  factory AiChatMessage.aiStatic({required String content, List<AiChatTopic> contextTopics = const []}) =>
      AiChatMessage(id: _uid(), role: AiMessageRole.ai, content: content, contextTopics: contextTopics);

  static int _counter = 0;
  static String _uid() => 'msg_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
}
