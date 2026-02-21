import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:light_x/routes/src/onboarding.dart';

import 'src/splash_route.dart';

export 'package:go_router/go_router.dart';

part 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    routes: [splashRoute, ...onboardingRoutes],
  );
}
