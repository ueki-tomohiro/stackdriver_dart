part of 'stackdriver_dart.dart';

/// Options for the `http` middleware integration.
class StackDriverReportOptions {
  /// Enables or disables reporting through this middleware.
  final bool isEnabled;

  /// Includes the response body in the reported error message when `true`.
  final bool logContent;

  /// Creates middleware options.
  const StackDriverReportOptions({
    this.isEnabled = true,
    this.logContent = false,
  });
}

/// Reports failed `http` responses through `pretty_http_logger` middleware.
class StackDriverReportExtension implements MiddlewareContract {
  /// Behavior flags for this middleware.
  final StackDriverReportOptions options;

  /// Reporter instance that receives generated API error reports.
  final StackDriverErrorReporter? reporter;

  /// Creates the middleware extension.
  StackDriverReportExtension({
    this.reporter,
    this.options = const StackDriverReportOptions(),
  });

  /// Passes requests through without modification.
  @override
  void interceptRequest(RequestData data) {}

  /// Reports responses with status codes greater than or equal to `400`.
  @override
  void interceptResponse(ResponseData data) {
    try {
      if (data.statusCode >= HttpStatus.badRequest) {
        reporter?.apiReport(
          ApiException.withInner(
            data.statusCode,
            options.logContent ? data.body : null,
            data.method.name,
            data.url,
            null,
            StackTrace.current,
          ),
        );
      }
    } catch (error, trace) {
      reporter?.apiReport(
        ApiException.withInner(
          HttpStatus.badRequest,
          'Invalid HTTP operation: ${data.method.name} ${data.url}',
          data.method.name,
          data.url,
          error,
          trace,
        ),
      );
      rethrow;
    }
  }

  /// Leaves transport errors to the underlying client.
  @override
  void interceptError(dynamic error) {}
}
