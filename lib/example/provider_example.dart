import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //home: MyHomePage(title: 'MyProvider Example Demo'),
      // 1 & 2. Use Provider.value & Provider.of(context)
      //home: Provider<String>.value(
      //  value: 'This is from MyHomePage',
      //  child: const MyHomePage(title: 'MyProvider Example Demo'),
      //),
      // 3. Use ChangeNotifierProvider & MyCount class
      home: ChangeNotifierProvider<MyCounter>(
        create: (context) => MyCounter(0),
        child: const MyHomePage(title: 'MyProvider Example Demo'),
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Press the button to increment count!',
              style: TextStyle(color: Colors.cyan, fontSize: 26.0),
            ),
            // 1. Use Provider.value & Provider.of(context) with line 13~16
            //Text(Provider.of<String>(context)),
            // 2. Use Provider.value & Consumer with line 13~16
            //Consumer<String>(builder: (context, data, chile){
            //  return Text(data);
            //}),
            // 3. Use ChangeNotifierProvider & MyCount class
            Consumer<MyCounter>(
              builder: (context, MyCounter data, child) {
                return Text(
                  '${data.count}',
                  style: const TextStyle(color: Colors.cyan, fontSize: 20.0),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MyCounter mycounter = Provider.of<MyCounter>(context, listen: false);
          mycounter.incrementCounter();
        },
        tooltip: 'Increment Count',
        child: const Icon(Icons.add, size: 60.0),
      ),
    );
  }
}

// 3. Use ChangeNotifierProvider & MyCount class
class MyCounter extends ChangeNotifier {
  int _count;

  get count => _count;

  MyCounter(this._count);

  void incrementCounter() {
    _count++;
    notifyListeners();
  }
}
