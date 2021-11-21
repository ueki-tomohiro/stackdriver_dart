import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stackdriver_dart/stackdriver_dart.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Report Sample",
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', ''),
      ],
      home: Container(
        child: const Center(
          child: Text(
            "Report Sample",
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: 24,
              fontWeight: FontWeight.w200,
              color: Color.fromRGBO(0, 102, 238, 0.08),
            ),
          ),
        ),
      ),
    );
  }
}

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
