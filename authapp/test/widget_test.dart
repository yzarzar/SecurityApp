import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:authapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame with isLoggedIn set to false (or true).
    await tester.pumpWidget(MyApp(isLoggedIn: false)); // Pass a value for isLoggedIn

    // Verify that the app loads correctly based on the initial state.
    expect(find.text('Login'), findsOneWidget); // Assuming the LoginScreen shows 'Login' text
    expect(find.text('Home'), findsNothing);

    // You could add more tests specific to your app's behavior here.
  });
}
