import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/models.dart';

enum DrawerIDs { home, users, devices, dashboard, logout }

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late String? _username;
  List<Widget> drawerList = [];
  int _selectedDestination = 0;

  void _clearUserInfo() async {
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    var userBaseController = userBaseProvider.userBaseController;
    userBaseController.logout();
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
            context, '/users', ModalRoute.withName('/users'));
        break;
      case 2:
        //Navigator.pushNamedAndRemoveUntil(context, '/device', ModalRoute.withName('/device'));
        break;
      case 3:
        //Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
        break;
      case 4:
        _clearUserInfo();
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
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
    drawerList.add(buildListTile(AppLocalizations.of(context)!.drawerHome,
        DrawerIDs.home.index, Icons.home));
    drawerList.add(buildListTile(AppLocalizations.of(context)!.drawerUsers,
        DrawerIDs.users.index, Icons.people));
    drawerList.add(buildListTile(AppLocalizations.of(context)!.drawerDevice,
        DrawerIDs.devices.index, Icons.devices));
    drawerList.add(buildListTile(AppLocalizations.of(context)!.drawerDashboard,
        DrawerIDs.dashboard.index, Icons.dashboard));
    drawerList.add(buildListTile(AppLocalizations.of(context)!.drawerLogout,
        DrawerIDs.logout.index, Icons.logout));
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
