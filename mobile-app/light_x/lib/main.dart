import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/app.dart';
import 'package:light_x/core/storage/shared_prefs/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.initialize();
  runApp(const ProviderScope(child: App()));
}

// MultiProvider _providerWrapper() {
//   return MultiProvider(
//     providers: [
//       ChangeNotifierProvider(create: (_) => MainScreenProvider()),
//       ChangeNotifierProvider(create: (c) => OnboardingProvider()),
//       ChangeNotifierProvider(create: (c) => HealthProvider()),
//       ChangeNotifierProvider(create: (c) => FaceScannerProvider()),
//       ChangeNotifierProvider(create: (c) => AnalysisProvider()),
//     ],
//     child: const App(),
//   );
// }
