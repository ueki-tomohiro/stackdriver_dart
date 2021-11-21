import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_extensions/http_extensions.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

class HttpApiClient {
  late final StackDriverErrorReporter reporter;
  late final ExtendedClient _client;

  HttpApiClient(this.reporter) {
    _client = ExtendedClient(
      inner: http.Client() as http.BaseClient,
      extensions: [
        StackDriverReportExtension(reporter: reporter),
      ],
    );
  }

  Future<http.StreamedResponse> callApi(http.Request request) async {
    return await _client.send(request);
  }
}

class DioApiClient {
  final StackDriverErrorReporter reporter;
  final dio.Dio _client = dio.Dio();

  DioApiClient(this.reporter) {
    _client.interceptors.add(DioStackDriverReport(reporter: reporter));
  }

  Future<dio.Response> callApi(dio.RequestOptions requestOptions) async {
    return await _client.fetch(requestOptions);
  }
}


void main() {
  final config = Config(
      projectId: "PROJECT_ID",
      key:"API_KEY",
      service: 'my-app',
      version: "1.0.0");

  test('start', () {
    final reporter = StackDriverErrorReporter();
    reporter.start(config);
  });

  test('http test', () async {
    final reporter = StackDriverErrorReporter();
    reporter.start(config);
    final httpApiClient = HttpApiClient(reporter);
    try {
    await httpApiClient.callApi(http.Request("GET", Uri.parse("")));
    } catch(_){}
  });

  test('dio test', () async {
    final reporter = StackDriverErrorReporter();
    reporter.start(config);
    final dioApiClient = DioApiClient(reporter);
    try {
      await dioApiClient.callApi(dio.RequestOptions(path: ""));
    } catch(_){}
  });
}
