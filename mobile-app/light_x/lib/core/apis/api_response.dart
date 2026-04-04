class ApiResponse<T> {
  final T? data;
  final String? errorMsg;

  bool get success => errorMsg == null;

  const ApiResponse({required this.data, this.errorMsg});

  factory ApiResponse.success(T data) {
    return ApiResponse(data: data, errorMsg: null);
  }

  factory ApiResponse.failure(String errorMsg, {T? data}) {
    return ApiResponse(data: null, errorMsg: errorMsg);
  }
}
