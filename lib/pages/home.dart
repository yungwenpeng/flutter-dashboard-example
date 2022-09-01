// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  //late SharedPreferences _logindprefs;
  final storage = FlutterSecureStorage();
  int _selectedDestination = 0;
  late Color? color;
  String? _username;

  @override
  void initState() {
    super.initState();

    color = Colors.transparent;
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    //_logindprefs = await SharedPreferences.getInstance();
    _username = await storage.read(key: "username");
    setState(() {
      //_username = (_logindprefs.getString('username') ?? '');
      _username = _username!.substring(0, _username?.indexOf('@'));
    });
  }

  void _clearUserInfo() async {
    //_logindprefs = await SharedPreferences.getInstance();
    //await _logindprefs.clear();
    await storage.delete(key: "username");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/welcome_bg.png'),
          fit: BoxFit.fill,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: scaffoldKey,
          appBar: AppBar(
            title: Text("Demo HomePage"),
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          drawer: Drawer(
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent.withOpacity(.4),
                image: DecorationImage(
                    alignment: Alignment.center,
                    image: AssetImage("assets/images/navigation_drawer_bg.png"),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(.4), BlendMode.multiply)),
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Hi $_username,',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Divider(
                    height: 2,
                    thickness: 2,
                    color: Colors.white,
                  ),
                  buildListTile('Home', 0, Icons.home),
                  buildListTile('Device', 1, Icons.devices),
                  buildListTile('Dashboard', 2, Icons.dashboard),
                  buildListTile('Logout', 3, Icons.logout),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
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

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
        break;
      case 1:
        //Navigator.pushNamedAndRemoveUntil(context, '/device', ModalRoute.withName('/device'));
        break;
      case 2:
        //Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
        break;
      case 3:
        _clearUserInfo();
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
        break;
    }
  }

  Widget buildListTile(String title, int index, IconData iconName) {
    bool isSelected = _selectedDestination == index;
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: isSelected ? 3.0 : 0,
            color: isSelected ? Colors.blue.shade500 : Colors.transparent,
          ),
          color: isSelected ? Colors.blue.shade500 : Colors.transparent,
        ),
        child: ListTile(
          leading:
              Icon(iconName, color: isSelected ? Colors.black : Colors.white),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          selected: isSelected,
          onTap: () => selectDestination(index),
        ));
  }
}
