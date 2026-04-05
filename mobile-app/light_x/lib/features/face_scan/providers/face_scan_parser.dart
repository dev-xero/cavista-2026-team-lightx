import 'package:light_x/features/face_scan/providers/entities/face_scan_result.dart';
import 'package:light_x/features/face_scan/providers/entities/face_scan_state.dart';

class FaceScanParser {
  final FaceScanState _state;
  FaceScanParser(this._state);
  String lightingValue() {
    final result = _state.lastResult;
    if (result == null) return 'Checking...';
    switch (result.lighting) {
      case LightingStatus.optimal:
        return 'Optimal';
      case LightingStatus.tooDark:
        return 'Too Dark';
      case LightingStatus.tooBright:
        return 'Too Bright';
      case LightingStatus.unknown:
        return 'Unknown';
    }
  }

  String distanceValue() {
    final result = _state.lastResult;
    if (result == null) return 'Checking...';
    switch (result.distance) {
      case DistanceStatus.perfect:
        return 'Perfect';
      case DistanceStatus.okay:
        return 'Okay';
      case DistanceStatus.tooFar:
        return 'Too Far';
      case DistanceStatus.tooClose:
        return 'Too Close';
      case DistanceStatus.unknown:
        return 'Unknown';
    }
  }

  String progressCaption() {
    final state = _state;
    if (state.phase == FaceScanPhase.initializing) return 'Starting camera...';
    if (state.phase == FaceScanPhase.error) return state.submission?.primaryErrorMessage ?? 'An error occurred';
    if (state.phase == FaceScanPhase.complete) return 'Scan complete!';
    if (state.phase == FaceScanPhase.submitting) return 'Submitting scan...';

    final result = state.lastResult;
    if (result == null) return 'Align your face in the frame';
    if (!result.isAcceptable) {
      if (result.lighting != LightingStatus.optimal) return result.lightingMessage;
      return result.distanceMessage;
    }
    return 'Hold still, almost done...';
  }

  String stepLabel() {
    switch (_state.phase) {
      case FaceScanPhase.idle:
      case FaceScanPhase.initializing:
        return 'Initialising';
      case FaceScanPhase.scanning:
        return 'Scanning Vitals';
      case FaceScanPhase.complete:
        return 'Scan Complete';
      case FaceScanPhase.submitting:
        return 'Submitting';
      case FaceScanPhase.error:
        return 'Error';
      case FaceScanPhase.success:
        return 'Success';
    }
  }
}
