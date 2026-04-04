// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:light_x/core/apis/api.dart';
// import 'package:light_x/core/apis/api_paths.dart';
// import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/ai_health_chat_ui.dart';
// import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/chat_footer.dart';
// import 'package:light_x/routes/app_router.dart';

// class _TopicCard {
//   final List<String> keywords;
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final String route;

//   const _TopicCard({
//     required this.keywords,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.route,
//   });
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Message model
// // ─────────────────────────────────────────────────────────────────────────────

// const _tag = 'AiHealthAss';

// enum MessageRole { ai, user }

// class ChatMessage {
//   final String id;
//   final MessageRole role;

//   /// For AI messages this grows token-by-token while [isStreaming] is true.
//   String content;

//   /// True while the API is still pushing tokens into this message.
//   bool isStreaming;

//   /// Wall-clock time this message was created.
//   final DateTime timestamp;

//   /// Cards auto-injected after streaming completes based on keyword detection.
//   List<Widget> contextWidgets;

//   ChatMessage({
//     required this.id,
//     required this.role,
//     required this.content,
//     this.isStreaming = false,
//     this.contextWidgets = const [],
//     DateTime? timestamp,
//   }) : timestamp = timestamp ?? DateTime.now();

//   factory ChatMessage.user(String text) => ChatMessage(id: _uid(), role: MessageRole.user, content: text);

//   factory ChatMessage.aiThinking() => ChatMessage(id: _uid(), role: MessageRole.ai, content: '', isStreaming: true);

//   factory ChatMessage.aiStatic({required String content, List<Widget> contextWidgets = const []}) =>
//       ChatMessage(id: _uid(), role: MessageRole.ai, content: content, contextWidgets: contextWidgets);

//   static int _counter = 0;
//   static String _uid() => 'msg_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Provider
// // ─────────────────────────────────────────────────────────────────────────────

// class AiHealthAssProvider extends ChangeNotifier {
//   // ── Public state ────────────────────────────────────────────────────────────

//   /// All messages in chronological order.
//   List<ChatMessage> get messages => List.unmodifiable(_messages);

//   /// True while an API request is in flight.
//   bool get isLoading => _isLoading;

//   /// Quick-action chips shown above the input bar.
//   List<QuickAction> get quickActions => _quickActions;

//   /// Whether the thinking bubble should be visible.
//   bool get showThinking => _showThinking;

//   /// Scroll controller — attach to the chat ListView so the provider can
//   /// auto-scroll to bottom after each new token/message.
//   final ScrollController scrollController = ScrollController();

//   /// Text controller for the input bar — provider owns lifecycle.
//   final TextEditingController inputController = TextEditingController();

//   // ── Private state ───────────────────────────────────────────────────────────

//   final List<ChatMessage> _messages = [];
//   bool _isLoading = false;
//   bool _showThinking = false;
//   StreamSubscription<String>? _streamSub;

//   // ── Quick actions ───────────────────────────────────────────────────────────

//   final List<QuickAction> _quickActions = [
//     QuickAction(icon: Icons.bar_chart_rounded, label: 'View Deep Sleep'),
//     QuickAction(icon: Icons.favorite_rounded, label: 'Heart Rate Zones'),
//     QuickAction(icon: Icons.flag_rounded, label: 'Set Goals'),
//   ];

//   // ── Initial greeting ────────────────────────────────────────────────────────

//   AiHealthAssProvider() {
//     _addWelcomeMessage();
//   }

//   void _addWelcomeMessage() {
//     _messages.add(
//       ChatMessage.aiStatic(
//         content:
//             "I've finished analyzing your sleep patterns and heart rate from last night. "
//             "Your recovery score is 85%.\n\n"
//             "Would you like to dive deeper into any specific area or adjust your goals for today?",
//       ),
//     );
//   }

//   // ── Send ─────────────────────────────────────────────────────────────────────

//   /// Call from the UI when the user taps Send or presses Enter.
//   Future<void> sendMessage(String text) async {
//     final trimmed = text.trim();
//     if (trimmed.isEmpty || _isLoading) return;

//     _clearError();
//     inputController.clear();

//     // 1. Add user bubble immediately.
//     final userMsg = ChatMessage.user(trimmed);
//     _messages.add(userMsg);
//     _showThinking = true;
//     _isLoading = true;
//     notifyListeners();
//     _scrollToBottom();

//     log('→ USER [${userMsg.id}] "${trimmed.length > 80 ? "${trimmed.substring(0, 80)}…" : trimmed}"', name: _tag);

//     // 2. Build context string from prior turns for the API.
//     final context = _buildContext(trimmed);
//     log('   context length: ${context.length} chars', name: _tag);

//     // 3. Stream the response.
//     try {
//       await _streamResponse(message: trimmed, context: context);
//     } catch (e, st) {
//       log('STREAM ERROR: $e', name: _tag, error: e, stackTrace: st);
//       _errorMessage = _friendlyError(e);
//       _showThinking = false;
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Shortcut: send a quick-action label as a user message.
//   Future<void> sendQuickAction(QuickAction action) async {
//     await sendMessage(action.label);
//   }

//   // ── Streaming ────────────────────────────────────────────────────────────────

//   Future<void> sendMessage(String text) async {
//     final trimmed = text.trim();
//     if (trimmed.isEmpty || _isLoading) return;

//     _clearError();
//     inputController.clear();

//     // 1. UI State Update
//     final userMsg = ChatMessage.user(trimmed);
//     _messages.add(userMsg);
//     _showThinking = true;
//     _isLoading = true;
//     notifyListeners();
//     _scrollToBottom();

//     // 2. Get the Stream from Service
//     final result = await Api.instance.chat.streamChat(message: trimmed, context: _buildContext(trimmed));

//     if (!result.success) {
//       _errorMessage = _friendlyError(result.errorMsg);
//       _showThinking = false;
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     // 3. Consume the Stream
//     final aiMsg = ChatMessage.aiThinking();
//     _messages.add(aiMsg);
//     _showThinking = false;

//     try {
//       int chunkCount = 0;
//       await for (final token in result.data!) {
//         if (token.isNotEmpty) {
//           aiMsg.content += token;
//           chunkCount++;

//           // Only notify/scroll periodically or on first chunk to save performance
//           if (chunkCount == 1 || chunkCount % 5 == 0) {
//             notifyListeners();
//             _scrollToBottom();
//           }
//         }
//       }
//     } catch (e) {
//       log('Stream Interrupted: $e', name: _tag);
//     } finally {
//       _finaliseStream(aiMsg);
//     }
//   }

//   void _finaliseStream(ChatMessage msg) {
//     msg.isStreaming = false;
//     msg.contextWidgets = _detectContextCards(msg.content);
//     _isLoading = false;
//     _showThinking = false;
//     notifyListeners();
//     _scrollToBottom();
//   }

//   // ── Keyword → context card scanner ──────────────────────────────────────────
//   // After streaming completes we scan the full AI response for health topic
//   // keywords and inject the matching navigation card(s) at the top of the
//   // bubble. Only the highest-priority match per topic group is shown so the
//   // same message never gets two "sleep" cards.
//   //
//   // To add a new destination:
//   //   1. Add keyword strings to the relevant _TopicCard entry, or add a new one.
//   //   2. Set route to whatever your app_router exposes.

//   List<Widget> _detectContextCards(String content) {
//     if (content.isEmpty) return const [];

//     final lower = content.toLowerCase();
//     final cards = <Widget>[];

//     for (final topic in _topicCards) {
//       final matched = topic.keywords.any((kw) => lower.contains(kw));
//       if (matched) {
//         log('  keyword match → "${topic.title}"', name: _tag);
//         cards.add(
//           AnalysisContextCard(title: topic.title, subtitle: topic.subtitle, icon: topic.icon, route: topic.route),
//         );
//       }
//     }

//     return cards;
//   }

//   // ── Context builder ──────────────────────────────────────────────────────────
//   // The /chat endpoint takes a flat "context" string — not a messages array.
//   // We serialise prior turns as "User: ...\nAssistant: ..." so the backend LLM
//   // has conversation history without needing session state on its side.
//   String _buildContext(String currentMessage) {
//     // All messages except the one we just added (last entry is current user msg).
//     final prior = _messages.where((m) => m.content.isNotEmpty).toList()
//       ..removeWhere((m) => m == _messages.last); // exclude the just-added msg

//     if (prior.isEmpty) return 'No previous context found.';

//     return prior
//         .map((m) {
//           final prefix = m.role == MessageRole.user ? 'User' : 'Assistant';
//           return '$prefix: ${m.content.trim()}';
//         })
//         .join('\n');
//   }

//   // ── Scroll ───────────────────────────────────────────────────────────────────

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   // ── Helpers ──────────────────────────────────────────────────────────────────

//   void _clearError() {
//     _errorMessage = null;
//   }

//   void retryLast() {
//     log('RETRY triggered', name: _tag);
//     if (_messages.isNotEmpty && _messages.last.role == MessageRole.ai) {
//       log('  removing failed AI message [${_messages.last.id}]', name: _tag);
//       _messages.removeLast();
//     }
//     final lastUser = _messages.lastWhere((m) => m.role == MessageRole.user, orElse: () => ChatMessage.user(''));
//     if (lastUser.content.isNotEmpty) {
//       log('  re-sending user message [${lastUser.id}]', name: _tag);
//       _messages.removeLast();
//       sendMessage(lastUser.content);
//     } else {
//       log('  nothing to retry', name: _tag);
//     }
//   }

//   void clearConversation() {
//     log('🗑 conversation cleared  (had ${_messages.length} messages)', name: _tag);
//     _messages.clear();
//     _isLoading = false;
//     _showThinking = false;
//     _errorMessage = null;
//     _addWelcomeMessage();
//     notifyListeners();
//   }

//   static String _friendlyError(Object e) {
//     final msg = e.toString();
//     if (msg.contains('422')) return 'Invalid request. Please try rephrasing.';
//     if (msg.contains('429')) return 'Too many requests. Please wait a moment.';
//     if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
//       return 'Server error. Please try again shortly.';
//     }
//     if (msg.contains('SocketException') || msg.contains('Connection refused') || msg.contains('Network')) {
//       return 'Cannot reach server. Check your connection.';
//     }
//     return 'Something went wrong. Please try again.';
//   }

//   // ── Dispose ──────────────────────────────────────────────────────────────────

//   @override
//   void dispose() {
//     log('provider disposed  (${_messages.length} messages in history)', name: _tag);
//     _streamSub?.cancel();
//     scrollController.dispose();
//     inputController.dispose();
//     super.dispose();
//   }
// }
