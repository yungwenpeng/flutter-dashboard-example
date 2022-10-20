import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = const FlutterSecureStorage();
  int _selectedDestination = 0;
  String? _username;

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
  }

  void _loadUserInfo() async {
    _username = await storage.read(key: "username");
    setState(() {
      _username = _username!.contains('@')
          ? (_username!.substring(0, _username?.indexOf('@')))
          : _username;
    });
  }

  void _clearUserInfo() async {
    var tbClient = ThingsboardClient(dotenv.env['API_URL'] ?? '');
    await storage.delete(key: "username");
    await tbClient.logout();
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
            leading: IconButton(
              icon: const Icon(Icons.menu),
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
                    image: const AssetImage(
                        "assets/images/navigation_drawer_bg.png"),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(.4), BlendMode.multiply)),
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Hi $_username,',
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
                  buildListTile(AppLocalizations.of(context)!.drawerDevice, 1,
                      Icons.devices),
                  buildListTile(AppLocalizations.of(context)!.drawerDashboard,
                      2, Icons.dashboard),
                  buildListTile(AppLocalizations.of(context)!.drawerLogout, 3,
                      Icons.logout),
                ],
              ),
            ),
          ),
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
