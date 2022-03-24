part of stackdriver_dart;

class ApiException implements Exception {
  ApiException.withInner(this.code, this.message, this.method, this.url,
      this.innerException, this.stackTrace);

  int code = 0;
  String? message;
  String method;
  String url;
  Object? innerException;
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

class ServiceContext {
  String? version;
  String? service;
  String? resourceType;

  ServiceContext({this.version, this.service, this.resourceType});

  @override
  String toString() {
    return toJson().toString();
  }

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

class SourceLocation {
  String? filePath;
  int? lineNumber;
  String? functionName;

  SourceLocation({
    this.filePath,
    this.lineNumber,
    this.functionName,
  });

  @override
  String toString() {
    return toJson().toString();
  }

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

class SourceReference {
  String? repository;
  String? revisionId;

  SourceReference({
    this.repository,
    this.revisionId,
  });

  @override
  String toString() {
    return toJson().toString();
  }

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

class HttpRequestContext {
  String? method;
  String? url;
  String? userAgent;
  String? referrer;
  String? responseStatusCode;
  String? remoteIp;

  HttpRequestContext(
      {this.method,
      this.url,
      this.userAgent,
      this.referrer,
      this.responseStatusCode,
      this.remoteIp});

  static HttpRequestContext fromException(ApiException exception) {
    return HttpRequestContext(
        method: exception.method,
        url: exception.url,
        responseStatusCode: exception.code.toString(),
        userAgent: HttpClient().userAgent,
        referrer: "",
        remoteIp: "");
  }

  @override
  String toString() {
    return toJson().toString();
  }

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

class ErrorContext {
  SourceLocation? reportLocation;
  List<SourceReference>? sourceReferences;
  HttpRequestContext? httpRequest;
  String? user;

  ErrorContext(
      {this.reportLocation,
      this.sourceReferences,
      this.httpRequest,
      this.user});

  @override
  String toString() {
    return toJson().toString();
  }

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

class Payload {
  ServiceContext? serviceContext;
  ErrorContext? context;
  String? message;

  Payload({this.serviceContext, this.context, this.message});

  @override
  String toString() {
    return toJson().toString();
  }

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
