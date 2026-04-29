class HttpResponse<T> {
  HttpResponse({this.data, String? status}) : status = status ?? '999';

  final T? data;
  final String status;

  int? get statusCode => int.tryParse(status);
}
