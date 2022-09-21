import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'model/router_delegate.dart';
import 'model/thingsboard_client_base_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  // remove hash symbol(#) on the url like http://localhost:8080/#/
  // reference https://github.com/flutter/flutter/issues/33245#issuecomment-760214554
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyAppRouterDelegate _delegate;

  @override
  void initState() {
    super.initState();
    _delegate = MyAppRouterDelegate();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThingsBoardClientBaseProvider>(
      create: (context) => ThingsBoardClientBaseProvider(),
      child: MaterialApp(
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
        home: Router(
          routerDelegate: _delegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
