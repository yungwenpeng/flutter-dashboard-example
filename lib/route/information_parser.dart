import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        case 'preferences':
          return MyAppRouteConfiguration.preferences();
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
      setCurrentPath('/unknown');
      return const RouteInformation(location: '/unknown');
    } else if (configuration.isLanding) {
      setCurrentPath('/');
      return null;
    } else if (configuration.isLoginPage) {
      setCurrentPath('/login');
      return const RouteInformation(location: '/login');
    } else if (configuration.isHomePage) {
      setCurrentPath('/home');
      return const RouteInformation(location: '/home');
    } else if (configuration.isUserListPage) {
      setCurrentPath('/users');
      return const RouteInformation(location: '/users');
    } else if (configuration.isPreferencesPage) {
      setCurrentPath('/preferences');
      return const RouteInformation(location: '/preferences');
    }
    return null;
  }

  void setCurrentPath(String? path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentPath', path!);
  }
}
