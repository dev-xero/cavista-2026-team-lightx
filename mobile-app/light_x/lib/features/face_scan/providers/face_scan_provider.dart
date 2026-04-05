import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/face_scan/providers/face_scan_parser.dart';
import 'package:light_x/features/face_scan/providers/entities/face_scan_state.dart';
import 'package:light_x/features/face_scan/providers/src/face_scan_notifier.dart';
import 'package:light_x/features/face_scan/ui/entities/face_scan_display_data.dart';

final _faceScanNotifier = NotifierProvider.autoDispose<FaceScanNotifier, FaceScanState>(() => FaceScanNotifier());

final _faceScanDisplayProvider = Provider.autoDispose<FaceScanDisplayData>((ref) {
  final state = ref.watch(_faceScanNotifier);

  final percent = (state.progress * 100).toStringAsFixed(0);
  final primaryLabel = state.phase == FaceScanPhase.error ? 'Retry' : 'Continue';
  final fp = FaceScanParser(state);

  return FaceScanDisplayData(
    lighting: fp.lightingValue(),
    distance: fp.distanceValue(),
    progress: state.progress,
    percentLabel: '$percent%',
    caption: fp.progressCaption(),
    stepLabel: fp.stepLabel(),
    primaryLabel: primaryLabel,
  );
});

final _faceScanProvider = Provider.autoDispose((ref) => FaceScanProvider(ref));

class FaceScanProvider {
  final Ref _ref;
  FaceScanProvider(this._ref);
  static final asPro = _faceScanProvider;

  final state = _faceScanNotifier;
  final display = _faceScanDisplayProvider;
}
