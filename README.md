This package report to Google Cloud Error Reporting.
It's multi-platform.
Http request supported via http and dio package.

## Usage

To See `/example` folder.

### Initialize
```dart
Future main() async {
  final config = Config(
    projectId: "PROJECT_ID",
    key:"API_KEY",
    service: 'my-app',
    version: "1.0.0");

  final reporter = StackDriverErrorReporter();
  reporter.start(config);

  runZonedGuarded(() async {
    runApp(const MyApp());
  }, (error, trace) {
    reporter.report(err: error, trace: trace);
  });
}
```