// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:nutri_decide/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify app loads with login screen
    expect(find.text('Welcome Back'), findsOneWidget);

  });
}
