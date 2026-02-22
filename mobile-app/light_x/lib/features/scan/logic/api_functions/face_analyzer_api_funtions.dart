import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:light_x/core/apis/api_paths.dart';
import 'package:light_x/core/utils/result.dart';

class FaceAnalyzerApiFunctions {
  static Future<Result<Map<String, dynamic>>> analyzeFacial(Uint8List image) async {
    log("Sending image for facial analysis...");
    final result = await Result.tryRunAsync(() async {
      final uri = Uri.parse(ApiPaths.faceAnalysis);

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes('file', image, filename: 'face.jpg', contentType: MediaType('image', 'jpeg')),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      log('Face analysis response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return null;
      }
    });

    return result.isSuccess && result.data != null
        ? Result.success(result.data!)
        : Result.error(result.message ?? 'Unknown error during facial analysis');
  }
}
