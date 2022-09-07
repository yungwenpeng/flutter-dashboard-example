import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Navigator 2.0 Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageRouterDelegate _routerDelegate = PageRouterDelegate();
  final PageRouteInformationParser _routeInformationParser =
      PageRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: widget.title,
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class PageRoutePath {
  final int? id;
  final bool isUnknown;

  PageRoutePath.home()
      : id = null,
        isUnknown = false;

  PageRoutePath.details(this.id) : isUnknown = false;

  PageRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;

  PageRoutePath(this.id, this.isUnknown);
}

class PageRouterDelegate extends RouterDelegate<PageRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  PageList? _selectedPage;
  bool show404 = false;

  List<PageList> pages = [
    PageList('First Page', 'Item1'),
    PageList('Second Page', 'Item2'),
    PageList('Third Page', 'Item3'),
  ];

  PageRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  void _handlePageTapped(PageList page) {
    _selectedPage = page;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('PagesListPage'),
          child: PagesListScreen(
            pages: pages,
            onTapped: _handlePageTapped,
          ),
        ),
        if (show404)
          const MaterialPage(
              key: ValueKey('UnknownPage'), child: UnknownScreen())
        else if (_selectedPage != null)
          PageDetailsPage(
              page: _selectedPage!,
              path: PageRoutePath(pages.indexOf(_selectedPage!), false))
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedPage to null
        _selectedPage = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PageRoutePath configuration) async {
    if (configuration.isUnknown) {
      _selectedPage = null;
      show404 = true;
      return;
    }

    if (configuration.isDetailsPage) {
      if (configuration.id! < 0 || configuration.id! > pages.length - 1) {
        show404 = true;
        return;
      }

      _selectedPage = pages[configuration.id!];
    } else {
      _selectedPage = null;
    }

    show404 = false;
  }

  @override
  PageRoutePath get currentConfiguration {
    if (show404) {
      return PageRoutePath.unknown();
    }

    return _selectedPage == null
        ? PageRoutePath.home()
        : PageRoutePath.details(pages.indexOf(_selectedPage!));
  }
}

class PageRouteInformationParser extends RouteInformationParser<PageRoutePath> {
  @override
  Future<PageRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return PageRoutePath.home();
    }

    // Handle '/page/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'page') return PageRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return PageRoutePath.unknown();
      return PageRoutePath.details(id);
    }

    // Handle unknown routes
    return PageRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(PageRoutePath configuration) {
    if (configuration.isUnknown) {
      return const RouteInformation(location: '/404');
    }
    if (configuration.isHomePage) {
      return const RouteInformation(location: '/');
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(location: '/page/${configuration.id}');
    }
    return null;
  }
}

class PageList {
  final String title;
  final String item;

  PageList(this.title, this.item);
}

class PagesListScreen extends StatelessWidget {
  final List<PageList> pages;
  final ValueChanged<PageList> onTapped;

  const PagesListScreen({
    super.key,
    required this.pages,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Navigator 2.0 Test'),
      ),
      body: ListView(
        children: [
          for (var page in pages)
            ListTile(
              title: Text(page.title),
              subtitle: Text(page.item),
              onTap: () {
                onTapped(page);
              },
            )
        ],
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('404!'),
      ),
    );
  }
}

class PageDetailsPage extends Page {
  final PageRoutePath path;
  final PageList page;

  PageDetailsPage({
    required this.page,
    required this.path,
  }) : super(key: ValueKey(page));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PageDetailsScreen(
          page: page,
          path: path,
        );
      },
    );
  }
}

class PageDetailsScreen extends StatelessWidget {
  final PageRoutePath path;
  final PageList page;

  const PageDetailsScreen({
    super.key,
    required this.path,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path.id.toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(page.title, style: Theme.of(context).textTheme.headline6),
            Text(page.item, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
