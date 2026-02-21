import 'package:light_x/features/onboarding/ui/screens/onboarding_1.dart';
import 'package:light_x/routes/app_router.dart';

final onboardingRoutes = [
  GoRoute(
    path: Routes.onboarding1.path,
    name: Routes.onboarding1.name,
    builder: (context, state) => const Onboarding1(),
  ),
];
