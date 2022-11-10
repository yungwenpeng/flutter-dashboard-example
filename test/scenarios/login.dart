import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thingsboard_app/models/user_provider.dart';
import 'package:thingsboard_app/pages/pages.dart';

Widget createLoginScreen() => ChangeNotifierProvider<UserBaseProvider>(
      create: (context) => UserBaseProvider(),
      child: const MaterialApp(
        home: Login(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [
          Locale('en', ''),
        ],
      ),
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Page Widget Tests : ', () {
    testWidgets('Testing if SingleChildScrollView shows up', (tester) async {
      // Build the widget
      await tester.pumpWidget(createLoginScreen());
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Testing Scrolling', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      expect(find.widgetWithText(TextFormField, 'Username(email)'),
          findsOneWidget);
      // Scroll until the item to be found appears.
      await tester.fling(
          find.byType(SingleChildScrollView), const Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.login), findsWidgets);
    });

    testWidgets('validating error message when username input error',
        (tester) async {
      await tester.pumpWidget(createLoginScreen());
      /* 
        Steps:
        1. Enter 'test' into the username TextFormField 
        2. Tap the login button
        3. Expect to show the snackbar on screen.
      */
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Username(email)'), 'test');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      expect(find.text('Please fix the errors in red before submitting.'),
          findsOneWidget);
      expect(find.text('Username(email) need @ character'), findsOneWidget);
    });

    testWidgets('validating error message when password input error',
        (tester) async {
      var inputText = '12';
      await tester.pumpWidget(createLoginScreen());
      /* 
        Steps:
        1. Enter 'test' into the password TextFormField
        2. Tap the visibility_off icon, verify inputText and visibility icon
        2. Tap the login button
        3. Expect to show the snackbar on screen.
      */
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), inputText);
      await tester.tap(find.byIcon(Icons.visibility_off));
      expect(find.text(inputText), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      expect(find.text('Please fix the errors in red before submitting.'),
          findsOneWidget);
      expect(find.text('Minimum character length is 6'), findsOneWidget);
    });
  });
}
