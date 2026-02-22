import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:light_x/core/apis/api_paths.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/ai_health_chat_ui.dart';
import 'package:light_x/features/ai_chat/ui/widgets/ai_health_assistant/chat_footer.dart';
import 'package:light_x/routes/app_router.dart';

class _TopicCard {
  final List<String> keywords;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _TopicCard({
    required this.keywords,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Message model
// ─────────────────────────────────────────────────────────────────────────────

const _tag = 'AiHealthAss';

enum MessageRole { ai, user }

class ChatMessage {
  final String id;
  final MessageRole role;

  /// For AI messages this grows token-by-token while [isStreaming] is true.
  String content;

  /// True while the API is still pushing tokens into this message.
  bool isStreaming;

  /// Wall-clock time this message was created.
  final DateTime timestamp;

  /// Cards auto-injected after streaming completes based on keyword detection.
  List<Widget> contextWidgets;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.isStreaming = false,
    this.contextWidgets = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String text) => ChatMessage(id: _uid(), role: MessageRole.user, content: text);

  factory ChatMessage.aiThinking() => ChatMessage(id: _uid(), role: MessageRole.ai, content: '', isStreaming: true);

  factory ChatMessage.aiStatic({required String content, List<Widget> contextWidgets = const []}) =>
      ChatMessage(id: _uid(), role: MessageRole.ai, content: content, contextWidgets: contextWidgets);

  static int _counter = 0;
  static String _uid() => 'msg_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class AiHealthAssProvider extends ChangeNotifier {
  // ── Public state ────────────────────────────────────────────────────────────

  /// All messages in chronological order.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// True while an API request is in flight.
  bool get isLoading => _isLoading;

  /// Non-null when the last API call failed.
  String? get errorMessage => _errorMessage;

  /// Quick-action chips shown above the input bar.
  List<QuickAction> get quickActions => _quickActions;

  /// Whether the thinking bubble should be visible.
  bool get showThinking => _showThinking;

  /// Scroll controller — attach to the chat ListView so the provider can
  /// auto-scroll to bottom after each new token/message.
  final ScrollController scrollController = ScrollController();

  /// Text controller for the input bar — provider owns lifecycle.
  final TextEditingController inputController = TextEditingController();

  // ── Private state ───────────────────────────────────────────────────────────

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showThinking = false;
  String? _errorMessage;
  StreamSubscription<String>? _streamSub;

  // ── Quick actions ───────────────────────────────────────────────────────────

  final List<QuickAction> _quickActions = [
    QuickAction(icon: Icons.bar_chart_rounded, label: 'View Deep Sleep'),
    QuickAction(icon: Icons.favorite_rounded, label: 'Heart Rate Zones'),
    QuickAction(icon: Icons.flag_rounded, label: 'Set Goals'),
  ];

  // ── Initial greeting ────────────────────────────────────────────────────────

  AiHealthAssProvider() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage.aiStatic(
        content:
            "I've finished analyzing your sleep patterns and heart rate from last night. "
            "Your recovery score is 85%.\n\n"
            "Would you like to dive deeper into any specific area or adjust your goals for today?",
      ),
    );
  }

  // ── Send ─────────────────────────────────────────────────────────────────────

  /// Call from the UI when the user taps Send or presses Enter.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _clearError();
    inputController.clear();

    // 1. Add user bubble immediately.
    final userMsg = ChatMessage.user(trimmed);
    _messages.add(userMsg);
    _showThinking = true;
    _isLoading = true;
    notifyListeners();
    _scrollToBottom();

    log('→ USER [${userMsg.id}] "${trimmed.length > 80 ? "${trimmed.substring(0, 80)}…" : trimmed}"', name: _tag);

    // 2. Build context string from prior turns for the API.
    final context = _buildContext(trimmed);
    log('   context length: ${context.length} chars', name: _tag);

    // 3. Stream the response.
    try {
      await _streamResponse(message: trimmed, context: context);
    } catch (e, st) {
      log('STREAM ERROR: $e', name: _tag, error: e, stackTrace: st);
      _errorMessage = _friendlyError(e);
      _showThinking = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Shortcut: send a quick-action label as a user message.
  Future<void> sendQuickAction(QuickAction action) async {
    await sendMessage(action.label);
  }

  // ── Streaming ────────────────────────────────────────────────────────────────

  Future<void> _streamResponse({required String message, required String context}) async {
    // ── Request ────────────────────────────────────────────────────────────────
    final body = jsonEncode({'message': message, 'context': context});

    final request = http.Request('POST', Uri.parse(ApiPaths.chat))
      ..headers['Content-Type'] = 'application/json'
      ..body = body;

    log('POST /chat  body=${body.length}B', name: _tag);
    final requestStart = DateTime.now();

    final response = await http.Client().send(request);
    final ttfb = DateTime.now().difference(requestStart).inMilliseconds;
    log('HTTP ${response.statusCode}  ttfb=${ttfb}ms', name: _tag);

    if (response.statusCode != 200) {
      final errBody = await response.stream.bytesToString();
      log('Error body: $errBody', name: _tag);
      try {
        final decoded = jsonDecode(errBody) as Map<String, dynamic>;
        final detail = decoded['detail'];
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first as Map<String, dynamic>;
          throw Exception(first['msg'] ?? 'Validation error');
        }
      } catch (_) {}
      throw Exception('Server ${response.statusCode}: $errBody');
    }

    // ── Create streaming AI bubble ─────────────────────────────────────────────
    final aiMsg = ChatMessage.aiThinking();
    _messages.add(aiMsg);
    _showThinking = false;
    notifyListeners();
    _scrollToBottom();

    log('AI [${aiMsg.id}] stream started', name: _tag);

    // ── Parse SSE ──────────────────────────────────────────────────────────────
    final completer = Completer<void>();
    int chunkCount = 0;
    int totalBytes = 0;
    final streamStart = DateTime.now();

    _streamSub = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.isEmpty) return;

            if (!line.startsWith('data: ')) {
              log('unexpected SSE line: "$line"', name: _tag);
              return;
            }

            final payload = line.substring(6);

            if (payload == '[DONE]') {
              final elapsed = DateTime.now().difference(streamStart).inMilliseconds;
              log(
                'AI [${aiMsg.id}] DONE  chunks=$chunkCount  bytes=$totalBytes  '
                'elapsed=${elapsed}ms  chars=${aiMsg.content.length}',
                name: _tag,
              );
              _finaliseStream(aiMsg);
              if (!completer.isCompleted) completer.complete();
              return;
            }

            String token = payload;
            try {
              final decoded = jsonDecode(payload);
              if (decoded is String) token = decoded;
            } catch (_) {}

            if (token.isNotEmpty) {
              chunkCount++;
              totalBytes += token.length;
              aiMsg.content += token;

              // Log every 10th chunk to avoid flooding, but always log #1
              if (chunkCount == 1 || chunkCount % 10 == 0) {
                log('  chunk #$chunkCount  +${token.length}B  total=${aiMsg.content.length}B', name: _tag);
              }

              notifyListeners();
              _scrollToBottom();
            }
          },
          onError: (e, st) {
            log('SSE stream error after $chunkCount chunks: $e', name: _tag, error: e, stackTrace: st);
            if (!completer.isCompleted) completer.completeError(e);
          },
          onDone: () {
            final elapsed = DateTime.now().difference(streamStart).inMilliseconds;
            log(
              'AI [${aiMsg.id}] stream closed  chunks=$chunkCount  bytes=$totalBytes  elapsed=${elapsed}ms',
              name: _tag,
            );
            _finaliseStream(aiMsg);
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: true,
        );

    await completer.future;
  }

  void _finaliseStream(ChatMessage msg) {
    msg.isStreaming = false;
    msg.contextWidgets = _detectContextCards(msg.content);
    if (msg.contextWidgets.isNotEmpty) {
      log('  injected ${msg.contextWidgets.length} context card(s)', name: _tag);
    }
    _isLoading = false;
    _showThinking = false;
    notifyListeners();
    _scrollToBottom();
  }

  // ── Keyword → context card scanner ──────────────────────────────────────────
  // After streaming completes we scan the full AI response for health topic
  // keywords and inject the matching navigation card(s) at the top of the
  // bubble. Only the highest-priority match per topic group is shown so the
  // same message never gets two "sleep" cards.
  //
  // To add a new destination:
  //   1. Add keyword strings to the relevant _TopicCard entry, or add a new one.
  //   2. Set route to whatever your app_router exposes.

  static final _topicCards = <_TopicCard>[
    _TopicCard(
      keywords: ['sleep', 'deep sleep', 'rem', 'light sleep', 'insomnia', 'bedtime', 'rest', 'nap'],
      title: 'Sleep Analysis',
      subtitle: 'View your full sleep report',
      icon: Icons.bedtime_rounded,
      route: Routes.healthAnalysis.path,
    ),
    _TopicCard(
      keywords: ['heart rate', 'bpm', 'heart', 'pulse', 'tachycardia', 'bradycardia', 'ecg', 'arrhythmia'],
      title: 'Heart Rate',
      subtitle: 'See heart rate zones & trends',
      icon: Icons.favorite_rounded,
      route: Routes.healthAnalysis.path,
    ),
    _TopicCard(
      keywords: ['blood oxygen', 'spo2', 'oxygen', 'saturation', 'hypoxia', 'breathing'],
      title: 'Blood Oxygen',
      subtitle: 'View SpO₂ history',
      icon: Icons.water_drop_rounded,
      route: Routes.healthAnalysis.path,
    ),
    _TopicCard(
      keywords: ['blood pressure', 'systolic', 'diastolic', 'hypertension', 'mmhg', 'bp'],
      title: 'Blood Pressure',
      subtitle: 'Track BP over time',
      icon: Icons.monitor_heart_rounded,
      route: Routes.healthAnalysis.path,
    ),
    _TopicCard(
      keywords: ['steps', 'walking', 'activity', 'exercise', 'workout', 'calories', 'distance', 'run', 'fitness'],
      title: 'Activity',
      subtitle: 'Daily steps & activity log',
      icon: Icons.directions_walk_rounded,
      route: Routes.healthAnalysis.path,
    ),
    _TopicCard(
      keywords: ['stress', 'hrv', 'heart rate variability', 'recovery', 'cortisol', 'anxiety', 'relax'],
      title: 'Stress & Recovery',
      subtitle: 'HRV and recovery score',
      icon: Icons.self_improvement_rounded,
      route: Routes.healthAnalysis.path,
    ),
    _TopicCard(
      keywords: ['battery', 'charge', 'watch battery', 'device battery'],
      title: 'Device Status',
      subtitle: 'Watch battery & sync info',
      icon: Icons.watch_rounded,
      route: Routes.healthAnalysis.path,
    ),
  ];

  List<Widget> _detectContextCards(String content) {
    if (content.isEmpty) return const [];

    final lower = content.toLowerCase();
    final cards = <Widget>[];

    for (final topic in _topicCards) {
      final matched = topic.keywords.any((kw) => lower.contains(kw));
      if (matched) {
        log('  keyword match → "${topic.title}"', name: _tag);
        cards.add(
          AnalysisContextCard(title: topic.title, subtitle: topic.subtitle, icon: topic.icon, route: topic.route),
        );
      }
    }

    return cards;
  }

  // ── Context builder ──────────────────────────────────────────────────────────
  // The /chat endpoint takes a flat "context" string — not a messages array.
  // We serialise prior turns as "User: ...\nAssistant: ..." so the backend LLM
  // has conversation history without needing session state on its side.
  String _buildContext(String currentMessage) {
    // All messages except the one we just added (last entry is current user msg).
    final prior = _messages.where((m) => m.content.isNotEmpty).toList()
      ..removeWhere((m) => m == _messages.last); // exclude the just-added msg

    if (prior.isEmpty) return 'No previous context found.';

    return prior
        .map((m) {
          final prefix = m.role == MessageRole.user ? 'User' : 'Assistant';
          return '$prefix: ${m.content.trim()}';
        })
        .join('\n');
  }

  // ── Scroll ───────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _clearError() {
    _errorMessage = null;
  }

  void retryLast() {
    log('RETRY triggered', name: _tag);
    if (_messages.isNotEmpty && _messages.last.role == MessageRole.ai) {
      log('  removing failed AI message [${_messages.last.id}]', name: _tag);
      _messages.removeLast();
    }
    final lastUser = _messages.lastWhere((m) => m.role == MessageRole.user, orElse: () => ChatMessage.user(''));
    if (lastUser.content.isNotEmpty) {
      log('  re-sending user message [${lastUser.id}]', name: _tag);
      _messages.removeLast();
      sendMessage(lastUser.content);
    } else {
      log('  nothing to retry', name: _tag);
    }
  }

  void clearConversation() {
    log('🗑 conversation cleared  (had ${_messages.length} messages)', name: _tag);
    _messages.clear();
    _isLoading = false;
    _showThinking = false;
    _errorMessage = null;
    _addWelcomeMessage();
    notifyListeners();
  }

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('422')) return 'Invalid request. Please try rephrasing.';
    if (msg.contains('429')) return 'Too many requests. Please wait a moment.';
    if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
      return 'Server error. Please try again shortly.';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused') || msg.contains('Network')) {
      return 'Cannot reach server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ── Dispose ──────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    log('provider disposed  (${_messages.length} messages in history)', name: _tag);
    _streamSub?.cancel();
    scrollController.dispose();
    inputController.dispose();
    super.dispose();
  }
}
