import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/thingsboard_client_base_provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late String _username;
  int? _selectedDestination;

  @override
  void initState() {
    super.initState();
    var tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    var tbClient = tbClientBaseProvider.tbClient;
    _username = tbClient.getAuthUser()!.sub;
    _username = _username.substring(0, _username.indexOf('@'));
  }

  void _clearUserInfo() async {
    var tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    var tbClient = tbClientBaseProvider.tbClient;
    await tbClient.logout();
  }

  @override
  Widget build(BuildContext context) {
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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hi, $_username',
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: Colors.white,
            ),
            buildListTile(
                AppLocalizations.of(context)!.drawerHome, 0, Icons.home),
            buildListTile(
                AppLocalizations.of(context)!.drawerDevice, 1, Icons.devices),
            buildListTile(AppLocalizations.of(context)!.drawerDashboard, 2,
                Icons.dashboard),
            buildListTile(
                AppLocalizations.of(context)!.drawerLogout, 3, Icons.logout),
          ],
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
        break;
      case 2:
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
            color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
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
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: isSelected,
          onTap: () => selectDestination(index),
        ));
  }
}
