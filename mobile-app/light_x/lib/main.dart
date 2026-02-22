import 'package:flutter/material.dart';
import 'package:light_x/app.dart';
import 'package:light_x/core/storage/shared_prefs/shared_prefs.dart';
import 'package:light_x/features/home/providers/analysis_provider.dart';
import 'package:light_x/features/home/providers/main_screen_provider.dart';
import 'package:light_x/features/onboarding/providers/onboarding_provider.dart';
import 'package:light_x/features/scan/providers/face_scanner_provider.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.initialize();
  runApp(_providerWrapper());
}

MultiProvider _providerWrapper() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MainScreenProvider()),
      ChangeNotifierProvider(create: (c) => OnboardingProvider()),
      ChangeNotifierProvider(create: (c) => HealthProvider()),
      ChangeNotifierProvider(create: (c) => FaceScannerProvider()),
      ChangeNotifierProvider(create: (c) => AnalysisProvider()),
    ],
    child: const App(),
  );
}
