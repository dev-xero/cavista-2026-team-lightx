part of '../shared_prefs.dart';

enum SharedPrefKeys {
  // AUTH
  // ============================================================================

  /// Type: bool
  isUserSignedIn,

  /// Type: json
  onboardingData,
}

extension SharedPrefKeysExtension on SharedPrefKeys {
  Object? get load => SharedPrefs.prefs.get(name);
  T? get<T>() => SharedPrefs.prefs.get(name) as T?;
}
