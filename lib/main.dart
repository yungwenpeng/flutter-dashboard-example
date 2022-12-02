import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'localization/localization.dart';
import 'models/models.dart';
import 'route/route.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  // remove hash symbol(#) on the url like http://localhost:8080/#/
  // reference https://github.com/flutter/flutter/issues/33245#issuecomment-760214554
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyAppRouterDelegate delegate;
  late MyAppRouteInformationParser parser;
  late AppTranslationsDelegate _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    delegate = MyAppRouterDelegate();
    parser = MyAppRouteInformationParser();
    String languageCode = defaultTargetPlatform == TargetPlatform.android
        ? Platform.localeName.split('_').first
        : ui.window.locale.languageCode;
    _newLocaleDelegate =
        AppTranslationsDelegate(newLocale: Locale(languageCode));
    application.onLocaleChanged = onLocaleChange;
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String defaultLocale = defaultTargetPlatform == TargetPlatform.android
        ? Platform.localeName.split('_').first
        : ui.window.locale.languageCode;
    String languageCode = prefs.getString('languageCode') ?? defaultLocale;
    onLocaleChange(Locale(languageCode));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserBaseProvider>(
      create: (context) => UserBaseProvider(),
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        routerDelegate: delegate,
        routeInformationParser: parser,
        backButtonDispatcher: RootBackButtonDispatcher(),
        localizationsDelegates: [
          _newLocaleDelegate,
          //provides localised strings
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          //provides RTL support
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }
}
