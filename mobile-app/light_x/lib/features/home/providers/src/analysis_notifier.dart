import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/core/apis/api.dart';
import 'package:light_x/core/apis/entities/health_model.dart';
import 'package:light_x/core/storage/shared_prefs/shared_prefs.dart';
import 'package:light_x/core/utils/app_logger.dart';
import 'package:light_x/features/home/providers/entities/analysis_state.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';

const _tag = 'VitalsAnalysis';

class AnalysisNotifier extends Notifier<AnalysisState> {
  @override
  AnalysisState build() => AnalysisState.d();

  Future<void> analyse() async {
    if (state.isLoadingAnalysis) return;

    final request = _buildRequest();
    state = state.copyWith(isLoadingAnalysis: true); // Set loading state
    try {
      final response = await Api.instance.analysis.analyzeVitals(request);
      if (!response.success || response.data == null) {
        AppLogger.e(response.errorMsg ?? 'Analysis failed. Please try again.');
      }

      state = state.copyWith(result: response.data);
      log('Parsed: risk=${response.data?.riskLevel.name} score=${response.data?.riskScore}', name: _tag);
    } catch (e, st) {
      log('$e', name: _tag, error: e, stackTrace: st);
    } finally {
      state = state.copyWith(isLoadingAnalysis: false); // Reset loading state
    }
  }

  void reset() {
    state = AnalysisState.d();
  }

  HealthModel _buildRequest() {
    final rawOnboarding = SharedPrefKeys.onboardingData.get<String>();
    final base = rawOnboarding == null ? HealthModel.empty() : HealthModel.fromJson(jsonDecode(rawOnboarding));

    final snapshot = ref.read(latestHealthSnapshotProvider);

    return base.copyWith(
      systolicBp: snapshot?.bloodPressure?.systolic ?? 120,
      diastolicBp: snapshot?.bloodPressure?.diastolic ?? 80,
      heartRate: snapshot?.heartRate ?? 72,
      spo2: snapshot?.spo2?.toInt() ?? 98,
      hrv: 18,
      totalCholesterol: 240,
      hdlCholesterol: 35,
      fastingGlucose: 118,
      creatinine: 1,
    );
  }
}
