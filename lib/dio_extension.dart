part of 'stackdriver_dart.dart';

/// Dio interceptor that forwards failed requests to Error Reporting.
class DioStackDriverReport extends dio.Interceptor {
  /// Reporter instance that receives generated API error reports.
  final StackDriverErrorReporter? reporter;

  /// Creates the Dio interceptor.
  DioStackDriverReport({this.reporter});

  /// Passes requests through and reports request construction failures.
  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) {
    final url = options.uri.toString();
    try {
      super.onRequest(options, handler);
    } catch (error, trace) {
      reporter?.apiReport(
        ApiException.withInner(
          HttpStatus.badRequest,
          'Invalid HTTP operation: ${options.method} $url',
          options.method,
          url,
          error,
          trace,
        ),
      );
      rethrow;
    }
  }

  /// Reports bad responses and transport errors from Dio.
  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    final url = err.response?.requestOptions.uri.toString() ?? "";
    if (err.type == dio.DioExceptionType.badResponse) {
      reporter?.apiReport(
        ApiException.withInner(
          err.response?.statusCode ?? HttpStatus.badRequest,
          err.response?.toString(),
          err.requestOptions.method,
          url,
          null,
          err.stackTrace,
        ),
      );
    } else {
      reporter?.apiReport(
        ApiException.withInner(
          HttpStatus.badRequest,
          'Invalid HTTP operation: ${err.requestOptions.method} $url',
          err.requestOptions.method,
          url,
          err.error,
          err.stackTrace,
        ),
      );
    }
    super.onError(err, handler);
  }
}
