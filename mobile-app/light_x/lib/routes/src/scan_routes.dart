import 'package:light_x/features/scan/ui/screens/face_scan_screen.dart';
import 'package:light_x/features/scan/ui/screens/health_screen.dart';
import 'package:light_x/features/scan/ui/screens/watch_scan_screen.dart';
import 'package:light_x/routes/app_router.dart';

final scanRoutes = [
  GoRoute(
    path: Routes.watchScan.path,
    name: Routes.watchScan.name,
    builder: (context, state) => const WatchScanScreen(),
  ),
  GoRoute(
    path: Routes.healthDataResult.path,
    name: Routes.healthDataResult.name,
    builder: (context, state) => const HealthScreen(),
  ),
  GoRoute(
    name: Routes.faceScan.name,
    path: Routes.faceScan.path,
    builder: (context, state) => const FaceScannerScreen(),
  ),
];
