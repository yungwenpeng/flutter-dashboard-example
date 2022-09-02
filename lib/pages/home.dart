import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/thingsboard_client_base_provider.dart';
import 'drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? _username;

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
  }

  void _loadUserInfo() async {
    var tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    var tbClient = tbClientBaseProvider.tbClient;
    _username = tbClient.getAuthUser()?.sub;
    setState(() {
      _username = _username!.substring(0, _username?.indexOf('@'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/welcome_bg.png'),
          fit: BoxFit.fill,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.homeAppBarTitle),
            /*leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),*/
          ),
          drawer: const MyDrawer(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hi $_username,\nWelcome to Demo Homepage!',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
