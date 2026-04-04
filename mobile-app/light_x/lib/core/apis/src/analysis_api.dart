part of '../api.dart';

class _AnalysisApi {
  Future<ApiResponse<AnalysisResult>> analyzeVitals(HealthModel request) async {
    try {
      AppLogger.d('Sending analysis request: ${jsonEncode(request.toJson())}');
      final response = await Api.dio.post(
        ApiPaths.analyzeVitals,
        data: request.toJson(), // Dio encodes this automatically
        options: Options(connectTimeout: 30.inSeconds),
      );

      AppLogger.d("Received response: ${response.statusCode} - ${response.data}");

      if (response.statusCode == 200) {
        // Extract the raw response
        dynamic raw = response.data;

        // Handle the "double-encoded string" quirk if the backend sends
        // a JSON string inside a JSON response.
        if (raw is String) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is String) raw = decoded;
          } catch (_) {}
        }

        return ApiResponse.success(_parse(raw.toString(), request));
      }

      return ApiResponse.failure(_extractServerMessage(response));
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  AnalysisResult _parse(String raw, HealthModel req) {
    final lower = raw.toLowerCase();

    final RiskLevel level;
    final SeverityLevel riskSeverity;
    final int score;
    final String badge;

    if (lower.contains('critical') || lower.contains('very high risk') || lower.contains('severe')) {
      level = RiskLevel.critical;
      riskSeverity = SeverityLevel.critical;
      score = _extractScore(lower) ?? 88;
      badge = 'Critical';
    } else if (lower.contains('high risk') || lower.contains('elevated risk') || lower.contains('high')) {
      level = RiskLevel.high;
      riskSeverity = SeverityLevel.warning;
      score = _extractScore(lower) ?? 74;
      badge = 'High Risk';
    } else if (lower.contains('moderate') || lower.contains('borderline') || lower.contains('medium')) {
      level = RiskLevel.moderate;
      riskSeverity = SeverityLevel.caution;
      score = _extractScore(lower) ?? 52;
      badge = 'Moderate';
    } else {
      level = RiskLevel.low;
      riskSeverity = SeverityLevel.normal;
      score = _extractScore(lower) ?? 24;
      badge = 'Low Risk';
    }

    final sys = req.systolicBp;
    final dia = req.diastolicBp;
    final String bpStatus;
    final SeverityLevel bpSeverity;

    if (sys >= 180 || dia >= 120) {
      bpStatus = 'Hypertensive Crisis';
      bpSeverity = SeverityLevel.critical;
    } else if (sys >= 140 || dia >= 90) {
      bpStatus = 'High (Stage 2)';
      bpSeverity = SeverityLevel.warning;
    } else if (sys >= 130 || dia >= 80) {
      bpStatus = 'High (Stage 1)';
      bpSeverity = SeverityLevel.caution;
    } else if (sys >= 120) {
      bpStatus = 'Elevated';
      bpSeverity = SeverityLevel.caution;
    } else {
      bpStatus = 'Normal';
      bpSeverity = SeverityLevel.normal;
    }

    final hr = req.heartRate;
    final String hrStatus;
    final SeverityLevel hrSeverity;

    if (hr < 40 || hr > 150) {
      hrStatus = 'Abnormal';
      hrSeverity = SeverityLevel.critical;
    } else if (hr < 50 || hr > 100) {
      hrStatus = 'Out of Range';
      hrSeverity = SeverityLevel.caution;
    } else {
      hrStatus = 'Normal';
      hrSeverity = SeverityLevel.normal;
    }

    final spo2 = req.spo2;
    final String spo2Status;
    final SeverityLevel spo2Severity;

    if (spo2 < 90) {
      spo2Status = 'Critical Low';
      spo2Severity = SeverityLevel.critical;
    } else if (spo2 < 95) {
      spo2Status = 'Low';
      spo2Severity = SeverityLevel.caution;
    } else {
      spo2Status = 'Normal';
      spo2Severity = SeverityLevel.normal;
    }

    final tip = _extractTip(raw) ?? _defaultTip(level, sys, dia, req.avgSleepHours.toDouble(), req.stressLevel);

    return AnalysisResult(
      rawResponse: raw,
      riskLevel: level,
      riskSeverity: riskSeverity,
      riskScore: score.clamp(0, 100),
      riskBadgeText: badge,
      riskFraction: (score / 100).clamp(0.0, 1.0),
      bpDisplay: '$sys/$dia',
      bpStatus: bpStatus,
      bpSeverity: bpSeverity,
      hrDisplay: '$hr',
      hrStatus: hrStatus,
      hrSeverity: hrSeverity,
      spo2Display: spo2.toStringAsFixed(0),
      spo2Status: spo2Status,
      spo2Severity: spo2Severity,
      lifestyleTip: tip,
    );
  }

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

  String _extractServerMessage(Response response) {
    final status = response.statusCode;
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty && detail.first is Map) {
        final first = detail.first as Map;
        final msg = first['msg']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      if (detail != null) return detail.toString();
    }

    return 'Server error: $status';
  }
}
