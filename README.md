[![pub package](https://img.shields.io/pub/v/stackdriver_dart.svg)](https://pub.dev/packages/stackdriver_dart)

# stackdriver_dart

Flutter applications can use `stackdriver_dart` to send uncaught errors and HTTP
failures to Google Cloud Error Reporting.

The package includes:

- app error reporting via `StackDriverErrorReporter`
- automatic `FlutterError.onError` registration
- manual reporting for caught exceptions
- request failure reporting for both `http` and `dio`
- custom transport support via `targetUrl` or `customReportingFunction`

## Requirements

- Dart `>=3.0.0 <4.0.0`
- Flutter `>=3.10.0`

## Installation

Add the dependency:

```yaml
dependencies:
  stackdriver_dart: ^1.1.0
```

Then install packages:

```bash
flutter pub get
```

## Basic Setup

Initialize the reporter before `runApp`, then forward uncaught zone errors.

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

Future<void> main() async {
  final reporter = StackDriverErrorReporter();
  reporter.start(
    Config(
      projectId: 'PROJECT_ID',
      key: 'API_KEY',
      service: 'my-app',
      version: '1.0.0',
    ),
  );

  runZonedGuarded(() async {
    runApp(const MyApp());
  }, (error, trace) {
    reporter.report(err: error, trace: trace);
  });
}
```

`start()` also registers `FlutterError.onError` by default, so framework errors
are reported automatically.

## Report Errors Manually

Use `report()` for handled exceptions or custom messages.

```dart
try {
  throw StateError('Something went wrong');
} catch (error, trace) {
  await StackDriverErrorReporter().report(err: error, trace: trace);
}
```

You can attach a user identifier to subsequent reports:

```dart
final reporter = StackDriverErrorReporter();
reporter.setUser('user-123');
```

## Report `http` Failures

`StackDriverReportExtension` integrates with
`pretty_http_logger`'s `HttpClientWithMiddleware`.

```dart
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

class HttpApiClient {
  HttpApiClient(StackDriverErrorReporter reporter)
      : _client = HttpClientWithMiddleware.build(
          middlewares: [
            StackDriverReportExtension(
              reporter: reporter,
              options: const StackDriverReportOptions(
                logContent: true,
              ),
            ),
          ],
        );

  final HttpClientWithMiddleware _client;

  Future<http.StreamedResponse> callApi(http.Request request) {
    return _client.send(request);
  }
}
```

`StackDriverReportExtension` reports responses with status code `>= 400`.
Set `logContent: true` only when response bodies are safe to send.

## Report `dio` Failures

`DioStackDriverReport` reports bad responses and request errors from `dio`.

```dart
import 'package:dio/dio.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

class DioApiClient {
  DioApiClient(StackDriverErrorReporter reporter) {
    _client.interceptors.add(DioStackDriverReport(reporter: reporter));
  }

  final Dio _client = Dio();

  Future<Response<dynamic>> getUser() {
    return _client.get('/users/me');
  }
}
```

## Configuration

`Config` supports the following options:

| Field | Description |
| --- | --- |
| `key` | API key used for the Google Cloud Error Reporting endpoint. |
| `projectId` | Google Cloud project ID. |
| `service` | Service name included in the report payload. |
| `version` | Service version included in the report payload. |
| `referer` | Optional `referer` and `origin` headers for outgoing requests. |
| `context` | Base `ErrorContext`, including the current user value. |
| `targetUrl` | Overrides the default report endpoint. Useful for proxies or testing. |
| `disabled` | Disables all reporting when `true`. |
| `reportUncaughtExceptions` | Controls automatic `FlutterError.onError` registration. Defaults to `true`. |
| `customReportingFunction` | Receives the generated `Payload` instead of sending an HTTP request. |

Example with a custom reporting function:

```dart
final reporter = StackDriverErrorReporter();
reporter.start(
  Config(
    service: 'my-app',
    version: '1.0.0',
    customReportingFunction: (Payload payload) async {
      print(payload);
      return Exception(payload.message);
    },
  ),
);
```

## Example App

See the sample application in [`example/lib/main.dart`](./example/lib/main.dart).
