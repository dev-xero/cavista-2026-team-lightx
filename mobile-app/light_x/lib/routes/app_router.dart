import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:light_x/routes/src/ai_chat_routes.dart';
import 'package:light_x/routes/src/main_routes.dart';
import 'package:light_x/routes/src/onboarding_routes.dart';
import 'package:light_x/routes/src/pricing_route.dart';
import 'package:light_x/routes/src/scan_routes.dart';

import 'src/splash_route.dart';

export 'package:go_router/go_router.dart';

part 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: Routes.home.path,
    navigatorKey: rootNavigatorKey,
    routes: [splashRoute, ...onboardingRoutes, ...mainRoutes, ...scanRoutes, ...aiChatRoutes, pricingRoute],
  );
}
