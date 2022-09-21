import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'thingsboard_client_base_provider.dart';
import 'pages.dart';

class MyAppRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  bool? _loggedIn;
  bool? get loggedIn => _loggedIn;

  set loggedIn(value) {
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
    if (_loggedIn == null) {
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
    onLogout() {
      loggedIn = false;
      deviceListIn = null;
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
              onDeviceDetails: onDeviceDetails),
      if (deviceListIn != null && deviceDetailsIn != null)
        if (deviceDetailsIn!)
          DeviceDetailsPage(
              onLogout: onLogout,
              onDeviceList: onDeviceList,
              onDeviceDetails: onDeviceDetails),
    ];
  }

  _clear() {
    deviceListIn = null;
    deviceDetailsIn = null;
  }

  @override
  Future<void> setNewRoutePath(configuration) async {/* Do Nothing */}
}
