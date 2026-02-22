part of 'app_router.dart';

/// pattern
/// Route - extra: Arg
/// Path follows subPath
///
enum Routes {
  splash,

  onboarding1,
  onboarding2,

  // ============================================================================
  // MISC
  // ============================================================================
  emptyState,

  // ============================================================================
  // AUTH SCREENS
  // ============================================================================

  // ============================================================================
  // MAIN SCREENS
  // ============================================================================
  home,
  healthAnalysis,

  watchScan,
  healthDataResult,

  aiChat,
  faceScan,
  pricing,
  faceScanResult,
}

extension RoutesExtension on Routes {
  String get path => name.withSlashPrefix;
  String get subPath => name;

  void push(BuildContext context, [Object? extra]) => context.pushNamed(name, extra: extra);
  void pushReplacement(BuildContext context, [Object? extra]) => context.pushReplacementNamed(name, extra: extra);
  void go(BuildContext context, [Object? extra]) => context.goNamed(name, extra: extra);
}

extension RoutesHelper on String {
  String get lastRoutePath => substring(lastIndexOf('/') + 1);
  String get withSlashPrefix => startsWith('/') ? this : '/$this';
}
