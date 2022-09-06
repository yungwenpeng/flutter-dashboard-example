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
  PageList? _selectedPage;
  bool show404 = false;

  List<PageList> pages = [
    PageList('First Page', 'Item1'),
    PageList('Second Page', 'Item2'),
    PageList('Third Page', 'Item3'),
  ];

  void _handlePageTapped(PageList page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      home: Navigator(
        pages: [
          MaterialPage(
            key: const ValueKey('PagesList'),
            child: PagesListScreen(
              pages: pages,
              onTapped: _handlePageTapped,
            ),
          ),
          if (show404)
            const MaterialPage(
                key: ValueKey('UnknownPage'), child: UnknownScreen()),
          if (_selectedPage != null) PageDetailsPage(page: _selectedPage!)
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }
          // Update the list of pages by setting _selectedPage to null
          setState(() {
            _selectedPage = null;
          });
          return true;
        },
      ),
    );
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
                print('onTapped : ${page.title}');
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
  final PageList page;

  PageDetailsPage({
    required this.page,
  }) : super(key: ValueKey(page));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PageDetailsScreen(page: page);
      },
    );
  }
}

class PageDetailsScreen extends StatelessWidget {
  final PageList page;

  const PageDetailsScreen({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
