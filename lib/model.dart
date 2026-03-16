part of 'stackdriver_dart.dart';

/// Wraps HTTP failure information before it is sent to Error Reporting.
class ApiException implements Exception {
  /// Creates an API exception with the original error and stack trace.
  ApiException.withInner(
    this.code,
    this.message,
    this.method,
    this.url,
    this.innerException,
    this.stackTrace,
  );

  /// HTTP status code associated with the failure.
  int code = 0;

  /// Message body or summary captured from the failed operation.
  String? message;

  /// HTTP method used for the request.
  String method;

  /// Request URL that failed.
  String url;

  /// Original exception thrown by the HTTP client, when available.
  Object? innerException;

  /// Stack trace captured when the failure was observed.
  StackTrace? stackTrace;

  @override
  String toString() {
    if (message == null) {
      return 'ApiException';
    }
    if (innerException != null) {
      return 'ApiException $code: $message (Inner exception: $innerException)\n\n$stackTrace';
    }

    return 'ApiException $code: $message';
  }
}

/// Describes the service metadata attached to an error payload.
class ServiceContext {
  /// Service version shown in Google Cloud Error Reporting.
  String? version;

  /// Service name shown in Google Cloud Error Reporting.
  String? service;

  /// Optional monitored resource type.
  String? resourceType;

  /// Creates a service context payload.
  ServiceContext({this.version, this.service, this.resourceType});

  @override
  String toString() {
    return toJson().toString();
  }

  /// Converts this object to a JSON-ready map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (version != null) {
      json[r'version'] = version;
    }
    if (service != null) {
      json[r'service'] = service;
    }

    return json;
  }
}

/// Identifies a source code location for a reported error.
class SourceLocation {
  /// Path of the source file.
  String? filePath;

  /// Line number of the source location.
  int? lineNumber;

  /// Function or method name.
  String? functionName;

  /// Creates a source location payload.
  SourceLocation({this.filePath, this.lineNumber, this.functionName});

  @override
  String toString() {
    return toJson().toString();
  }

  /// Converts this object to a JSON-ready map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (filePath != null) {
      json[r'filePath'] = filePath;
    }
    if (lineNumber != null) {
      json[r'lineNumber'] = lineNumber;
    }
    if (functionName != null) {
      json[r'functionName'] = functionName;
    }

    return json;
  }
}

/// Describes a source repository reference related to an error.
class SourceReference {
  /// Repository URL or identifier.
  String? repository;

  /// Revision identifier such as a commit SHA.
  String? revisionId;

  /// Creates a source reference payload.
  SourceReference({this.repository, this.revisionId});

  @override
  String toString() {
    return toJson().toString();
  }

  /// Converts this object to a JSON-ready map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (repository != null) {
      json[r'repository'] = repository;
    }
    if (revisionId != null) {
      json[r'revisionId'] = revisionId;
    }

    return json;
  }
}

/// Captures request metadata for an API failure report.
class HttpRequestContext {
  /// HTTP method used for the request.
  String? method;

  /// Request URL.
  String? url;

  /// User-Agent header value.
  String? userAgent;

  /// Referrer header value.
  String? referrer;

  /// HTTP response status code.
  String? responseStatusCode;

  /// Remote IP address, when available.
  String? remoteIp;

  /// Creates an HTTP request context payload.
  HttpRequestContext({
    this.method,
    this.url,
    this.userAgent,
    this.referrer,
    this.responseStatusCode,
    this.remoteIp,
  });

  /// Builds a request context from an [ApiException].
  static HttpRequestContext fromException(ApiException exception) {
    return HttpRequestContext(
      method: exception.method,
      url: exception.url,
      responseStatusCode: exception.code.toString(),
      userAgent: HttpClient().userAgent,
      referrer: "",
      remoteIp: "",
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  /// Converts this object to a JSON-ready map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (method != null) {
      json[r'method'] = method;
    }
    if (url != null) {
      json[r'url'] = url;
    }
    if (userAgent != null) {
      json[r'userAgent'] = userAgent;
    }
    if (method != null) {
      json[r'method'] = method;
    }
    if (referrer != null) {
      json[r'referrer'] = referrer;
    }
    if (responseStatusCode != null) {
      json[r'responseStatusCode'] = responseStatusCode;
    }
    if (remoteIp != null) {
      json[r'remoteIp'] = remoteIp;
    }

    return json;
  }
}

/// Provides additional metadata for a reported error.
class ErrorContext {
  /// Source location where the error occurred.
  SourceLocation? reportLocation;

  /// Source references that help identify the build or repository revision.
  List<SourceReference>? sourceReferences;

  /// HTTP request metadata associated with the failure.
  HttpRequestContext? httpRequest;

  /// End-user identifier attached to the report.
  String? user;

  /// Creates an error context payload.
  ErrorContext({
    this.reportLocation,
    this.sourceReferences,
    this.httpRequest,
    this.user,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  /// Converts this object to a JSON-ready map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (reportLocation != null) {
      json[r'reportLocation'] = reportLocation?.toJson();
    }
    if (sourceReferences != null) {
      json[r'sourceReferences'] = sourceReferences?.map((t) => t.toJson());
    }
    if (httpRequest != null) {
      json[r'httpRequest'] = httpRequest?.toJson();
    }
    if (user != null) {
      json[r'user'] = user;
    }

    return json;
  }
}

/// Root payload sent to Google Cloud Error Reporting.
class Payload {
  /// Service metadata for the report.
  ServiceContext? serviceContext;

  /// Additional error context for the report.
  ErrorContext? context;

  /// Formatted error message including stack trace details.
  String? message;

  /// Creates an Error Reporting payload.
  Payload({this.serviceContext, this.context, this.message});

  @override
  String toString() {
    return toJson().toString();
  }

  /// Converts this object to a JSON-ready map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (serviceContext != null) {
      json[r'serviceContext'] = serviceContext?.toJson();
    }
    if (context != null) {
      json[r'context'] = context?.toJson();
    }
    if (message != null) {
      json[r'message'] = message;
    }

    return json;
  }
}
