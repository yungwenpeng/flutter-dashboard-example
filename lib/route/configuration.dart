class MyAppRouteConfiguration {
  final bool unknown;
  final bool? loggedIn;
  final bool? onUserListPage;
  final bool? onPreferencesPage;

  MyAppRouteConfiguration.unKnow()
      : unknown = true,
        loggedIn = null,
        onUserListPage = null,
        onPreferencesPage = null;
  bool get isUnKnow =>
      unknown == true &&
      loggedIn == null &&
      onUserListPage == null &&
      onPreferencesPage == null;

  MyAppRouteConfiguration.landing()
      : unknown = false,
        loggedIn = null,
        onUserListPage = null,
        onPreferencesPage = null;
  bool get isLanding =>
      unknown == false &&
      loggedIn == null &&
      onUserListPage == null &&
      onPreferencesPage == null;

  MyAppRouteConfiguration.login()
      : unknown = false,
        loggedIn = false,
        onUserListPage = null,
        onPreferencesPage = null;
  bool get isLoginPage =>
      unknown == false &&
      loggedIn == false &&
      onUserListPage == null &&
      onPreferencesPage == null;

  MyAppRouteConfiguration.home()
      : unknown = false,
        loggedIn = true,
        onUserListPage = null,
        onPreferencesPage = null;
  bool get isHomePage =>
      unknown == false &&
      loggedIn == true &&
      onUserListPage == null &&
      onPreferencesPage == null;

  MyAppRouteConfiguration.userList()
      : unknown = false,
        loggedIn = true,
        onUserListPage = true,
        onPreferencesPage = null;
  bool get isUserListPage =>
      unknown == false &&
      loggedIn == true &&
      onUserListPage == true &&
      onPreferencesPage == null;

  MyAppRouteConfiguration.preferences()
      : unknown = false,
        loggedIn = true,
        onUserListPage = null,
        onPreferencesPage = true;
  bool get isPreferencesPage =>
      unknown == false &&
      loggedIn == true &&
      onUserListPage == null &&
      onPreferencesPage == true;
}
