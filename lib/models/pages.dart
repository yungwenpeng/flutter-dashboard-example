import 'package:flutter/material.dart';

import '../pages/pages.dart';

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
  final VoidCallback onUserList;
  final VoidCallback onPreferences;
  const HomePage(
      {required this.onLogout,
      required this.onUserList,
      required this.onPreferences})
      : super(key: const ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MyHomePage(
        onLogout: onLogout,
        onUserList: onUserList,
        onPreferences: onPreferences,
      ),
    );
  }
}

class UserListPage extends Page {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  final VoidCallback onPreferences;
  const UserListPage(
      {required this.onLogout,
      required this.onUserList,
      required this.onPreferences})
      : super(key: const ValueKey('UserListPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => UserList(
        onLogout: onLogout,
        onUserList: onUserList,
        onPreferences: onPreferences,
      ),
    );
  }
}

class PreferencesPage extends Page {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  final VoidCallback onPreferences;
  const PreferencesPage(
      {required this.onLogout,
      required this.onUserList,
      required this.onPreferences})
      : super(key: const ValueKey('PreferencesPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MyPreferences(
        onLogout: onLogout,
        onUserList: onUserList,
        onPreferences: onPreferences,
      ),
    );
  }
}
