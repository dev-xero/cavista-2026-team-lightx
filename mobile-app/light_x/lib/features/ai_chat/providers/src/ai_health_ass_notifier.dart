import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/core/apis/api.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_chat_message.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_chat_topic_keywords.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_health_ass_state.dart';

const _tag = 'AiHealthAss';

class AiHealthAssNotifier extends Notifier<AiHealthAssState> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();

  bool _disposed = false;
  int _operationId = 0;

  @override
  AiHealthAssState build() {
    ref.onDispose(() {
      _disposed = true;
      scrollController.dispose();
      inputController.dispose();
    });

    return AiHealthAssState.d();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    inputController.clear();
    final opId = ++_operationId;

    final userMsg = AiChatMessage.user(trimmed);
    final nextMessages = [...state.messages, userMsg];

    state = state.copyWith(messages: nextMessages, showThinking: true, isLoading: true, clearError: true);
    _scrollToBottom();

    final history = nextMessages.sublist(0, nextMessages.length - 1);
    final result = await Api.instance.chat.streamChat(message: trimmed, context: _buildContext(history));

    if (_isStale(opId)) return;

    if (!result.success || result.data == null) {
      state = state.copyWith(
        isLoading: false,
        showThinking: false,
        errorMessage: Api.parseFriendlyError(result.errorMsg.toString()),
      );
      return;
    }

    var aiMsg = AiChatMessage.aiThinking();
    state = state.copyWith(messages: [...state.messages, aiMsg], showThinking: false);

    var streamFailed = false;
    try {
      int chunkCount = 0;
      await for (final token in result.data!) {
        if (_isStale(opId)) return;
        if (token.isEmpty) continue;

        aiMsg = aiMsg.copyWith(content: aiMsg.content + token);
        chunkCount++;

        if (chunkCount == 1 || chunkCount % 5 == 0) {
          _replaceLastMessage(aiMsg);
          _scrollToBottom();
        }
      }
    } catch (e, st) {
      streamFailed = true;
      log('Stream interrupted: $e', name: _tag, error: e, stackTrace: st);
      state = state.copyWith(errorMessage: Api.parseFriendlyError(e.toString()));
    } finally {
      if (_isStale(opId)) {
      } else if (streamFailed && aiMsg.content.trim().isEmpty) {
        final messages = [...state.messages];
        if (messages.isNotEmpty && messages.last.id == aiMsg.id) {
          messages.removeLast();
        }
        state = state.copyWith(messages: messages, isLoading: false, showThinking: false);
      } else {
        final completed = aiMsg.copyWith(isStreaming: false, contextTopics: _detectTopics(aiMsg.content));
        _replaceLastMessage(completed);
        state = state.copyWith(isLoading: false, showThinking: false);
        _scrollToBottom();
      }
    }
  }

  Future<void> sendQuickAction(String label) async {
    await sendMessage(label);
  }

  Future<void> retryLast() async {
    if (state.isLoading) return;

    final messages = state.messages;
    final lastUserIndex = messages.lastIndexWhere((m) => m.role == AiMessageRole.user);
    if (lastUserIndex == -1) return;

    final lastUser = messages[lastUserIndex];
    final keepUntilUser = messages.sublist(0, lastUserIndex + 1);
    state = state.copyWith(messages: keepUntilUser, clearError: true, showThinking: false, isLoading: false);

    final opId = ++_operationId;
    state = state.copyWith(showThinking: true, isLoading: true);
    _scrollToBottom();

    final result = await Api.instance.chat.streamChat(message: lastUser.content, context: _buildContext(keepUntilUser));

    if (_isStale(opId)) return;

    if (!result.success || result.data == null) {
      state = state.copyWith(
        isLoading: false,
        showThinking: false,
        errorMessage: Api.parseFriendlyError(result.errorMsg.toString()),
      );
      return;
    }

    var aiMsg = AiChatMessage.aiThinking();
    state = state.copyWith(messages: [...state.messages, aiMsg], showThinking: false);

    var streamFailed = false;
    try {
      int chunkCount = 0;
      await for (final token in result.data!) {
        if (_isStale(opId)) return;
        if (token.isEmpty) continue;

        aiMsg = aiMsg.copyWith(content: aiMsg.content + token);
        chunkCount++;

        if (chunkCount == 1 || chunkCount % 5 == 0) {
          _replaceLastMessage(aiMsg);
          _scrollToBottom();
        }
      }
    } catch (e, st) {
      streamFailed = true;
      log('Retry stream interrupted: $e', name: _tag, error: e, stackTrace: st);
      state = state.copyWith(errorMessage: Api.parseFriendlyError(e.toString()));
    } finally {
      if (_isStale(opId)) return;

      if (streamFailed && aiMsg.content.trim().isEmpty) {
        final messages = [...state.messages];
        if (messages.isNotEmpty && messages.last.id == aiMsg.id) {
          messages.removeLast();
        }
        state = state.copyWith(messages: messages, isLoading: false, showThinking: false);
        return;
      }

      final completed = aiMsg.copyWith(isStreaming: false, contextTopics: _detectTopics(aiMsg.content));
      _replaceLastMessage(completed);
      state = state.copyWith(isLoading: false, showThinking: false);
      _scrollToBottom();
    }
  }

  void clearConversation() {
    ++_operationId;
    state = AiHealthAssState.d();
  }

  List<AiChatTopic> _detectTopics(String content) {
    if (content.isEmpty) return const [];

    final lower = content.toLowerCase();
    final matches = <AiChatTopic>[];

    for (final entry in aiChatTopicKeywords.entries) {
      final matched = entry.value.any((kw) => lower.contains(kw));
      if (matched) {
        matches.add(entry.key);
      }
    }

    return matches;
  }

  String _buildContext(List<AiChatMessage> history) {
    final prior = history.where((m) => m.content.trim().isNotEmpty).toList();
    if (prior.isEmpty) return 'No previous context found.';

    return prior
        .map((m) {
          final prefix = m.role == AiMessageRole.user ? 'User' : 'Assistant';
          return '$prefix: ${m.content.trim()}';
        })
        .join('\n');
  }

  void _replaceLastMessage(AiChatMessage message) {
    final messages = [...state.messages];
    if (messages.isEmpty) return;
    messages[messages.length - 1] = message;
    state = state.copyWith(messages: messages);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  bool _isStale(int opId) => _disposed || opId != _operationId;
}
