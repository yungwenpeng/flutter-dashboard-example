import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_app/l10n/l10n.dart';

import '../localization/localization.dart';
import 'pages.dart';

class MyPreferences extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  final VoidCallback onPreferences;
  const MyPreferences(
      {super.key,
      required this.onLogout,
      required this.onUserList,
      required this.onPreferences});

  @override
  State<MyPreferences> createState() => _MyPreferencesState();
}

class _MyPreferencesState extends State<MyPreferences> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late Locale? dropdownValue;

  @override
  void initState() {
    super.initState();
    _loadlanguageCode();
  }

  void _loadlanguageCode() async {
    dropdownValue = const Locale('en');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? 'en';
    application.onLocaleChanged = onLocaleChange;
    onLocaleChange(Locale(languageCode));
    dropdownValue = Locale(languageCode);
  }

  void onLocaleChange(Locale locale) async {
    setState(() {
      AppTranslations.load(locale);
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
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppTranslations.of(context)!.text('drawerPreferences')),
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
          onPreferences: () => widget.onPreferences(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Center(
              child: Column(
                children: [
                  Text(
                      AppTranslations.of(context)!
                          .text('preferencesSelectLanguage'),
                      style: const TextStyle(
                          fontSize: 28,
                          color: Color.fromARGB(255, 223, 98, 49),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  DropdownButton(
                    value: dropdownValue,
                    style: const TextStyle(fontSize: 26, color: Colors.white),
                    dropdownColor: const Color.fromARGB(255, 28, 163, 197),
                    icon: const Icon(Icons.language,
                        color: Color.fromARGB(255, 243, 100, 33), size: 32),
                    borderRadius: BorderRadius.circular(20),
                    items: L10n.all.map(
                      ((locale) {
                        final name = L10n.getName(locale.languageCode);
                        final countryCode =
                            L10n.getCountryFlag(locale.languageCode);
                        return DropdownMenuItem(
                            value: locale,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _flagWidget(countryCode, context),
                                  dropdownValue == locale
                                      ? Text(
                                          name,
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 250, 131, 34),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : Text(name),
                                ],
                              ),
                            ));
                      }),
                    ).toList(),
                    onChanged: (value) async {
                      //print('onChanged value:$value, dropdownValue:$dropdownValue');
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('languageCode', value.toString());
                      setState(() {
                        dropdownValue = Locale(value.toString());
                        onLocaleChange(Locale(value.toString()));
                      });
                      Restart.restartApp();
                    },
                    /*underline: Container(
                        height: 1,
                        color: const Color.fromARGB(255, 254, 255, 175)),*/
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flagWidget(String countryCode, BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    var flagText =
        String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: Text(
        flagText,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
