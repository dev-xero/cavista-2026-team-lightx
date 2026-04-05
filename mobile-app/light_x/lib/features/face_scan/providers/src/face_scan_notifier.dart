import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:light_x/core/apis/api.dart';
import 'package:light_x/features/face_scan/logic/services/face_scan_service.dart';
import 'package:light_x/features/face_scan/providers/entities/face_scan_submission.dart';
import 'package:light_x/features/face_scan/providers/entities/face_scan_state.dart';

class FaceScanNotifier extends Notifier<FaceScanState> {
  CameraController? _controller;
  FaceScanService? _service;
  StreamSubscription<double>? _progressSub;
  bool _captureTriggered = false;
  bool _isAnalyzingFrame = false;
  bool _isDisposed = false;
  int _operationId = 0;

  CameraController? get controller => _controller;

  @override
  FaceScanState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _disposeInternals();
    });
    return FaceScanState.d();
  }

  Future<void> initialize() async {
    if (state.phase == FaceScanPhase.initializing || state.phase == FaceScanPhase.scanning) return;
    final opId = ++_operationId;
    _captureTriggered = false;
    _isAnalyzingFrame = false;

    state = state.copyWith(
      phase: FaceScanPhase.initializing,
      progress: 0.0,
      clearLastResult: true,
      clearSnapshot: true,
      clearSubmission: true,
    );

    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();
      if (_isStale(opId)) {
        await controller.dispose();
        return;
      }
      _controller = controller;

      final previewSize = controller.value.previewSize!;
      _service = FaceScanService(previewSize: previewSize);

      await _progressSub?.cancel();
      _progressSub = _service!.progressStream.listen((p) {
        if (_isStale(opId)) return;
        final next = p.clamp(0.0, 1.0);
        final previous = state.progress;
        if ((next - previous).abs() >= 0.01 || next == 0.0 || next == 1.0) {
          state = state.copyWith(progress: next);
        }

        if (next >= 1.0 && !_captureTriggered) {
          _captureTriggered = true;
          unawaited(_capture(opId));
        }
      });

      await controller.startImageStream((frame) => _onFrame(frame, opId));
      if (_isStale(opId)) return;
      state = state.copyWith(phase: FaceScanPhase.scanning);
    } catch (e) {
      if (_isStale(opId)) return;
      state = state.copyWith(
        phase: FaceScanPhase.error,
        submission: FaceScanSubmission(message: 'Camera error', errors: ['Camera error: $e']),
      );
    }
  }

  Future<void> _onFrame(CameraImage frame, int opId) async {
    if (_captureTriggered || _service == null || _isAnalyzingFrame || _isStale(opId)) return;
    _isAnalyzingFrame = true;
    try {
      final result = await _service!.analyzeFrame(frame);
      if (_isStale(opId)) return;
      state = state.copyWith(lastResult: result);
    } finally {
      _isAnalyzingFrame = false;
    }
  }

  Future<void> _capture(int opId) async {
    final controller = _controller;
    if (_service == null || controller == null || _isStale(opId)) return;
    try {
      await controller.stopImageStream();
      final raw = await _service!.takeSnapshot(controller);

      Uint8List? compressed;
      if (raw != null) {
        compressed = await FlutterImageCompress.compressWithList(
          raw,
          minWidth: 800,
          minHeight: 800,
          quality: 60,
          format: CompressFormat.jpeg,
        );
      }

      if (_isStale(opId)) return;
      state = state.copyWith(progress: 1.0, snapshot: compressed, phase: FaceScanPhase.complete);
    } catch (e) {
      if (_isStale(opId)) return;
      state = state.copyWith(
        phase: FaceScanPhase.error,
        submission: FaceScanSubmission(message: 'Capture failed', errors: ['Capture failed: $e']),
      );
    }
  }

  void setSubmitting() {
    state = state.copyWith(phase: FaceScanPhase.submitting, clearSubmission: true);
  }

  void setSuccess(Map<String, dynamic> json) {
    final success = FaceScanSubmission.fromSuccessJson(json);
    state = state.copyWith(submission: success, phase: FaceScanPhase.success);
  }

  void setSuccessFromPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final hasEnvelope =
          payload.containsKey('data') || payload.containsKey('message') || payload.containsKey('timestamp');
      if (hasEnvelope) {
        setSuccess(payload);
        return;
      }

      state = state.copyWith(
        submission: FaceScanSubmission(
          analysis: payload['analysis']?.toString(),
          message: payload['message']?.toString() ?? 'Scan Complete',
          timestamp: payload['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
        ),
        phase: FaceScanPhase.success,
      );
      return;
    }

    try {
      final dynamic raw = payload;
      final dynamic mapRaw = raw.toJson();
      if (mapRaw is Map) {
        final mapped = <String, dynamic>{};
        for (final entry in mapRaw.entries) {
          mapped[entry.key.toString()] = entry.value;
        }

        final lines = mapped.entries.map((e) => '${_titleCase(e.key)}: ${e.value}').join('\n');
        state = state.copyWith(
          submission: FaceScanSubmission(
            analysis: lines,
            message: 'Scan Complete',
            timestamp: DateTime.now().toIso8601String(),
          ),
          phase: FaceScanPhase.success,
        );
        return;
      }
    } catch (_) {
      // Fallback below
    }

    state = state.copyWith(
      submission: FaceScanSubmission(
        analysis: payload?.toString() ?? '',
        message: 'Scan Complete',
        timestamp: DateTime.now().toIso8601String(),
      ),
      phase: FaceScanPhase.success,
    );
  }

  void setBackendError(Map<String, dynamic> json) {
    final backendError = FaceScanSubmission.fromErrorJson(json);
    state = state.copyWith(submission: backendError, phase: FaceScanPhase.error);
  }

  Future<bool> submitCurrentSnapshot() async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      state = state.copyWith(
        phase: FaceScanPhase.error,
        submission: const FaceScanSubmission(message: 'Missing snapshot', errors: ['No snapshot available to submit.']),
      );
      return false;
    }

    setSubmitting();
    final result = await Api.instance.analysis.analyzeFacial(snapshot);
    if (result.data == null) {
      setBackendError({
        'message': result.errorMsg ?? 'No face detected in the image.',
        'details': ['Ensure your face is fully visible and well-lit, then try again.'],
      });
      return false;
    }

    setSuccessFromPayload(result.data);
    return true;
  }

  Future<void> retry() async {
    ++_operationId;
    await _disposeInternals();
    _captureTriggered = false;
    _isAnalyzingFrame = false;
    state = FaceScanState.d();
    await initialize();
  }

  Future<void> _disposeInternals() async {
    await _progressSub?.cancel();
    _progressSub = null;

    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.stopImageStream().catchError((_) {});
      await controller.dispose().catchError((_) {});
    }

    _service?.dispose();
    _service = null;
  }

  bool _isStale(int opId) => _isDisposed || opId != _operationId;

  String _titleCase(String key) {
    final cleaned = key.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return key;
    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
