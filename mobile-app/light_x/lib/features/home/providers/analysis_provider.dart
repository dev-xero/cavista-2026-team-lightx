import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:light_x/core/apis/api_paths.dart';
import 'package:light_x/data/models/health_model.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

// ─── keep these imports if the Analysis widget models live there ───────────────
// import 'package:light_x/features/analysis/ui/analysis_screen.dart';

const _tag = 'VitalsAnalysis';

// ─────────────────────────────────────────────────────────────────────────────
// Request model
// ─────────────────────────────────────────────────────────────────────────────

class VitalsRequest {
  final int age;
  final int gender; // 0 = female, 1 = male
  final int smokingStatus; // 0 = never, 1 = former, 2 = current
  final double bmi;
  final double avgSleepHours;
  final int stressLevel; // 1–10
  final int diabetic; // 0 = no, 1 = yes
  final int systolicBp;
  final int diastolicBp;
  final int heartRate;
  final double spo2;
  final double breathingRate;
  final double hrv;
  final double totalCholesterol;
  final double hdlCholesterol;
  final double fastingGlucose;
  final double creatinine;

  const VitalsRequest({
    required this.age,
    required this.gender,
    required this.smokingStatus,
    required this.bmi,
    required this.avgSleepHours,
    required this.stressLevel,
    required this.diabetic,
    required this.systolicBp,
    required this.diastolicBp,
    required this.heartRate,
    required this.spo2,
    required this.breathingRate,
    required this.hrv,
    required this.totalCholesterol,
    required this.hdlCholesterol,
    required this.fastingGlucose,
    required this.creatinine,
  });

  Map<String, dynamic> toJson() => {
    'age': age,
    'gender': gender,
    'smoking_status': smokingStatus,
    'bmi': bmi,
    'avg_sleep_hours': avgSleepHours,
    'stress_level': stressLevel,
    'diabetic': diabetic,
    'systolic_bp': systolicBp,
    'diastolic_bp': diastolicBp,
    'heart_rate': heartRate,
    'spo2': spo2,
    'breathing_rate': breathingRate,
    'hrv': hrv,
    'total_cholesterol': totalCholesterol,
    'hdl_cholesterol': hdlCholesterol,
    'fasting_glucose': fastingGlucose,
    'creatinine': creatinine,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Parsed result — fed directly into Analysis screen widgets
// ─────────────────────────────────────────────────────────────────────────────

enum RiskLevel { low, moderate, high, critical }

class AnalysisResult {
  /// Raw text from the backend — shown as-is in the gauge description.
  final String rawResponse;

  final RiskLevel riskLevel;
  final int riskScore; // 0–100
  final String riskBadgeText;
  final Color riskArcColor;
  final double riskFraction; // 0.0–1.0

  final String bpDisplay; // e.g. "135/85"
  final String bpStatus;
  final Color bpStatusColor;

  final String hrDisplay; // e.g. "72"
  final String hrStatus;
  final Color hrStatusColor;

  final String spo2Display; // e.g. "98"
  final String spo2Status;
  final Color spo2StatusColor;

  final String lifestyleTip;

  const AnalysisResult({
    required this.rawResponse,
    required this.riskLevel,
    required this.riskScore,
    required this.riskBadgeText,
    required this.riskArcColor,
    required this.riskFraction,
    required this.bpDisplay,
    required this.bpStatus,
    required this.bpStatusColor,
    required this.hrDisplay,
    required this.hrStatus,
    required this.hrStatusColor,
    required this.spo2Display,
    required this.spo2Status,
    required this.spo2StatusColor,
    required this.lifestyleTip,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

enum AnalysisState { idle, loading, success, error }

class AnalysisProvider extends ChangeNotifier {
  AnalysisState get state => _state;
  AnalysisResult? get result => _result;
  String? get errorMessage => _errorMessage;

  AnalysisState _state = AnalysisState.idle;
  AnalysisResult? _result;
  String? _errorMessage;

  // The last request sent — kept so the screen can show a "retry" button.
  HealthModel? _lastRequest;

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> analyse(HealthModel request) async {
    if (_state == AnalysisState.loading) return;

    _lastRequest = request;
    _errorMessage = null;
    _state = AnalysisState.loading;
    notifyListeners();

    log('payload sending...: ${jsonEncode(request.toJson())}', name: _tag);

    try {
      final response = await http
          .post(
            Uri.parse(ApiPaths.analyzeVitals),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      log('HTTP ${response.statusCode}  body=${response.body.length}B', name: _tag);

      if (response.statusCode != 200) {
        _handleHttpError(response);
        return;
      }

      // Backend returns a plain JSON string (per the spec "string").
      String raw = response.body;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is String) raw = decoded;
      } catch (_) {}

      log('   raw response: ${raw.length > 200 ? "${raw.substring(0, 200)}…" : raw}', name: _tag);

      _result = _parse(raw, request);
      _state = AnalysisState.success;
      log('Parsed: risk=${_result!.riskLevel.name} score=${_result!.riskScore}', name: _tag);
    } catch (e, st) {
      log('$e', name: _tag, error: e, stackTrace: st);
      _errorMessage = _friendlyError(e);
      _state = AnalysisState.error;
    }

    notifyListeners();
  }

  Future<void> retry() async {
    if (_lastRequest != null) await analyse(_lastRequest!);
  }

  void reset() {
    _state = AnalysisState.idle;
    _result = null;
    _errorMessage = null;
    _lastRequest = null;
    notifyListeners();
  }

  // ── Response parser ─────────────────────────────────────────────────────────
  //
  // The backend returns a plain English string from the ML model.
  // We extract what we can from keywords and fall back to the raw vitals
  // from the request for the metric cards (we already have the numbers).

  AnalysisResult _parse(String raw, HealthModel req) {
    final lower = raw.toLowerCase();

    // ── Risk level ────────────────────────────────────────────────────────────
    final RiskLevel level;
    final int score;
    final String badge;
    final Color arcColor;

    if (lower.contains('critical') || lower.contains('very high risk') || lower.contains('severe')) {
      level = RiskLevel.critical;
      score = _extractScore(lower) ?? 88;
      badge = 'Critical';
      arcColor = AppColors.red;
    } else if (lower.contains('high risk') || lower.contains('elevated risk') || lower.contains('high')) {
      level = RiskLevel.high;
      score = _extractScore(lower) ?? 74;
      badge = 'High Risk';
      arcColor = AppColors.red;
    } else if (lower.contains('moderate') || lower.contains('borderline') || lower.contains('medium')) {
      level = RiskLevel.moderate;
      score = _extractScore(lower) ?? 52;
      badge = 'Moderate';
      arcColor = AppColors.amber;
    } else {
      level = RiskLevel.low;
      score = _extractScore(lower) ?? 24;
      badge = 'Low Risk';
      arcColor = AppColors.green;
    }

    // ── BP classification ──────────────────────────────────────────────────────
    final sys = req.systolicBp;
    final dia = req.diastolicBp;
    final String bpStatus;
    final Color bpColor;

    if (sys >= 180 || dia >= 120) {
      bpStatus = 'Hypertensive Crisis';
      bpColor = AppColors.red;
    } else if (sys >= 140 || dia >= 90) {
      bpStatus = 'High (Stage 2)';
      bpColor = AppColors.red;
    } else if (sys >= 130 || dia >= 80) {
      bpStatus = 'High (Stage 1)';
      bpColor = AppColors.amber;
    } else if (sys >= 120) {
      bpStatus = 'Elevated';
      bpColor = AppColors.amberText;
    } else {
      bpStatus = 'Normal';
      bpColor = AppColors.green;
    }

    // ── HR classification ──────────────────────────────────────────────────────
    final hr = req.heartRate;
    final String hrStatus;
    final Color hrColor;

    if (hr < 40 || hr > 150) {
      hrStatus = 'Abnormal';
      hrColor = AppColors.red;
    } else if (hr < 50 || hr > 100) {
      hrStatus = 'Out of Range';
      hrColor = AppColors.amber;
    } else {
      hrStatus = 'Normal';
      hrColor = AppColors.green;
    }

    // ── SpO2 classification ────────────────────────────────────────────────────
    final spo2 = req.spo2;
    final String spo2Status;
    final Color spo2Color;

    if (spo2 < 90) {
      spo2Status = 'Critical Low';
      spo2Color = AppColors.red;
    } else if (spo2 < 95) {
      spo2Status = 'Low';
      spo2Color = AppColors.amber;
    } else {
      spo2Status = 'Normal';
      spo2Color = AppColors.green;
    }

    // ── Lifestyle tip ──────────────────────────────────────────────────────────
    // Extract the first actionable sentence from the response, falling back
    // to a generic tip based on the risk level.
    final tip = _extractTip(raw) ?? _defaultTip(level, sys, dia, req.avgSleepHours.toDouble(), req.stressLevel);

    return AnalysisResult(
      rawResponse: raw,
      riskLevel: level,
      riskScore: score.clamp(0, 100),
      riskBadgeText: badge,
      riskArcColor: arcColor,
      riskFraction: (score / 100).clamp(0.0, 1.0),
      bpDisplay: '$sys/$dia',
      bpStatus: bpStatus,
      bpStatusColor: bpColor,
      hrDisplay: '$hr',
      hrStatus: hrStatus,
      hrStatusColor: hrColor,
      spo2Display: spo2.toStringAsFixed(0),
      spo2Status: spo2Status,
      spo2StatusColor: spo2Color,
      lifestyleTip: tip,
    );
  }

  // ── Extract a numeric score from the raw text (e.g. "risk score: 72") ───────
  int? _extractScore(String lower) {
    final patterns = [
      RegExp(r'risk score[:\s]+(\d{1,3})'),
      RegExp(r'score[:\s]+(\d{1,3})\s*(?:out of|/)\s*100'),
      RegExp(r'(\d{1,3})\s*%\s*(?:risk|chance|probability)'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(lower);
      if (m != null) {
        final v = int.tryParse(m.group(1)!);
        if (v != null && v >= 0 && v <= 100) return v;
      }
    }
    return null;
  }

  // ── Pull the first sentence that sounds like a recommendation ────────────────
  String? _extractTip(String raw) {
    final sentences = raw.split(RegExp(r'(?<=[.!?])\s+'));
    const tipKeywords = [
      'reduce',
      'increase',
      'avoid',
      'consider',
      'recommend',
      'suggest',
      'try',
      'limit',
      'maintain',
      'improve',
      'monitor',
      'consult',
    ];
    for (final s in sentences) {
      final l = s.toLowerCase();
      if (tipKeywords.any((kw) => l.contains(kw)) && s.length > 20 && s.length < 220) {
        return s.trim();
      }
    }
    return null;
  }

  String _defaultTip(RiskLevel level, int sys, int dia, double sleep, int stress) {
    if (sys >= 130 || dia >= 80) {
      return 'Reducing your daily sodium intake by 1,000 mg could lower your systolic BP by up to 5 points.';
    }
    if (sleep < 6) return 'Aim for 7–9 hours of sleep per night to support cardiovascular health.';
    if (stress >= 7) return 'High stress elevates cortisol and BP. Consider daily 10-minute mindfulness sessions.';
    if (level == RiskLevel.low) {
      return 'Keep up the great habits — regular activity and a balanced diet protect long-term heart health.';
    }
    return 'Scheduling regular check-ups with your doctor can help track and manage your cardiovascular risk.';
  }

  // ── HTTP / network error handling ────────────────────────────────────────────
  void _handleHttpError(http.Response response) {
    String msg;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'];
      if (detail is List && detail.isNotEmpty) {
        msg = (detail.first as Map)['msg']?.toString() ?? 'Validation error';
      } else {
        msg = detail?.toString() ?? 'Server error ${response.statusCode}';
      }
    } catch (_) {
      msg = 'Server error ${response.statusCode}';
    }
    log('HTTP error: $msg', name: _tag);
    _errorMessage = msg;
    _state = AnalysisState.error;
    notifyListeners();
  }

  static String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('TimeoutException')) return 'Request timed out. Please try again.';
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Cannot reach server. Check your connection.';
    }
    if (s.contains('422')) return 'Invalid data submitted. Please check your inputs.';
    return 'Analysis failed. Please try again.';
  }
}
