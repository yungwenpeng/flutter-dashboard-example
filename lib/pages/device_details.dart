import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../model/thingsboard_client_base_provider.dart';

class DeviceDetails extends StatefulWidget {
  const DeviceDetails({super.key});

  @override
  State<DeviceDetails> createState() => _DeviceDetailsState();
}

class _DeviceDetailsState extends State<DeviceDetails>
    with WidgetsBindingObserver {
  late ThingsBoardClientBaseProvider tbClientBaseProvider;
  late TelemetrySubscriber telemetrySubscriber;
  bool isSubscribed = false;

  void deviceTimeseriesSubscription() {
    tbClientBaseProvider.entityDataQueryWithTimeseriesSubscription();
    telemetrySubscriber = tbClientBaseProvider.telemetrySubscriber;
    if (!isSubscribed) {
      telemetrySubscriber.subscribe();
      isSubscribed = true;
    }
  }

  void deviceTimeseriesunSubscription() {
    if (isSubscribed) {
      telemetrySubscriber.unsubscribe();
      isSubscribed = false;
    }
  }

  @override
  void initState() {
    super.initState();

    tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);

    tbClientBaseProvider.myDevices[tbClientBaseProvider.deviceId]!.temperature =
        '-';
    tbClientBaseProvider.myDevices[tbClientBaseProvider.deviceId]!.humidity =
        '-';
    deviceTimeseriesSubscription();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      deviceTimeseriesSubscription();
    } else {
      deviceTimeseriesunSubscription();
    }
  }

  @override
  void dispose() {
    deviceTimeseriesunSubscription();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context);
    var deviceDetails =
        tbClientBaseProvider.myDevices[tbClientBaseProvider.deviceId];
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
          title: Text(deviceDetails!.deviceName),
        ),
        body: Card(
          elevation: 0,
          color: Colors.white70,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              title: Center(
                  child: Text(
                deviceDetails.deviceName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 25.0),
              )),
              subtitle: Text(deviceDetails.deviceId, maxLines: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Temperature: ${tbClientBaseProvider.myDevices[tbClientBaseProvider.deviceId]!.temperature}',
                style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 23.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Humidity: ${tbClientBaseProvider.myDevices[tbClientBaseProvider.deviceId]!.humidity}',
                style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 23.0),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
