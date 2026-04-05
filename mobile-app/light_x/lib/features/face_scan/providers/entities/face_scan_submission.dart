class FaceScanSubmission {
  final String? analysis;
  final String? message;
  final String? timestamp;
  final List<String> errors;
  final String? technicalDetails;

  const FaceScanSubmission({
    this.analysis,
    this.message,
    this.timestamp,
    this.errors = const <String>[],
    this.technicalDetails,
  });

  bool get isSuccess => analysis != null;
  bool get hasValidationErrors => errors.isNotEmpty;
  String get primaryErrorMessage =>
      errors.isNotEmpty ? errors.first : (message?.trim().isNotEmpty == true ? message! : 'Processing error');

  factory FaceScanSubmission.fromSuccessJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return FaceScanSubmission(
      analysis: data['analysis']?.toString(),
      message: json['message']?.toString(),
      timestamp: json['timestamp']?.toString(),
    );
  }

  factory FaceScanSubmission.fromErrorJson(Map<String, dynamic> json) {
    final dynamic detailRaw = json['detail'] ?? json['details'];

    if (detailRaw is List) {
      if (detailRaw.isEmpty) {
        return FaceScanSubmission(message: json['message']?.toString());
      }

      final errors = <String>[];
      final technicalChunks = <String>[];

      for (final item in detailRaw) {
        if (item is Map<String, dynamic>) {
          final msg = item['msg']?.toString() ?? 'Unknown error';
          errors.add(msg);

          final loc = (item['loc'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
          final type = item['type']?.toString() ?? 'validation_error';
          final input = item['input']?.toString();

          final buffer = StringBuffer();
          if (loc.isNotEmpty) buffer.write('loc=${loc.join(' > ')}');
          if (type.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.write('; ');
            buffer.write('type=$type');
          }
          if (input != null && input.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.write('; ');
            buffer.write('input=$input');
          }

          if (buffer.isNotEmpty) technicalChunks.add(buffer.toString());
          continue;
        }

        errors.add(item.toString());
      }

      return FaceScanSubmission(
        message: json['message']?.toString(),
        errors: errors,
        technicalDetails: technicalChunks.isEmpty ? null : technicalChunks.join('\n'),
      );
    }

    if (json['message'] != null) {
      return FaceScanSubmission(message: json['message'].toString(), errors: [json['message'].toString()]);
    }

    return const FaceScanSubmission();
  }
}
