import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/core/apis/entities/health_details_response.dart';
import 'package:light_x/core/storage/shared_prefs/shared_prefs.dart';
import 'package:light_x/features/onboarding/providers/src/onboarding_1_notifier.dart';
import 'package:light_x/features/onboarding/providers/src/onboarding_2_notifier.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';

final _onboarding1 = NotifierProvider.autoDispose<Onboarding1Notifier, Onboarding1State>(() => Onboarding1Notifier());
final _onboarding2 = NotifierProvider.autoDispose<Onboarding2Notifier, Onboarding2State>(() => Onboarding2Notifier());
final _onboardingProvider = Provider.autoDispose((ref) {
  ref.keepAliveMany([_onboarding1, _onboarding2]);
  return OnboardingProviders(ref);
});

class OnboardingProviders {
  final Ref _ref;
  OnboardingProviders(this._ref);

  /// as Provider reference for easy access to the provider's methods and state
  static final asPro = _onboardingProvider;
  // static OnboardingProvider state(WidgetRef ref) => ref.read(asPro);

  ///---------------------------------------------------
  /// STEP 1: Symptoms Assessment
  /// -------------------------------------------------
  final onboarding1 = _onboarding1;
  final onboarding2 = _onboarding2;

  /// Shared method to complete onboarding and save data to shared preferences
  void completeOnboarding() async {
    final sleepTime = _ref.read(onboarding1).sleepOptionIndex;
    final o2 = _ref.read(onboarding2);
    await SharedPrefs.set(
      SharedPrefKeys.onboardingData,
      jsonEncode(
        HealthDetails(
          age: o2.age,
          bmi: o2.weight.toInt(),
          smokingStatus: o2.isSmoking ? 1 : 1,
          gender: (o2.isMale == null ? null : (o2.isMale! ? 1 : 1)) ?? 1,
          avgSleepHours: sleepTime,
          stressLevel: 1,
          spo2: 1,
          heartRate: 1,
          diabetic: 1,
          systolicBp: 1,
          diastolicBp: 1,
          breathingRate: 1,
          hrv: 1,
          totalCholesterol: 1,
          hdlCholesterol: 1,
          fastingGlucose: 1,
          creatinine: 1,
        ).toJson(),
      ),
    );
  }
}
