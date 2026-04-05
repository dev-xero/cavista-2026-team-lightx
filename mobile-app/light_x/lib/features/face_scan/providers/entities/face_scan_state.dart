import 'dart:typed_data';

import 'package:light_x/features/face_scan/providers/entities/face_scan_result.dart';
import 'package:light_x/features/face_scan/providers/entities/face_scan_submission.dart';

class FaceScanState {
  final FaceScanPhase phase;
  final double progress;
  final FaceScanResult? lastResult;
  final Uint8List? snapshot;
  final FaceScanSubmission? submission;

  const FaceScanState({required this.phase, this.progress = 0.0, this.lastResult, this.snapshot, this.submission});

  factory FaceScanState.d() => const FaceScanState(phase: FaceScanPhase.idle, progress: 0.0);

  FaceScanState copyWith({
    FaceScanPhase? phase,
    double? progress,
    FaceScanResult? lastResult,
    Uint8List? snapshot,
    FaceScanSubmission? submission,
    bool clearLastResult = false,
    bool clearSnapshot = false,
    bool clearSubmission = false,
  }) {
    return FaceScanState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      submission: clearSubmission ? null : (submission ?? this.submission),
    );
  }
}

enum FaceScanPhase { idle, initializing, scanning, complete, submitting, success, error }
