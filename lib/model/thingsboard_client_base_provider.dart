import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../storage/thingsboard_secure_storage.dart';
import 'device.dart';

class ThingsBoardClientBaseProvider with ChangeNotifier {
  late final ThingsboardClient tbClient;
  var myDevices = <String, MyThingsBoardDevice>{};

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
            createTime.toString());
      }
      pageLink = pageLink.nextPageLink();
    } while (devices.hasNext);

    notifyListeners();
  }
}
