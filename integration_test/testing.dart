import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Hedieaty App Integration Test', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 1: Navigate to the Login page
    final loginButton = find.text("Already have an account? Log In");
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 2: Enter email and password
    final emailField = find.byType(TextField).first; // Email input
    final passwordField = find.byType(TextField).at(1); // Password input
    await tester.enterText(emailField, "laila@gmail.com");
    await tester.enterText(passwordField, "laila123");
    await tester.tapAt(Offset(0, 0)); // Dismiss keyboard
    await tester.pumpAndSettle();

    // Step 3: Tap the Log In button
    final logInButton = find.widgetWithText(ElevatedButton, "Log In");
    expect(logInButton, findsOneWidget);
    await tester.tap(logInButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 4: Verify navigation to Home screen
    expect(find.text("Hedieaty"), findsWidgets);

    // Step 5: Navigate to a friend's event
    final friendListTile = find.byType(ListTile).first;
    expect(friendListTile, findsOneWidget);
    await tester.tap(friendListTile);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 6: Select 'View Gifts' button for the first event
await tester.pumpAndSettle(const Duration(seconds: 5)); // Allow stream to resolve

final viewGiftsButton = find.widgetWithText(ElevatedButton, "View Gifts");
expect(viewGiftsButton, findsOneWidget); // Adjust based on number of buttons expected
await tester.tap(viewGiftsButton);
await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify navigation to the gifts list screen
    expect(find.text("Gifts For Event"), findsWidgets);

    // Step 7: Tap the 'Pledge' button
    final pledgeButton = find.widgetWithText(ElevatedButton, "Pledge Gift").first;
    expect(pledgeButton, findsOneWidget);
    await tester.tap(pledgeButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 8: Navigate to the "My Pledged Gifts" page
    final myPledgedGiftsNav = find.byIcon(Icons.card_giftcard);
    expect(myPledgedGiftsNav, findsOneWidget);
    await tester.tap(myPledgedGiftsNav);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final myPledgedGiftsButton = find.widgetWithText(ListTile, "My Pledged Gifts");
    expect(myPledgedGiftsButton, findsOneWidget);
    await tester.tap(myPledgedGiftsButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 9: Verify the pledged gift
    expect(find.text("airpods"), findsOneWidget);

    // Step 10: Navigate back to the Home screen
    final homeNavBarButton = find.byIcon(Icons.home).first;
    expect(homeNavBarButton, findsOneWidget);
    await tester.tap(homeNavBarButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
