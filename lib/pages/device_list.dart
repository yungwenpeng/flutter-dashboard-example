import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/thingsboard_client_base_provider.dart';
import 'drawer.dart';

class MyDevicesPage extends StatefulWidget {
  const MyDevicesPage({super.key});

  @override
  State<MyDevicesPage> createState() => _MyDevicesPageState();
}

class _MyDevicesPageState extends State<MyDevicesPage> {
  void _clearUserInfo() async {
    var tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    var tbClient = tbClientBaseProvider.tbClient;
    await tbClient.logout();
  }

  @override
  void initState() {
    super.initState();

    final tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    tbClientBaseProvider.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    final tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context);
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        alignment: Alignment.center,
        image: AssetImage('assets/images/welcome_bg.png'),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.deviceAppBarTitle),
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: (() {
                  _clearUserInfo();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', ModalRoute.withName('/login'));
                })),
          ],
        ),
        drawer: const MyDrawer(),
        body: ListView.builder(
          itemCount: tbClientBaseProvider.myDevices.length,
          itemBuilder: (context, index) {
            String name = tbClientBaseProvider.myDevices.values
                .toList(growable: true)[index]
                .deviceName;
            String id = tbClientBaseProvider.myDevices.values
                .toList(growable: true)[index]
                .deviceId;
            return Card(
                elevation: 0,
                color: Colors
                    .lightBlueAccent, //Color.fromARGB(195, 208, 227, 235),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white70, width: 3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.devices,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  subtitle: Text(id, maxLines: 1),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    //color: Colors.white,
                    tooltip: AppLocalizations.of(context)!.deviceDetails,
                    onPressed: (() => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(name, textAlign: TextAlign.center),
                            content: SingleChildScrollView(
                                child: ListBody(children: [
                              Text(
                                  '${AppLocalizations.of(context)!.deviceId}: $id'),
                              const SizedBox(height: 6.0),
                              Text(
                                  '${AppLocalizations.of(context)!.deviceCreateTime}: ${tbClientBaseProvider.myDevices.values.toList(growable: true)[index].deviceCreateTime}'),
                              const SizedBox(height: 6.0),
                              Text(
                                  '${AppLocalizations.of(context)!.deviceLabel}: ${tbClientBaseProvider.myDevices.values.toList(growable: true)[index].deviceLabel}'),
                              const SizedBox(height: 6.0),
                              Text(
                                  '${AppLocalizations.of(context)!.deviceFirmwareId}: ${tbClientBaseProvider.myDevices.values.toList(growable: true)[index].deviceFirmwareId}'),
                              const SizedBox(height: 6.0),
                              Text(
                                  '${AppLocalizations.of(context)!.deviceSoftwareId}: ${tbClientBaseProvider.myDevices.values.toList(growable: true)[index].deviceSoftwareId}')
                            ])),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.white70, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        )),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
