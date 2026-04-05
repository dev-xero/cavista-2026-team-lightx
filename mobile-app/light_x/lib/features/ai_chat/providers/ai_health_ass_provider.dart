import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_health_ass_state.dart';
import 'package:light_x/features/ai_chat/providers/src/ai_health_ass_notifier.dart';

final _aiHealthAssNotifier = NotifierProvider.autoDispose<AiHealthAssNotifier, AiHealthAssState>(
  () => AiHealthAssNotifier(),
);

final _aiHealthAssProvider = Provider.autoDispose((ref) => AiHealthAssProvider(ref));

class AiHealthAssProvider {
  final Ref _ref;
  AiHealthAssProvider(this._ref);

  static final asPro = _aiHealthAssProvider;

  final state = _aiHealthAssNotifier;
}
