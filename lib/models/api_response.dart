class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.ok(this.data)
      : success = true,
        error = null;

  ApiResponse.fail(this.error)
      : success = false,
        data = null;
}