class HttpResponseError {
  HttpResponseError({
    required this.errorType,
    required this.message,
    this.stackTrace,
    int? statusCode,
    this.reason,
  }) : statusCode = statusCode ?? 999;

  final int statusCode;
  final String? errorType, message, reason;
  final StackTrace? stackTrace;
}
