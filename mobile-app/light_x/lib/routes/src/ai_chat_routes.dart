import 'package:light_x/features/ai_chat/ui/screens/ai_health_assistant.dart';
import 'package:light_x/routes/app_router.dart';

final aiChatRoutes = [
  GoRoute(path: Routes.aiChat.path, name: Routes.aiChat.name, builder: (context, state) => AiHealthAssistant()),
];
