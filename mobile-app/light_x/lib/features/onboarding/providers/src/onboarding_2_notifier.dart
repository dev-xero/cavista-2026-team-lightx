import 'package:flutter_riverpod/flutter_riverpod.dart';

class Onboarding2State {
  final int age;
  final double height;
  final double weight;
  final bool isSmoking;
  final bool? isMale;

  const Onboarding2State({
    required this.age,
    required this.height,
    required this.weight,
    required this.isSmoking,
    this.isMale,
  });

  /// default state for onboarding 2
  factory Onboarding2State.d() {
    return const Onboarding2State(age: 1, height: 1, weight: 1, isSmoking: false);
  }

  Onboarding2State copyWith({int? age, double? height, double? weight, bool? isSmoking, bool? isMale}) =>
      Onboarding2State(
        age: age ?? this.age,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        isSmoking: isSmoking ?? this.isSmoking,
        isMale: isMale ?? this.isMale,
      );
}

class Onboarding2Notifier extends Notifier<Onboarding2State> {
  @override
  Onboarding2State build() => Onboarding2State.d();

  void setAge(int age) => state = state.copyWith(age: age);
  void setHeight(double height) => state = state.copyWith(height: height);
  void setWeight(double weight) => state = state.copyWith(weight: weight);
  void setIsSmoking(bool isSmoking) => state = state.copyWith(isSmoking: isSmoking);
  void setIsMale(bool isMale) => state = state.copyWith(isMale: isMale);
}
