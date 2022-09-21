import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/thingsboard_client_base_provider.dart';
import 'drawer.dart';

class MyDevicesPage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeviceList;
  final VoidCallback onDeviceDetails;
  const MyDevicesPage(
      {super.key,
      required this.onLogout,
      required this.onDeviceList,
      required this.onDeviceDetails});

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
                tooltip: AppLocalizations.of(context)!.drawerLogout,
                onPressed: (() {
                  _clearUserInfo();
                  widget.onLogout();
                })),
          ],
        ),
        drawer: MyDrawer(
          onLogout: () => widget.onLogout(),
          onDeviceList: () => widget.onDeviceList(),
        ),
        body: ListView.builder(
          itemCount: tbClientBaseProvider.myDevices.length,
          itemBuilder: (context, index) {
            var myDevices = tbClientBaseProvider.myDevices.values
                .toList(growable: true)[index];
            return Card(
              elevation: 0,
              color:
                  Colors.lightBlueAccent, //Color.fromARGB(195, 208, 227, 235),
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
                  myDevices.deviceName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black),
                ),
                subtitle: Text(myDevices.deviceId, maxLines: 1),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  //color: Colors.white,
                  tooltip: AppLocalizations.of(context)!.deviceDetails,
                  onPressed: (() {
                    _showMaterialDialog(
                        context,
                        myDevices.deviceName,
                        myDevices.deviceId,
                        myDevices.deviceCreateTime,
                        myDevices.deviceLabel,
                        myDevices.deviceProfileName,
                        myDevices.deviceFirmwareId,
                        myDevices.deviceSoftwareId);
                  }),
                ),
                onTap: () {
                  tbClientBaseProvider.deviceId = myDevices.deviceId;
                  widget.onDeviceDetails();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showMaterialDialog(BuildContext context, name, id, deviceCreateTime,
      deviceLabel, deviceProfileName, deviceFirmwareId, deviceSoftwareId) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        elevation: 0,
        title: Text(name, textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: ListBody(children: [
            Text('${AppLocalizations.of(context)!.deviceId}: $id'),
            const SizedBox(height: 6.0),
            Text(
                '${AppLocalizations.of(context)!.deviceCreateTime}: $deviceCreateTime'),
            const SizedBox(height: 6.0),
            Text('${AppLocalizations.of(context)!.deviceLabel}: $deviceLabel'),
            const SizedBox(height: 6.0),
            Text(
                '${AppLocalizations.of(context)!.deviceProfileName}: $deviceProfileName'),
            const SizedBox(height: 6.0),
            Text(
                '${AppLocalizations.of(context)!.deviceFirmwareId}: $deviceFirmwareId'),
            const SizedBox(height: 6.0),
            Text(
                '${AppLocalizations.of(context)!.deviceSoftwareId}: $deviceSoftwareId')
          ]),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.deviceAlertDialogConfirm),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
