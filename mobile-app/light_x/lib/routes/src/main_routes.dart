import 'package:light_x/features/home/providers/main_screen_provider.dart';
import 'package:light_x/features/home/ui/screens/main_screen.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:provider/provider.dart';

final mainRoutes = ShellRoute(
  builder: (context, state, child) => MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => MainScreenProvider())],
    child: child,
  ),
  routes: [
    GoRoute(name: Routes.home.name, path: Routes.home.path, builder: (context, state) => MainScreen(index: 0)),
    GoRoute(
      name: Routes.healthAnalysis.name,
      path: Routes.healthAnalysis.path,
      builder: (context, state) => MainScreen(index: 1),
    ),
  ],
);
