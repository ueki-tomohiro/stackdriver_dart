import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('renders the report sample screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Report Sample'), findsOneWidget);
  });
}
