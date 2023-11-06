part of stackdriver_dart;

class StackDriverReportOptions {
  final bool isEnabled;
  final bool logContent;

  const StackDriverReportOptions(
      {this.isEnabled = true, this.logContent = false});
}

class StackDriverReportExtension implements MiddlewareContract {
  final StackDriverReportOptions options;
  final StackDriverErrorReporter? reporter;

  StackDriverReportExtension({
    this.reporter,
    this.options = const StackDriverReportOptions(),
  });

  @override
  void interceptRequest(RequestData data) {}

  @override
  void interceptResponse(ResponseData data) {
    try {
      if (data.statusCode >= HttpStatus.badRequest) {
        reporter?.apiReport(ApiException.withInner(
            data.statusCode,
            options.logContent ? data.body : null,
            data.method.name,
            data.url,
            null,
            StackTrace.current));
      }
    } catch (error, trace) {
      reporter?.apiReport(ApiException.withInner(
        HttpStatus.badRequest,
        'Invalid HTTP operation: ${data.method.name} ${data.url}',
        data.method.name,
        data.url,
        error,
        trace,
      ));
      rethrow;
    }
  }

  @override
  void interceptError(dynamic error) {}
}
