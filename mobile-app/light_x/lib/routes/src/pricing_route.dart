import 'package:light_x/features/pricing/ui/premium_pricing.dart';
import 'package:light_x/routes/app_router.dart';

final pricingRoute = GoRoute(
  name: Routes.pricing.name,
  path: Routes.pricing.path,
  builder: (context, state) => const PricingScreen(),
);
