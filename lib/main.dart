import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // 改造一：默认蓝 → teal 种子色，全应用按钮/水波纹/AppBar 同步变化
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // 改造一：当前步长，默认 1
  int _step = 1;

  void _incrementCounter() {
    setState(() {
      _counter += _step;
    });
  }

  // 改造一：弹层选择步长 1/2/5，选中值通过 Navigator.pop 带回
  Future<void> _pickStep() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in const [1, 2, 5])
              ListTile(
                title: Text('步长 $value'),
                trailing: value == _step ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _step = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _pickStep,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text('步长 $_step'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
