import 'package:light_x/features/home/ui/screens/main_screen.dart';
import 'package:light_x/routes/app_router.dart';

final mainRoutes = [
  GoRoute(name: Routes.home.name, path: Routes.home.path, builder: (context, state) => const MainScreen()),
];
