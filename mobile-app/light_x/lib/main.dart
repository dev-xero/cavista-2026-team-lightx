import 'package:flutter/material.dart';
import 'package:light_x/app.dart';
import 'package:light_x/features/home/providers/main_screen_provider.dart';
import 'package:light_x/features/onboarding/providers/onboarding_provider.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainScreenProvider()),
        ChangeNotifierProvider(create: (c) => OnboardingProvider()),
        ChangeNotifierProvider(create: (c) => HealthProvider()),
      ],
      child: const App(),
    ),
  );
}
