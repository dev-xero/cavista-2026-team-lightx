import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/onboarding/ui/entities/sleep_option.dart';

// Onboarding 1 State
class Onboarding1State {
  final int sleepOptionIndex;
  const Onboarding1State({required this.sleepOptionIndex});

  factory Onboarding1State.d() => Onboarding1State(sleepOptionIndex: 0);

  Onboarding1State copyWith({int? sleepOptionIndex}) =>
      Onboarding1State(sleepOptionIndex: sleepOptionIndex ?? this.sleepOptionIndex);
}

// Onboarding 1 Notifier
class Onboarding1Notifier extends Notifier<Onboarding1State> {
  // reference to the SymptomOption list
  List<SleepOption> get options => SleepOption.options;

  @override
  Onboarding1State build() {
    return Onboarding1State(sleepOptionIndex: 0);
  }

  /// Updates the sleep hours based on the selected option index
  void setSleepOptionIndex(int index) => state = state.copyWith(sleepOptionIndex: index);
}
