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
