import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// ─────────────────────────────────────────────
// Enums / result types
// ─────────────────────────────────────────────

enum LightingStatus { tooDark, optimal, tooBright, unknown }

enum DistanceStatus { tooFar, okay, perfect, tooClose, unknown }

class FaceScanResult {
  final LightingStatus lighting;
  final DistanceStatus distance;
  final String lightingMessage;
  final String distanceMessage;
  final bool isAcceptable;

  const FaceScanResult({
    required this.lighting,
    required this.distance,
    required this.lightingMessage,
    required this.distanceMessage,
    required this.isAcceptable,
  });
}

// ─────────────────────────────────────────────
// FaceScanService
// ─────────────────────────────────────────────

class FaceScanService {
  FaceScanService({required this.previewWidth, required this.previewHeight});

  final double previewWidth;
  final double previewHeight;

  // Progress tracking ─────────────────────────
  final StreamController<double> _progressController = StreamController<double>.broadcast();

  Stream<double> get progressStream => _progressController.stream;

  static const Duration holdDuration = Duration(seconds: 2);
  static const int _progressTicks = 20;

  Timer? _progressTimer;
  int _progressStep = 0;
  bool _isHolding = false;

  // ML Kit detector ───────────────────────────
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: false,
      enableLandmarks: false,
      enableContours: false,
      enableTracking: false,
    ),
  );

  // FIX: track whether a frame is already being processed so we don't
  // queue up dozens of concurrent ML Kit calls (causes the ImageReader
  // "unable to acquire buffer" spam and keeps running after dispose).
  bool _processingFrame = false;
  bool _disposed = false;

  // ─── Public API ────────────────────────────

  Future<FaceScanResult> analyzeFrame(CameraImage cameraImage) async {
    if (_disposed) throw StateError('FaceScanService has been disposed.');

    // FIX: drop frames that arrive while the previous one is still processing.
    if (_processingFrame) {
      return const FaceScanResult(
        lighting: LightingStatus.unknown,
        distance: DistanceStatus.unknown,
        lightingMessage: 'Checking…',
        distanceMessage: 'Checking…',
        isAcceptable: false,
      );
    }

    _processingFrame = true;
    try {
      final inputImage = _toInputImage(cameraImage);
      final faces = await _detector.processImage(inputImage);

      // Guard again after the async gap — may have been disposed while awaiting.
      if (_disposed) throw StateError('FaceScanService has been disposed.');

      if (faces.isEmpty) {
        _stopProgress();
        return const FaceScanResult(
          lighting: LightingStatus.unknown,
          distance: DistanceStatus.unknown,
          lightingMessage: 'No face detected — please look at the camera',
          distanceMessage: '',
          isAcceptable: false,
        );
      }

      final face = faces.first;
      final lighting = _analyzeLighting(cameraImage);
      final distance = _analyzeDistance(face.boundingBox);
      final isAcceptable = _lightingAcceptable(lighting) && _distanceAcceptable(distance);

      final result = FaceScanResult(
        lighting: lighting,
        distance: distance,
        lightingMessage: _lightingMessage(lighting),
        distanceMessage: _distanceMessage(distance),
        isAcceptable: isAcceptable,
      );

      if (isAcceptable) {
        _startProgress();
      } else {
        _stopProgress();
      }

      return result;
    } finally {
      _processingFrame = false;
    }
  }

  Future<Uint8List?> takeSnapshot(CameraController controller) async {
    try {
      final XFile file = await controller.takePicture();
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    if (_disposed) return; // FIX: guard against double-dispose
    _disposed = true;
    _progressTimer?.cancel();
    _progressTimer = null;
    // Close stream only if it hasn't been closed already.
    if (!_progressController.isClosed) {
      _progressController.close();
    }
    _detector.close();
  }

  // ─── Lighting ──────────────────────────────

  LightingStatus _analyzeLighting(CameraImage image) {
    final yPlane = image.planes.first;
    final bytes = yPlane.bytes;
    if (bytes.isEmpty) return LightingStatus.unknown;

    int sum = 0;
    int count = 0;
    for (int i = 0; i < bytes.length; i += 8) {
      sum += bytes[i];
      count++;
    }

    final avg = sum / count;
    if (avg < 60) return LightingStatus.tooDark;
    if (avg > 210) return LightingStatus.tooBright;
    return LightingStatus.optimal;
  }

  bool _lightingAcceptable(LightingStatus s) => s == LightingStatus.optimal;

  String _lightingMessage(LightingStatus s) {
    switch (s) {
      case LightingStatus.tooDark:
        return 'Too dark — move to a brighter area';
      case LightingStatus.tooBright:
        return 'Too bright — avoid direct light or glare';
      case LightingStatus.optimal:
        return 'Lighting is good ✓';
      case LightingStatus.unknown:
        return 'Checking lighting…';
    }
  }

  // ─── Distance ──────────────────────────────

  DistanceStatus _analyzeDistance(Rect boundingBox) {
    // Use the longer preview dimension as the reference so portrait/landscape
    // orientation differences don't skew the ratio.
    final refDimension = previewWidth > previewHeight ? previewWidth : previewHeight;
    final ratio = boundingBox.width / refDimension;

    if (ratio < 0.20) return DistanceStatus.tooFar;
    if (ratio < 0.35) return DistanceStatus.okay;
    if (ratio <= 0.65) return DistanceStatus.perfect;
    return DistanceStatus.tooClose;
  }

  bool _distanceAcceptable(DistanceStatus s) => s == DistanceStatus.okay || s == DistanceStatus.perfect;

  String _distanceMessage(DistanceStatus s) {
    switch (s) {
      case DistanceStatus.tooFar:
        return 'Move closer to the camera';
      case DistanceStatus.okay:
        return 'A little closer would be better';
      case DistanceStatus.perfect:
        return 'Distance is perfect ✓';
      case DistanceStatus.tooClose:
        return 'Move further away from the camera';
      case DistanceStatus.unknown:
        return 'Checking distance…';
    }
  }

  // ─── Progress simulation ───────────────────

  void _startProgress() {
    if (_isHolding || _disposed) return;
    _isHolding = true;
    _progressStep = 0;

    final totalTicks = holdDuration.inMilliseconds ~/ (1000 ~/ _progressTicks);
    final tickInterval = Duration(milliseconds: 1000 ~/ _progressTicks);

    _progressTimer = Timer.periodic(tickInterval, (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      _progressStep++;
      final progress = (_progressStep / totalTicks).clamp(0.0, 1.0);
      if (!_progressController.isClosed) {
        _progressController.add(progress);
      }
      if (_progressStep >= totalTicks) {
        timer.cancel();
        _isHolding = false;
      }
    });
  }

  void _stopProgress() {
    if (!_isHolding) return;
    _progressTimer?.cancel();
    _progressTimer = null;
    _isHolding = false;
    _progressStep = 0;
    if (!_progressController.isClosed) {
      _progressController.add(0.0);
    }
  }

  // ─── InputImage conversion ─────────────────

  InputImage _toInputImage(CameraImage image) {
    // FIX: fromRawValue can return null on some Android devices that report
    // yuv_420_888 — fall back to nv21 which has the same Y-plane layout.
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    // FIX: front camera on Android is physically rotated 270° relative to
    // portrait. Using rotation0deg means ML Kit sees a sideways face and
    // returns no detections, making lighting & distance stay "unknown".
    const rotation = InputImageRotation.rotation270deg;

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final buffer = WriteBuffer();
    for (final plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }
}
