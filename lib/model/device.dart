import 'package:thingsboard_app/model/linechart_telemetry_data.dart';

class MyThingsBoardDevice {
  String deviceName;
  String deviceId;
  String deviceLabel;
  String deviceFirmwareId;
  String deviceSoftwareId;
  String deviceCreateTime;
  String deviceProfileName;
  String temperature;
  String humidity;
  var lcTemperatureData = <LineChartTelemetryData>[];
  var lcHumidityData = <LineChartTelemetryData>[];

  MyThingsBoardDevice(
      this.deviceId,
      this.deviceName,
      this.deviceLabel,
      this.deviceFirmwareId,
      this.deviceSoftwareId,
      this.deviceCreateTime,
      this.deviceProfileName,
      this.temperature,
      this.humidity);
}
