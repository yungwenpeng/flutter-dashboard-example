import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'thingsboard_client_base_provider.dart';
import 'pages.dart';
import 'route_configuration.dart';

class MyAppRouterDelegate extends RouterDelegate<MyAppRouteConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<MyAppRouteConfiguration> {
  bool? _show404;
  bool? get show404 => _show404;
  set show404(bool? value) {
    _show404 = value;
    if (value == true) {
      deviceListIn = null;
      deviceDetailsIn = null;
      selectedDeviceId = null;
    }
    notifyListeners();
  }

  bool? _loggedIn;
  bool? get loggedIn => _loggedIn;

  set loggedIn(value) {
    if (_loggedIn == true && value == false) {
      // It is a logout!
      _clear();
    }
    _loggedIn = value;
    notifyListeners();
  }

  bool? _deviceListIn;
  bool? get deviceListIn => _deviceListIn;
  set deviceListIn(bool? value) {
    _deviceListIn = value;
    notifyListeners();
  }

  bool? _deviceDetailsIn;
  bool? get deviceDetailsIn => _deviceDetailsIn;
  set deviceDetailsIn(bool? value) {
    _deviceDetailsIn = value;
    notifyListeners();
  }

  String? _selectedDeviceId;
  String? get selectedDeviceId => _selectedDeviceId;
  set selectedDeviceId(String? value) {
    _selectedDeviceId = value;
    notifyListeners();
  }

  late GlobalKey<NavigatorState> _navigatorKey;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  MyAppRouterDelegate() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  @override
  Widget build(BuildContext context) {
    List<Page> stack;
    final tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    if (_loggedIn == null && show404 == null) {
      tbClientBaseProvider.init().then((isAuthenticated) {
        isAuthenticated ? loggedIn = true : loggedIn = false;
      });
    }
    if (loggedIn == null) {
      stack = _landingStack;
    } else if (loggedIn!) {
      stack = _loggedInStack;
    } else {
      stack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        if (deviceDetailsIn == null && deviceListIn != null) {
          if (deviceListIn!) {
            deviceListIn = null;
          }
        } else if (deviceDetailsIn != null && deviceListIn != null) {
          if (deviceDetailsIn!) {
            deviceListIn = true;
          }
        } else {
          deviceListIn = null;
        }
        deviceDetailsIn = null;
        selectedDeviceId = null;
        return true;
      },
    );
  }

  List<Page> get _landingStack => [const LandingPage()];

  List<Page> get _loggedOutStack => [
        LoginPage(
          onLogin: () {
            loggedIn = true;
          },
        )
      ];

  List<Page> get _loggedInStack {
    final selectedDeviceId = this.selectedDeviceId;
    onLogout() {
      loggedIn = false;
      _clear();
    }

    onDeviceList() {
      deviceListIn = true;
    }

    onDeviceDetails() {
      deviceDetailsIn = true;
    }

    return [
      HomePage(onLogout: onLogout, onDeviceList: onDeviceList),
      if (deviceListIn != null)
        if (deviceListIn!)
          DeviceListPage(
              onLogout: onLogout,
              onDeviceList: onDeviceList,
              onDeviceDetails: onDeviceDetails,
              selectedDeviceId: (String selectedDeviceId) {
                this.selectedDeviceId = selectedDeviceId;
              }),
      if (deviceListIn != null && deviceDetailsIn != null)
        if (deviceDetailsIn!)
          DeviceDetailsPage(
              onLogout: onLogout,
              onDeviceList: onDeviceList,
              onDeviceDetails: onDeviceDetails,
              selectedDeviceId: selectedDeviceId!),
    ];
  }

  _clear() {
    show404 = null;
    deviceListIn = null;
    deviceDetailsIn = null;
    selectedDeviceId = null;
  }

  @override
  MyAppRouteConfiguration? get currentConfiguration {
    if (loggedIn == null) {
      return MyAppRouteConfiguration.landing();
    } else if (loggedIn == false) {
      return MyAppRouteConfiguration.login();
    } else if (show404 == true) {
      return MyAppRouteConfiguration.unKnow();
    } else if (deviceListIn == null) {
      return MyAppRouteConfiguration.home();
    } else if (deviceDetailsIn == null && deviceListIn == true) {
      return MyAppRouteConfiguration.deviceList();
    } else if (deviceDetailsIn == true && deviceListIn == true) {
      return MyAppRouteConfiguration.deviceDetails(selectedDeviceId);
    } else {
      return null;
    }
  }
  @override
  Future<void> setNewRoutePath(MyAppRouteConfiguration configuration) async {
    if (configuration.unknown) {
      show404 = true;
    } else if (configuration.isLanding ||
        configuration.isHomePage ||
        configuration.isLoginPage) {
      show404 = false;
      deviceListIn = null;
      deviceDetailsIn = null;
      selectedDeviceId = null;
    } else if (configuration.isDeviceListPage) {
      show404 = false;
      deviceListIn = true;
      deviceDetailsIn = null;
      selectedDeviceId = null;
    } else if (configuration.isDeviceDetailsPage) {
      show404 = false;
      deviceListIn = true;
      deviceDetailsIn = true;
      selectedDeviceId = configuration.deviceId;
    } else {
      print('setNewRoutePath: Could not set new route');
    }
  }
}
