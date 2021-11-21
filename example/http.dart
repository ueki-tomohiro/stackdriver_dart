import 'package:http/http.dart';
import 'package:http_extensions/http_extensions.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

class HttpApiClient {
  late final StackDriverErrorReporter reporter;
  late final ExtendedClient _client;

  HttpApiClient(this.reporter) {
    _client = ExtendedClient(
      inner: Client() as BaseClient,
      extensions: [
        StackDriverReportExtension(reporter: reporter),
      ],
    );
  }

  Future<StreamedResponse> callApi(Request request) async {
    return await _client.send(request);
  }
}
