import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/localization.dart';
import '../models/models.dart';
import '../route/route.dart';
import 'pages.dart';

enum DrawerIDs { home, users, devices, dashboard, logout, preferences }

class MyDrawer extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  final VoidCallback onPreferences;
  const MyDrawer({
    super.key,
    required this.onLogout,
    required this.onUserList,
    required this.onPreferences,
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late String? _username;
  List<Widget> drawerList = [];
  int? _selectedDestination;

  void _clearUserInfo() async {
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    var userBaseController = userBaseProvider.userBaseController;
    userBaseController.logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('currentPath');
  }

  @override
  void initState() {
    super.initState();
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    var userBaseController = userBaseProvider.userBaseController;
    _username = userBaseController.getAuthUser()!.email;
    _username = _username!.substring(0, _username!.indexOf('@'));
  }

  @override
  Widget build(BuildContext context) {
    createListTile(context);
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent.withOpacity(.4),
          image: DecorationImage(
              alignment: Alignment.center,
              image: const AssetImage("assets/images/navigation_drawer_bg.png"),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(.4), BlendMode.multiply)),
        ),
        child: ListView(
          children: drawerList,
        ),
      ),
    );
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
    switch (index) {
      case 0:
        MyAppRouterDelegate().loggedIn = true;
        MyAppRouterDelegate().userListIn = null;
        Navigator.maybePop(context);
        break;
      case 1:
        widget.onUserList();
        MyAppRouterDelegate().loggedIn = true;
        break;
      //case 2:
      //Navigator.pushNamedAndRemoveUntil(context, '/device', ModalRoute.withName('/device'));
      //break;
      //case 3:
      //Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
      //break;
      case 4:
        widget.onLogout();
        _clearUserInfo();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Login(
                      onLogin: () {
                        MyAppRouterDelegate().loggedIn = false;
                        MyAppRouterDelegate().userListIn = false;
                      },
                    )));
        break;
      case 5:
        MyAppRouterDelegate().loggedIn = true;
        widget.onPreferences();
        break;
    }
  }

  createListTile(BuildContext context) {
    drawerList = [];
    drawerList.add(Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Hi $_username,',
        style: const TextStyle(
            fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w400),
      ),
    ));
    drawerList.add(const Divider(height: 2, thickness: 2, color: Colors.white));
    drawerList.add(buildListTile(
        AppTranslations.of(context)!.text('drawerHome'),
        DrawerIDs.home.index,
        Icons.home));
    drawerList.add(buildListTile(
        AppTranslations.of(context)!.text('drawerUsers'),
        DrawerIDs.users.index,
        Icons.people));
    /*drawerList.add(buildListTile(AppTranslations.of(context)!.text('drawerDevice'),
        DrawerIDs.devices.index, Icons.devices));
    drawerList.add(buildListTile(AppTranslations.of(context)!.text('drawerDashboard'),
        DrawerIDs.dashboard.index, Icons.dashboard));*/
    drawerList.add(buildListTile(
        AppTranslations.of(context)!.text('drawerLogout'),
        DrawerIDs.logout.index,
        Icons.logout));
    drawerList.add(buildListTile(
        AppTranslations.of(context)!.text('drawerPreferences'),
        DrawerIDs.preferences.index,
        Icons.settings));
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
          onTap: () {
            Navigator.maybePop(context);
            selectDestination(index);
          },
        ));
  }
}
