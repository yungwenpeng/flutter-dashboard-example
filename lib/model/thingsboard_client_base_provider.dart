import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../storage/thingsboard_secure_storage.dart';
import 'device.dart';
import 'linechart_telemetry_data.dart';

class ThingsBoardClientBaseProvider with ChangeNotifier {
  late final ThingsboardClient tbClient;
  var myDevices = <String, MyThingsBoardDevice>{};
  String? deviceId;
  late TelemetrySubscriber telemetrySubscriber;

  Future<bool> init() async {
    var storage = ThingsBoardSecureStorage();
    tbClient = ThingsboardClient(dotenv.env['API_URL'] ?? '', storage: storage);
    await tbClient.init();
    return tbClient.isAuthenticated();
  }

  Future<void> getDevices() async {
    var pageLink = PageLink(10);

    PageData<DeviceInfo> devices;

    do {
      // Fetch tenant / customer devices using current page link
      devices = tbClient.isTenantAdmin()
          ? await tbClient.getDeviceService().getTenantDeviceInfos(pageLink)
          : await tbClient.getDeviceService().getCustomerDeviceInfos(
              tbClient.getAuthUser()!.customerId, pageLink);
      for (var device in devices.data) {
        var firmwareId =
            device.getFirmwareId() != null ? (device.getFirmwareId()!.id!) : '';
        var softwareId =
            device.getSoftwareId() != null ? (device.getSoftwareId()!.id!) : '';
        var createTime =
            DateTime.fromMillisecondsSinceEpoch(device.createdTime!);
        var assignedFirmwareName = firmwareId != ''
            ? (await tbClient
                .getOtaPackageService()
                .getOtaPackageInfo(firmwareId))
            : '';
        var assignedSoftwareName = firmwareId != ''
            ? (await tbClient
                .getOtaPackageService()
                .getOtaPackageInfo(softwareId))
            : '';
        myDevices[device.getId()!.id!] = MyThingsBoardDevice(
            device.getId()!.id!,
            device.getName(),
            device.label!,
            assignedFirmwareName.toString(),
            assignedSoftwareName.toString(),
            createTime.toString(),
            device.deviceProfileName.toString(),
            '-', // temperature
            '-' // humidity
            );
      }
      pageLink = pageLink.nextPageLink();
    } while (devices.hasNext);

    notifyListeners();
  }

  Future<void> entityDataQueryWithTimeseriesSubscription() async {
    var entityList = <String>[];
    if (deviceId == '') {
      for (var device in myDevices.values.toList()) {
        device.lcTemperatureData.clear();
        device.lcHumidityData.clear();
        entityList.add(device.deviceId);
      }
    } else {
      myDevices[deviceId]!.lcTemperatureData.clear();
      myDevices[deviceId]!.lcHumidityData.clear();
      entityList.add(deviceId!);
    }

    var entityFilter =
        EntityListFilter(entityType: EntityType.DEVICE, entityList: entityList);
    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'temperature'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'humidity')
    ];
    var devicesQuery = EntityDataQuery(
      entityFilter: entityFilter,
      latestValues: deviceTelemetry,
      pageLink: EntityDataPageLink(pageSize: 20),
    );
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var timeWindow = const Duration(hours: 1).inMilliseconds;
    var tsCmd = TimeSeriesCmd(
        keys: ['temperature', 'humidity'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);

    var telemetryService = tbClient.getTelemetryService();

    telemetrySubscriber = TelemetrySubscriber(telemetryService, [cmd]);

    telemetrySubscriber.entityDataStream.listen((entityDataUpdate) {
      //print('Received entity data update: $entityDataUpdate');
      var data = entityDataUpdate.data;
      var update = entityDataUpdate.update;
      if (data != null) {
        var id = data.data[0].entityId.id;
        for (var temp in data.data[0].timeseries["temperature"]!.reversed) {
          addTelemetryData(
              id!, 'temperature', temp.ts, double.parse(temp.value ?? "0"));
        }
        for (var temp in data.data[0].timeseries["humidity"]!.reversed) {
          addTelemetryData(
              id!, 'humidity', temp.ts, double.parse(temp.value ?? "0"));
        }
      }
      if (update != null) {
        var id = update[0].entityId.id;
        if (update[0].timeseries['temperature'] != null) {
          myDevices[id]!.temperature =
              update[0].timeseries['temperature']![0].value!;
          addTelemetryData(
              id!,
              'temperature',
              update[0].timeseries['temperature']![0].ts,
              double.parse(myDevices[id]!.temperature));
        }
        if (update[0].timeseries['humidity'] != null) {
          myDevices[id]!.humidity = update[0].timeseries['humidity']![0].value!;
          addTelemetryData(
              id!,
              'humidity',
              update[0].timeseries['humidity']![0].ts,
              double.parse(myDevices[id]!.humidity));
        }
      }
      notifyListeners();
    });
  }

  void addTelemetryData(String id, String type, int ts, double value) {
    var timestamp = DateTime.fromMillisecondsSinceEpoch(ts);
    var addData = type == 'temperature'
        ? myDevices[deviceId]!.lcTemperatureData
        : myDevices[deviceId]!.lcHumidityData;

    addData.add(LineChartTelemetryData(timestamp, value));
    if (addData[0].x.add(const Duration(minutes: 1)).isBefore(DateTime.now())) {
      addData.removeAt(0);
    }
  }
}
