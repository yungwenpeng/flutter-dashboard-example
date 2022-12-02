import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import 'route.dart';

class MyAppRouterDelegate extends RouterDelegate<MyAppRouteConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<MyAppRouteConfiguration> {
  late GlobalKey<NavigatorState> _navigatorKey;
  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  MyAppRouterDelegate() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  bool? _show404;
  bool? get show404 => _show404;
  set show404(bool? value) {
    _show404 = value;
    if (value == true) {
      userListIn = null;
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

  bool? _userListIn;
  bool? get userListIn => _userListIn;
  set userListIn(bool? value) {
    _userListIn = value;
    notifyListeners();
  }

  bool? _preferencesIn;
  bool? get preferencesIn => _preferencesIn;
  set preferencesIn(bool? value) {
    _preferencesIn = value;
    notifyListeners();
  }

  _clear() {
    show404 = null;
    userListIn = null;
    preferencesIn = null;
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
      _clear();
    }

    onUserList() {
      userListIn = true;
      preferencesIn = null;
    }

    onPreferences() {
      userListIn = null;
      preferencesIn = true;
    }

    return [
      HomePage(
        onLogout: onLogout,
        onUserList: onUserList,
        onPreferences: onPreferences,
      ),
      if (userListIn != null)
        if (userListIn!)
          UserListPage(
            onLogout: onLogout,
            onUserList: onUserList,
            onPreferences: onPreferences,
          ),
      if (preferencesIn != null)
        if (preferencesIn!)
          PreferencesPage(
            onLogout: onLogout,
            onUserList: onUserList,
            onPreferences: onPreferences,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Page> stack;
    final userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    if (_loggedIn == null && show404 == null) {
      userBaseProvider.init().then((isAuthenticated) {
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
        if (userListIn != null) {
          if (userListIn!) {
            userListIn = null;
          }
        } else if (preferencesIn != null) {
          if (preferencesIn!) {
            preferencesIn = null;
          }
        } else {
          userListIn = null;
          preferencesIn = null;
        }
        return true;
      },
    );
  }

  @override
  MyAppRouteConfiguration? get currentConfiguration {
    if (loggedIn == null) {
      return MyAppRouteConfiguration.landing();
    } else if (loggedIn == false) {
      return MyAppRouteConfiguration.login();
    } else if (show404 == true) {
      return MyAppRouteConfiguration.unKnow();
    } else if (userListIn == null && preferencesIn == null) {
      return MyAppRouteConfiguration.home();
    } else if (loggedIn == true && preferencesIn == null) {
      return MyAppRouteConfiguration.userList();
    } else if (preferencesIn == true && userListIn == null) {
      return MyAppRouteConfiguration.preferences();
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
      userListIn = null;
      preferencesIn = null;
    } else if (configuration.isUserListPage) {
      show404 = false;
      userListIn = true;
      preferencesIn = null;
    } else if (configuration.isPreferencesPage) {
      show404 = false;
      userListIn = null;
      preferencesIn = true;
    } else {
      print('setNewRoutePath: Could not set new route');
    }
  }
}
