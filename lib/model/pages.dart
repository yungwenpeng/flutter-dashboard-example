import 'package:flutter/material.dart';

import '../landing.dart';
import '../pages/home.dart';
import '../pages/login.dart';
import '../pages/device_list.dart';
import '../pages/device_details.dart';

class LandingPage extends Page {
  const LandingPage() : super(key: const ValueKey('LandingPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => const Landing(),
    );
  }
}

class LoginPage extends Page {
  final VoidCallback onLogin;
  const LoginPage({required this.onLogin})
      : super(key: const ValueKey('LoginPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => Login(onLogin: onLogin),
    );
  }
}

class HomePage extends Page {
  final VoidCallback onLogout;
  final VoidCallback onDeviceList;
  const HomePage({required this.onLogout, required this.onDeviceList})
      : super(key: const ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MyHomePage(
        onLogout: onLogout,
        onDeviceList: onDeviceList,
      ),
    );
  }
}

class DeviceListPage extends Page {
  final VoidCallback onLogout;
  final VoidCallback onDeviceList;
  final VoidCallback onDeviceDetails;
  final Function(String) selectedDeviceId;

  const DeviceListPage(
      {required this.onLogout,
      required this.onDeviceList,
      required this.onDeviceDetails,
      required this.selectedDeviceId})
      : super(key: const ValueKey('DeviceListPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MyDevicesPage(
          onLogout: onLogout,
          onDeviceList: onDeviceList,
          onDeviceDetails: onDeviceDetails,
          selectedDeviceId: selectedDeviceId),
    );
  }
}

class DeviceDetailsPage extends Page {
  final VoidCallback onLogout;
  final VoidCallback onDeviceList;
  final VoidCallback onDeviceDetails;
  final String selectedDeviceId;
  const DeviceDetailsPage(
      {required this.onLogout,
      required this.onDeviceList,
      required this.onDeviceDetails,
      required this.selectedDeviceId})
      : super(key: const ValueKey('DeviceDetailsPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => DeviceDetails(
          onLogout: onLogout,
          onDeviceList: onDeviceList,
          onDeviceDetails: onDeviceDetails,
          selectedDeviceId: selectedDeviceId),
    );
  }
}
