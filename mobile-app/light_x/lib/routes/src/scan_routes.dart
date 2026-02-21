import 'package:light_x/features/scan/ui/screens/scan_screen.dart';
import 'package:light_x/routes/app_router.dart';

final scanRoutes = [
  GoRoute(path: Routes.watchScan.path, name: Routes.watchScan.name, builder: (context, state) => const ScanScreen()),
];
