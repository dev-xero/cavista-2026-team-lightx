import 'package:light_x/core/apis/entities/analysis_result.dart';

class AnalysisState {
  final AnalysisResult? result;
  final bool isLoadingAnalysis;

  const AnalysisState({this.result, this.isLoadingAnalysis = true});

  factory AnalysisState.d() => const AnalysisState();

  AnalysisState copyWith({AnalysisResult? result, bool? isLoadingAnalysis}) {
    return AnalysisState(result: result ?? this.result, isLoadingAnalysis: isLoadingAnalysis ?? this.isLoadingAnalysis);
  }
}
