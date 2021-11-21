import 'package:dio/dio.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

class DioApiClient {
  final StackDriverErrorReporter reporter;
  final Dio _client = Dio();

  DioApiClient(this.reporter) {
    _client.interceptors.add(DioStackDriverReport(reporter: reporter));
  }

  Future<Response> callApi(RequestOptions requestOptions) async {
    return await _client.fetch(requestOptions);
  }
}
