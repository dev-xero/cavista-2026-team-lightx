import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:light_x/core/apis/api.dart';
import 'package:light_x/core/apis/api_paths.dart';
import 'package:light_x/core/apis/api_response.dart';
import 'package:light_x/core/apis/entities/analysis_result.dart';
import 'package:light_x/core/apis/entities/health_model.dart';
import 'package:light_x/core/utils/app_logger.dart';
import 'package:light_x/data/models/health_model.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';

part 'src/chat_api.dart';
part 'src/analysis_api.dart';

class Api {
  static final _internal = Api._();
  static Api get instance => _internal;
  Api._();

  static final dio = Dio();

  final chat = _ChatApi();
  final analysis = _AnalysisApi();

  static String parseFriendlyError(Object e) {
    final s = e.toString();
    switch (s) {
      case var str when str.contains('TimeoutException'):
        return 'Request timed out. Please try again.';
      case var str when str.contains('SocketException') || str.contains('Connection refused'):
        return 'Cannot reach server. Check your connection.';
      case var str when str.contains('422'):
        return 'Invalid data submitted. Please check your inputs.';
      case var str when str.contains('500'):
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
