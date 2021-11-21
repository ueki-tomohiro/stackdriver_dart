part of stackdriver_dart;

class DioStackDriverReport extends dio.Interceptor {
  final StackDriverErrorReporter? reporter;

  DioStackDriverReport({this.reporter});

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    final url = options.uri.toString();
    try {
      super.onRequest(options, handler);
    } catch (error, trace) {
      reporter?.apiReport(ApiException.withInner(
          HttpStatus.badRequest,
          'Invalid HTTP operation: ${options.method} $url',
          options.method,
          url,
          error,
          trace));
      rethrow;
    }
  }
  @override
  void onError(dio.DioError err, dio.ErrorInterceptorHandler handler) {
    final url = err.response?.requestOptions.uri.toString() ?? "";
    if (err.type == dio.DioErrorType.response) {
      reporter?.apiReport(ApiException.withInner(
          err.response?.statusCode ?? HttpStatus.badRequest,
          err.response?.toString(),
          err.requestOptions.method,
          url,
          null,
          err.stackTrace));
    } else {
      reporter?.apiReport(ApiException.withInner(
          HttpStatus.badRequest,
          'Invalid HTTP operation: ${err.requestOptions.method} $url',
          err.requestOptions.method,
          url,
          err.error,
          err.stackTrace));
    }
    super.onError(err, handler);
  }
}
