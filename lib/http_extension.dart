part of stackdriver_dart;

class StackDriverReportOptions {
  final bool isEnabled;
  final bool logContent;

  const StackDriverReportOptions(
      {this.isEnabled = true, this.logContent = false});
}

class StackDriverReportExtension extends Extension<StackDriverReportOptions> {
  final StackDriverErrorReporter? reporter;

  StackDriverReportExtension(
      {this.reporter,
      StackDriverReportOptions defaultOptions =
          const StackDriverReportOptions()})
      : super(defaultOptions: defaultOptions);

  @override
  Future<http.StreamedResponse> sendWithOptions(
      http.BaseRequest request, StackDriverReportOptions options) async {
    if (!options.isEnabled) {
      return await super.sendWithOptions(request, options);
    }
    final url = request.url.toString();

    try {
      final response = await super.sendWithOptions(request, options);

      if (response.statusCode >= HttpStatus.badRequest) {
        reporter?.apiReport(ApiException.withInner(
            response.statusCode,
            options.logContent ? await response.stream.bytesToString() : null,
            request.method,
            url,
            null,
            StackTrace.current));
      }

      return response;
    } catch (error, trace) {
      reporter?.apiReport(ApiException.withInner(
          HttpStatus.badRequest,
          'Invalid HTTP operation: ${request.method} $url',
          request.method,
          url,
          error,
          trace));
      rethrow;
    }
  }
}
