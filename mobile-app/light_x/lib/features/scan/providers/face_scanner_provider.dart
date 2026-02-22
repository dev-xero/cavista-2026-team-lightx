import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:light_x/features/scan/logic/face_scan_service.dart';

// ─── Backend models ─────────────────────────────────────────────────────────

class ScanErrorDetail {
  final List<String> loc;
  final String msg;
  final String type;
  final String? input;

  const ScanErrorDetail({required this.loc, required this.msg, required this.type, this.input});

  factory ScanErrorDetail.fromJson(Map<String, dynamic> json) => ScanErrorDetail(
    loc: (json['loc'] as List).map((e) => e.toString()).toList(),
    msg: json['msg'] as String,
    type: json['type'] as String,
    input: json['input'] as String?,
  );

  String get locationLabel => loc.join(' › ');
}

class ScanErrorResponse {
  final List<ScanErrorDetail> details;
  const ScanErrorResponse({required this.details});

  factory ScanErrorResponse.fromJson(Map<String, dynamic> json) => ScanErrorResponse(
    details: (json['detail'] as List).map((e) => ScanErrorDetail.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class ScanSuccessResponse {
  final String analysis;
  final String message;
  final String timestamp;

  const ScanSuccessResponse({required this.analysis, required this.message, required this.timestamp});

  factory ScanSuccessResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ScanSuccessResponse(
      analysis: data['analysis'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}

// ─── State ──────────────────────────────────────────────────────────────────

enum FaceScanState { idle, initializing, scanning, complete, success, backendError, error }

// ─── Provider ───────────────────────────────────────────────────────────────

class FaceScannerProvider with ChangeNotifier {
  FaceScanState _state = FaceScanState.idle;
  FaceScanState get state => _state;

  CameraController? _controller;
  CameraController? get controller => _controller;

  FaceScanService? _service;

  FaceScanResult? _lastResult;
  FaceScanResult? get lastResult => _lastResult;

  double _progress = 0.0;
  double get progress => _progress;

  Uint8List? _snapshot;
  Uint8List? get snapshot => _snapshot;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ScanSuccessResponse? _successResponse;
  ScanSuccessResponse? get successResponse => _successResponse;

  ScanErrorResponse? _backendError;
  ScanErrorResponse? get backendError => _backendError;

  bool _captured = false;
  bool _isProcessingFrame = false; // guard against overlapping frame calls

  // ─── Init ────────────────────────────────

  Future<void> initialize() async {
    if (_state == FaceScanState.initializing || _state == FaceScanState.scanning) return;

    _setState(FaceScanState.initializing);
    _resetScan();

    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.low, // ← lower res = smaller buffer = no 413 / maxImages blowup
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // bgra8888 on iOS
      );

      await _controller!.initialize();

      final previewSize = _controller!.value.previewSize!;
      _service = FaceScanService(previewWidth: previewSize.width, previewHeight: previewSize.height);

      _service!.progressStream.listen((p) {
        _progress = p;
        notifyListeners();

        if (p >= 1.0 && !_captured) {
          _captured = true;
          _capture();
        }
      });

      await _controller!.startImageStream(_onFrame);
      _setState(FaceScanState.scanning);
    } catch (e) {
      _errorMessage = 'Camera error: $e';
      _setState(FaceScanState.error);
    }
  }

  // ─── Per-frame callback ──────────────────
  // Guard with _isProcessingFrame so we never queue up concurrent ML Kit calls,
  // which is what causes the "Unable to acquire buffer item / maxImages" crash.

  Future<void> _onFrame(CameraImage frame) async {
    if (_captured || _service == null || _isProcessingFrame) return;
    _isProcessingFrame = true;
    try {
      final result = await _service!.analyzeFrame(frame);
      _lastResult = result;
      notifyListeners();
    } finally {
      _isProcessingFrame = false;
    }
  }

  // ─── Capture ────────────────────────────

  Future<void> _capture() async {
    if (_controller == null || _service == null) return;
    try {
      await _controller!.stopImageStream();
      final raw = await _service!.takeSnapshot(_controller!);

      // Compress to JPEG at 60% quality, max 800px wide — keeps payload small
      if (raw != null) {
        _snapshot = await FlutterImageCompress.compressWithList(
          raw,
          minWidth: 800,
          minHeight: 800,
          quality: 60,
          format: CompressFormat.jpeg,
        );
      }

      _setState(FaceScanState.complete);
    } catch (e) {
      _errorMessage = 'Capture failed: $e';
      _setState(FaceScanState.error);
    }
  }

  // ─── Backend result setters ──────────────
  // Call these after you get the API response.

  void setSuccess(Map<String, dynamic> json) {
    _successResponse = ScanSuccessResponse.fromJson(json);
    _backendError = null;
    _setState(FaceScanState.success);
  }

  void setBackendError(Map<String, dynamic> json) {
    _backendError = ScanErrorResponse.fromJson(json);
    _successResponse = null;
    _setState(FaceScanState.backendError);
  }

  // ─── Retry ──────────────────────────────

  Future<void> retry() async {
    await _disposeInternals();
    await initialize();
  }

  // ─── Helpers ────────────────────────────

  void _setState(FaceScanState s) {
    _state = s;
    notifyListeners();
  }

  void _resetScan() {
    _lastResult = null;
    _progress = 0.0;
    _snapshot = null;
    _errorMessage = null;
    _backendError = null;
    _successResponse = null;
    _captured = false;
    _isProcessingFrame = false;
  }

  Future<void> _disposeInternals() async {
    await _controller?.stopImageStream().catchError((_) {});
    await _controller?.dispose();
    _service?.dispose();
    _controller = null;
    _service = null;
  }

  @override
  Future<void> dispose() async {
    await _disposeInternals();
    super.dispose();
  }
}
