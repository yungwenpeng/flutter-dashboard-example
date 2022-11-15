class MyAppRouteConfiguration {
  final bool unknown;
  final bool? loggedIn;
  final bool? onUserListPage;

  MyAppRouteConfiguration.unKnow()
      : unknown = true,
        loggedIn = null,
        onUserListPage = null;
  bool get isUnKnow =>
      unknown == true && loggedIn == null && onUserListPage == null;

  MyAppRouteConfiguration.landing()
      : unknown = false,
        loggedIn = null,
        onUserListPage = null;
  bool get isLanding =>
      unknown == false && loggedIn == null && onUserListPage == null;

  MyAppRouteConfiguration.login()
      : unknown = false,
        loggedIn = false,
        onUserListPage = null;
  bool get isLoginPage =>
      unknown == false && loggedIn == false && onUserListPage == null;

  MyAppRouteConfiguration.home()
      : unknown = false,
        loggedIn = true,
        onUserListPage = null;
  bool get isHomePage =>
      unknown == false && loggedIn == true && onUserListPage == null;

  MyAppRouteConfiguration.userList()
      : unknown = false,
        loggedIn = true,
        onUserListPage = true;
  bool get isUserListPage =>
      unknown == false && loggedIn == true && onUserListPage == true;
}
