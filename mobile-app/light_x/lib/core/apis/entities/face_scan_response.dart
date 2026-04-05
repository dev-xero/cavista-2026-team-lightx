class FaceScanResponse {
  final String analysis;
  final String message;
  final String timestamp;

  const FaceScanResponse({required this.analysis, required this.message, required this.timestamp});

  factory FaceScanResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FaceScanResponse(
      analysis: data['analysis'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}
