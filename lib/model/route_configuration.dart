class MyAppRouteConfiguration {
  late final String? deviceId;
  final bool unknown;
  final bool? loggedIn;
  final bool? onDeviceListPage;
  final bool? onDeviceDetailsPage;

  MyAppRouteConfiguration.landing()
      : unknown = false,
        loggedIn = null,
        onDeviceListPage = null,
        onDeviceDetailsPage = null,
        deviceId = null;
  bool get isLanding =>
      unknown == false &&
      loggedIn == null &&
      onDeviceListPage == null &&
      onDeviceDetailsPage == null &&
      deviceId == null;

  MyAppRouteConfiguration.login()
      : unknown = false,
        loggedIn = false,
        onDeviceListPage = null,
        onDeviceDetailsPage = null,
        deviceId = null;
  bool get isLoginPage =>
      unknown == false &&
      loggedIn == false &&
      onDeviceListPage == null &&
      onDeviceDetailsPage == null &&
      deviceId == null;

  MyAppRouteConfiguration.home()
      : unknown = false,
        loggedIn = true,
        onDeviceListPage = null,
        onDeviceDetailsPage = null,
        deviceId = null;
  bool get isHomePage =>
      unknown == false &&
      loggedIn == true &&
      onDeviceListPage == null &&
      onDeviceDetailsPage == null &&
      deviceId == null;

  MyAppRouteConfiguration.deviceList()
      : unknown = false,
        loggedIn = true,
        onDeviceListPage = true,
        onDeviceDetailsPage = null,
        deviceId = null;
  bool get isDeviceListPage =>
      unknown == false &&
      loggedIn == true &&
      onDeviceListPage == true &&
      onDeviceDetailsPage == null &&
      deviceId == null;

  MyAppRouteConfiguration.deviceDetails(this.deviceId)
      : unknown = false,
        loggedIn = true,
        onDeviceListPage = true,
        onDeviceDetailsPage = true;
  bool get isDeviceDetailsPage =>
      unknown == false &&
      loggedIn == true &&
      onDeviceListPage == true &&
      onDeviceDetailsPage == true &&
      deviceId != null;

  MyAppRouteConfiguration.unKnow()
      : unknown = true,
        loggedIn = null,
        onDeviceListPage = null,
        onDeviceDetailsPage = null,
        deviceId = null;
  bool get isUnKnow =>
      unknown == true &&
      loggedIn == null &&
      onDeviceListPage == null &&
      onDeviceDetailsPage == null &&
      deviceId == null;
}
