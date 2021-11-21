part of stackdriver_dart;

class StackDriverReportOptions {
  final bool isEnabled;

  const StackDriverReportOptions({this.isEnabled = true});
}

class StackDriverReportExtension extends Extension<StackDriverReportOptions> {
  final StackDriverErrorReporter? reporter;

  StackDriverReportExtension(
      {StackDriverReportOptions defaultOptions =
          const StackDriverReportOptions(),
      this.reporter})
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
            await response.stream.bytesToString(),
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
