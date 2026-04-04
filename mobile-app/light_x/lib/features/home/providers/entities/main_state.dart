class MainState {
  final int currentIndex;
  const MainState({required this.currentIndex});

  factory MainState.d() => const MainState(currentIndex: 0);

  MainState copyWith({int? currentIndex}) => MainState(currentIndex: currentIndex ?? this.currentIndex);
}
