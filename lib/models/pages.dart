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
  const HomePage({required this.onLogout, required this.onUserList})
      : super(key: const ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MyHomePage(
        onLogout: onLogout,
        onUserList: onUserList,
      ),
    );
  }
}

class UserListPage extends Page {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  const UserListPage({required this.onLogout, required this.onUserList})
      : super(key: const ValueKey('UserListPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => UserList(
        onLogout: onLogout,
        onUserList: onUserList,
      ),
    );
  }
}
