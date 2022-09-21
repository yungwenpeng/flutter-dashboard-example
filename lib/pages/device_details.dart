import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/thingsboard_client_base_provider.dart';
import '../model/linechart_telemetry_data.dart';

class DeviceDetails extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeviceList;
  final VoidCallback onDeviceDetails;
  const DeviceDetails(
      {super.key,
      required this.onLogout,
      required this.onDeviceList,
      required this.onDeviceDetails});

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
    var temperature = deviceDetails!.temperature;
    var humidity = deviceDetails.humidity;

    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        alignment: Alignment.center,
        image: AssetImage('assets/images/welcome_bg.png'),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(deviceDetails.deviceName),
        ),
        body: Card(
          elevation: 0,
          color: Colors.white70,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: SingleChildScrollView(
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
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Temperature: $temperature',
                  style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 23.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Humidity: $humidity',
                  style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 23.0),
                ),
              ),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 161, 152, 223),
                          Color.fromARGB(255, 244, 244, 245),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SfCartesianChart(
                        /*enableAxisAnimation: true,*/
                        legend: Legend(
                            isVisible: true,
                            //offset: const Offset(20, 100),
                            position: LegendPosition.top,
                            borderColor: Colors.black,
                            borderWidth: 2),
                        primaryXAxis: DateTimeAxis(
                          interval: 5,
                          labelIntersectAction:
                              AxisLabelIntersectAction.multipleRows,
                          title: AxisTitle(
                              text: 'TimeStamp',
                              textStyle: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400)),
                          //labelRotation: 90,
                          //dateFormat: DateFormat('kk:mm:ss'),
                        ),
                        series: <ChartSeries<LineChartTelemetryData, DateTime>>[
                          LineSeries<LineChartTelemetryData, DateTime>(
                            name: 'Temperature',
                            dataSource: deviceDetails.lcTemperatureData,
                            xValueMapper: (LineChartTelemetryData data, _) =>
                                data.x,
                            yValueMapper: (LineChartTelemetryData data, _) =>
                                data.y,
                            color: Colors.orangeAccent,
                            /*markerSettings:
                                const MarkerSettings(isVisible: true),*/
                          ),
                          LineSeries<LineChartTelemetryData, DateTime>(
                            name: 'Humidity',
                            dataSource: deviceDetails.lcHumidityData,
                            xValueMapper: (LineChartTelemetryData data, _) =>
                                data.x,
                            yValueMapper: (LineChartTelemetryData data, _) =>
                                data.y,
                            color: Colors.blueAccent,
                          )
                        ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
