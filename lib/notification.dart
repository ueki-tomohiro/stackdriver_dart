part of 'stackdriver_dart.dart';

/// URL endpoint of the Stackdriver Error Reporting report API.
const baseAPIUrl =
    'https://clouderrorreporting.googleapis.com/v1beta1/projects/';

/// Signature for a custom reporting transport implementation.
typedef ReportingFunction = FutureOr<Exception?> Function(Payload payload);

/// Configuration used to initialize [StackDriverErrorReporter].
class Config {
  /// API key used with the default Google Cloud Error Reporting endpoint.
  final String? key;

  /// Custom report endpoint, typically a proxy or test server.
  final String? targetUrl;

  /// Google Cloud project identifier.
  final String? projectId;

  /// Optional value sent as both `referer` and `origin` headers.
  final String? referer;

  /// Base context attached to all reports.
  final ErrorContext? context;

  /// Service name shown in Error Reporting.
  final String? service;

  /// Service version shown in Error Reporting.
  final String? version;

  /// Disables all reporting when `true`.
  final bool disabled;

  /// Registers uncaught Flutter errors automatically when `true`.
  final bool reportUncaughtExceptions;

  /// Overrides HTTP transport and receives each generated payload.
  final ReportingFunction? customReportingFunction;

  /// Creates a reporter configuration.
  Config({
    this.key,
    this.targetUrl,
    this.projectId,
    this.referer,
    this.context,
    this.service,
    this.version,
    this.disabled = false,
    this.reportUncaughtExceptions = true,
    this.customReportingFunction,
  });
}

/// Singleton reporter for sending exceptions to Google Cloud Error Reporting.
class StackDriverErrorReporter {
  /// Custom transport used instead of the default HTTP sender.
  ReportingFunction? customReportingFunction;

  /// API key used for the default endpoint.
  String? apiKey;

  /// Google Cloud project identifier.
  String? projectId;

  /// Override URL for the report endpoint.
  String? targetUrl;

  /// Optional `referer` header value.
  String referer = "";

  /// Base context attached to each report.
  ErrorContext? context;

  /// Service metadata attached to each report.
  ServiceContext? serviceContext;

  /// Disables sending reports when `true`.
  bool disabled = true;

  /// Controls automatic registration of uncaught Flutter errors.
  bool reportUncaughtExceptions = true;

  final _client = http.Client();

  StackDriverErrorReporter._internal();

  static final StackDriverErrorReporter _stackDriverErrorReporter =
      StackDriverErrorReporter._internal();

  factory StackDriverErrorReporter() {
    return _stackDriverErrorReporter;
  }

  /// Initializes the singleton reporter with [config].
  void start(Config config) {
    if (config.key?.isNotEmpty == false &&
        config.targetUrl?.isNotEmpty == false &&
        config.customReportingFunction == null) {
      throw Exception(
        'Cannot initialize: No API key, target url or custom reporting function provided.',
      );
    }
    if (config.projectId?.isNotEmpty == false &&
        config.targetUrl?.isNotEmpty == false &&
        config.customReportingFunction != null) {
      throw Exception(
        'Cannot initialize: No project ID, target url or custom reporting function provided.',
      );
    }

    customReportingFunction = config.customReportingFunction;
    apiKey = config.key;
    projectId = config.projectId;
    referer = config.referer ?? "";
    targetUrl = config.targetUrl;
    context = config.context ?? ErrorContext();
    serviceContext = ServiceContext(
      service: config.service ?? 'web',
      version: config.version ?? "",
    );
    reportUncaughtExceptions = config.reportUncaughtExceptions != false;
    disabled = config.disabled;

    registerHandlers(this);
  }

  /// Registers handlers for uncaught Flutter framework errors.
  void registerHandlers(StackDriverErrorReporter reporter) {
    if (reporter.reportUncaughtExceptions) {
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        try {
          reporter.report(err: details);
        } catch (_) {}
      };
    }
  }

  /// Reports an application error or exception.
  Future<Exception?> report({Object? err, StackTrace? trace}) async {
    if (disabled) {
      return null;
    }
    if (err == null) {
      return Exception('no error to report');
    }

    String? errorMessage;
    StackTrace? stackTrace;

    if (err is String) {
      errorMessage = err;
      stackTrace = trace ?? StackTrace.current;
    } else if (err is FlutterErrorDetails) {
      errorMessage = err.exception.toString();
      stackTrace = err.stack;
    } else if (err is Exception) {
      errorMessage = err.toString();
      stackTrace = trace ?? StackTrace.current;
    } else if (err is Error) {
      errorMessage = err.toString();
      stackTrace = err.stackTrace;
    }

    var reportUrl =
        targetUrl ?? '$baseAPIUrl$projectId/events:report?key=$apiKey';

    var customFunc = customReportingFunction;

    Payload payload = Payload(
      serviceContext: serviceContext,
      context: ErrorContext(user: context?.user ?? ""),
    );
    final message = resolveError(
      errorMessage: errorMessage,
      stackTrace: stackTrace,
    );
    payload.message = message;

    if (customFunc != null) {
      return await customFunc(payload);
    }

    return sendErrorPayload(reportUrl, payload);
  }

  /// Reports an HTTP/API failure.
  Future<Exception?> apiReport(ApiException exception) async {
    if (disabled) {
      return null;
    }

    var reportUrl =
        targetUrl ?? '$baseAPIUrl$projectId/events:report?key=$apiKey';

    final message = resolveError(
      errorMessage: exception.message,
      stackTrace: exception.stackTrace,
    );

    Payload payload = Payload(
      serviceContext: serviceContext,
      context: ErrorContext(
        httpRequest: HttpRequestContext.fromException(exception),
        user: context?.user ?? "",
      ),
      message: message,
    );

    var customFunc = customReportingFunction;
    if (customFunc != null) {
      return await customFunc(payload);
    }

    return sendErrorPayload(reportUrl, payload);
  }

  /// Formats an error message into a Stackdriver-compatible stack trace string.
  String resolveError({String? errorMessage, StackTrace? stackTrace}) {
    return 'Error: $errorMessage\n'
        '${stackTrace != null ? Trace.from(stackTrace).frames.map((f) {
                String member = f.member ?? '<anonymous>';
                if (member == '<fn>') {
                  member = '<anonymous>';
                }

                String loc = 'unknown location';
                if (f.isCore) {
                  loc = 'native';
                } else if (f.line != null) {
                  loc = '${f.uri}:${f.line}:${f.column ?? 0}';
                }

                return '    at $member ($loc)\n';
              }).join('') : ''}';
  }

  /// Sends a prepared [payload] to the report endpoint at [url].
  Future<Exception> sendErrorPayload(String url, Payload payload) async {
    final request = http.Request("POST", Uri.parse(url));
    request.headers.addAll({'Content-Type': 'application/json; charset=UTF-8'});
    if (referer != "") {
      request.headers.addAll({'referer': '$referer/', 'origin': referer});
    }
    String body = jsonEncode(payload.toJson());
    request.body = body;
    final response = await _client.send(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Exception(payload.message);
    } else if (response.statusCode == 429) {
      // HTTP 429 responses are returned by Stackdriver when API quota
      // is exceeded. We should not try to reject these as unhandled errors
      // or we may cause an infinite loop with 'reportUncaughtExceptions'.
      return Exception('quota or rate limiting error on StackDriver report');
    } else {
      var condition = '${response.statusCode} http response';
      return Exception('$condition on StackDriver report\n$responseBody');
    }
  }

  /// Sets the end-user identifier attached to subsequent reports.
  void setUser(String user) {
    context?.user = user;
  }
}
