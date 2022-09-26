import 'package:flutter/material.dart';

import 'route_configuration.dart';

class MyAppRouteInformationParser
    extends RouteInformationParser<MyAppRouteConfiguration> {
  @override
  Future<MyAppRouteConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) {
      return MyAppRouteConfiguration.home();
    } else if (uri.pathSegments.length == 1) {
      final first = uri.pathSegments[0].toLowerCase();
      switch (first) {
        case 'home':
          return MyAppRouteConfiguration.home();
        case 'login':
          return MyAppRouteConfiguration.login();
        case 'devices':
          return MyAppRouteConfiguration.deviceList();
        default:
          return MyAppRouteConfiguration.unKnow();
      }
    } else if (uri.pathSegments.length == 2) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      final regexp = RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}');
      if (first == 'devices' && regexp.hasMatch(second)) {
        return MyAppRouteConfiguration.deviceDetails(second);
      } else {
        return MyAppRouteConfiguration.unKnow();
      }
    } else {
      return MyAppRouteConfiguration.unKnow();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(
      MyAppRouteConfiguration configuration) {
    if (configuration.isUnKnow) {
      return const RouteInformation(location: '/unknown');
    } else if (configuration.isLanding) {
      return null;
    } else if (configuration.isLoginPage) {
      return const RouteInformation(location: '/login');
    } else if (configuration.isHomePage) {
      return const RouteInformation(location: '/home');
    } else if (configuration.isDeviceListPage) {
      return const RouteInformation(location: '/devices');
    } else if (configuration.isDeviceDetailsPage) {
      return RouteInformation(location: '/devices/${configuration.deviceId}');
    } else {
      return null;
    }
  }
}
