import 'package:flutter/material.dart';

import 'route.dart';

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
        case 'users':
          return MyAppRouteConfiguration.userList();
        default:
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
    } else if (configuration.isUserListPage) {
      return const RouteInformation(location: '/users');
    } else {
      return null;
    }
  }
}
