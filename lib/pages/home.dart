import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import 'pages.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  const MyHomePage(
      {super.key, required this.onLogout, required this.onUserList});

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
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    var userBaseController = userBaseProvider.userBaseController;
    _username = userBaseController.getAuthUser()?.email;
    setState(() {
      _username = _username != null
          ? _username!.substring(0, _username?.indexOf('@'))
          : null;
    });
    if (_username != null) {
      var userApiController = userBaseProvider.userApiController;
      inspect(userApiController.getAllUsers());
      //print('Get All User: ${userApiController.getAllUsers()}');
    }
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
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.homeAppBarTitle),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          drawer: MyDrawer(
            onLogout: () => widget.onLogout(),
            onUserList: () => widget.onUserList(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hi $_username,\n${AppLocalizations.of(context)!.welcomeHomePage}',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dotenv.env['API_URL'] ?? 'API_URL not found',
                      style: const TextStyle(color: Colors.purpleAccent),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
