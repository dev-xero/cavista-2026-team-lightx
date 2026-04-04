import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/home/providers/entities/main_state.dart';

class MainNotifier extends Notifier<MainState> {
  @override
  MainState build() => MainState.d();

  void setCurrentIndex(int index) => state = state.copyWith(currentIndex: index);
}
