import 'package:http/http.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

class HttpApiClient {
  late final StackDriverErrorReporter reporter;
  late final HttpClientWithMiddleware _client;

  HttpApiClient(this.reporter) {
    _client = HttpClientWithMiddleware.build(
      middlewares: [
        StackDriverReportExtension(reporter: reporter),
      ],
    );
  }

  Future<StreamedResponse> callApi(Request request) async {
    return await _client.send(request);
  }
}
