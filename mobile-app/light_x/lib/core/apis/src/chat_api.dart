part of '../api.dart';

class _ChatApi {
  Future<ApiResponse<Stream<String>>> streamChat({required String message, required String context}) async {
    try {
      final response = await Api.dio.post<ResponseBody>(
        ApiPaths.chat,
        data: {'message': message, 'context': context},
        options: Options(responseType: ResponseType.stream),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Transform the raw bytes into a stream of tokens
        final tokenStream = response.data!.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.startsWith('data: '))
            .map((line) => line.substring(6).trim())
            .takeWhile((payload) => payload != '[DONE]')
            .map((payload) {
              try {
                final decoded = jsonDecode(payload);
                return decoded is String ? decoded : payload;
              } catch (_) {
                return payload;
              }
            });

        return ApiResponse.success(tokenStream);
      }

      return ApiResponse.failure("Server Error: ${response.statusCode}");
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }
}
