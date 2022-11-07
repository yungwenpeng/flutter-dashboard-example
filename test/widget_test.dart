// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:thingsboard_app/models/models.dart';
import 'package:thingsboard_app/pages/login.dart';

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
  group('Login Page Widget Tests', () {
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

    testWidgets('Testing SnackBar if username input validation error',
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

    testWidgets('Testing SnackBar if password input validation error',
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
  group('RestApi Tests', () {
    setUpAll(() {
      HttpOverrides.global = null;
    });
    testWidgets('Testing read', (tester) async {
      await dotenv.load(fileName: ".env");
      var apiUrl = dotenv.get('API_URL');
      await tester.runAsync(() async {
        final HttpClient client = HttpClient();
        final HttpClientRequest request = await client
            .getUrl(Uri.parse('$apiUrl/api/users?query=user1@test.com'));

        final HttpClientResponse response = await request.close();
        expect(response.statusCode, 200);
      });
    });
  });
}
