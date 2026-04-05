import 'package:light_x/core/apis/entities/analysis_response.dart';

class AnalysisState {
  final AnalysisResponse? result;
  final bool isLoadingAnalysis;

  const AnalysisState({this.result, this.isLoadingAnalysis = true});

  factory AnalysisState.d() => const AnalysisState();

  AnalysisState copyWith({AnalysisResponse? result, bool? isLoadingAnalysis}) {
    return AnalysisState(result: result ?? this.result, isLoadingAnalysis: isLoadingAnalysis ?? this.isLoadingAnalysis);
  }
}
