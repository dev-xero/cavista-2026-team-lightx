// ignore_for_file: use_build_context_synchronously

import 'package:light_x/routes/app_router.dart';
import 'package:light_x/splash.dart';

final splashRoute = GoRoute(
  path: Routes.splash.path,
  name: Routes.splash.name,
  builder: (context, state) => const Splash(),
);
