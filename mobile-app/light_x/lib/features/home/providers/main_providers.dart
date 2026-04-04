import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/home/providers/entities/analysis_state.dart';
import 'package:light_x/features/home/providers/entities/devices_state.dart';
import 'package:light_x/features/home/providers/entities/main_state.dart';
import 'package:light_x/features/home/providers/src/analysis_notifier.dart';
import 'package:light_x/features/home/providers/src/devices_notifier.dart';
import 'package:light_x/features/home/providers/src/main_notifier.dart';

final _mainProvider = Provider((ref) => MainProviders(ref));
final _mainNotifier = NotifierProvider<MainNotifier, MainState>(() => MainNotifier());
final _analysisNotifier = NotifierProvider<AnalysisNotifier, AnalysisState>(() => AnalysisNotifier());
final _devicesNotifier = NotifierProvider<DevicesNotifier, DevicesState>(() => DevicesNotifier());

class MainProviders {
  final Ref _ref;
  MainProviders(this._ref);

  static final asPro = _mainProvider;
  final state = _mainNotifier;

  final analysis = _analysisNotifier;
  final devices = _devicesNotifier;
}
