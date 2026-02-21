import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:light_x/features/scan/ui/screens/health_screen.dart';
import 'package:light_x/features/scan/ui/screens/scan_screen.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:provider/provider.dart';

final scanRoute = ShellRoute(
  builder: (context, state, child) => ChangeNotifierProvider(create: (c) => HealthProvider(), child: child),
  routes: [
    GoRoute(path: Routes.watchScan.path, name: Routes.watchScan.name, builder: (context, state) => const ScanScreen()),
    GoRoute(
      path: Routes.healthDataResult.path,
      name: Routes.healthDataResult.name,
      builder: (context, state) => const HealthScreen(),
    ),
  ],
);
