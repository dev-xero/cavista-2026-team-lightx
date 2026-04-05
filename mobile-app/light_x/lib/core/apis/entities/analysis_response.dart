enum RiskLevel { low, moderate, high, critical }

enum SeverityLevel { normal, caution, warning, critical }

class AnalysisResponse {
  /// Raw text from the backend — shown as-is in the gauge description.
  final String rawResponse;

  final RiskLevel riskLevel;
  final SeverityLevel riskSeverity;
  final int riskScore; // 0–100
  final String riskBadgeText;
  final double riskFraction; // 0.0–1.0

  final String bpDisplay; // e.g. "135/85"
  final String bpStatus;
  final SeverityLevel bpSeverity;

  final String hrDisplay; // e.g. "72"
  final String hrStatus;
  final SeverityLevel hrSeverity;

  final String spo2Display; // e.g. "98"
  final String spo2Status;
  final SeverityLevel spo2Severity;

  final String lifestyleTip;

  const AnalysisResponse({
    required this.rawResponse,
    required this.riskLevel,
    required this.riskSeverity,
    required this.riskScore,
    required this.riskBadgeText,
    required this.riskFraction,
    required this.bpDisplay,
    required this.bpStatus,
    required this.bpSeverity,
    required this.hrDisplay,
    required this.hrStatus,
    required this.hrSeverity,
    required this.spo2Display,
    required this.spo2Status,
    required this.spo2Severity,
    required this.lifestyleTip,
  });
}
