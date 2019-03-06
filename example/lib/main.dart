import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_jsbridge/jsbridge.dart';

import './foobar.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'running...';
  String _current = '';

  final _bridge = JSBridge("""
    let i = 0
    window.next = () => ++i
  """);

  @override
  void initState() {
    super.initState();
    initAddResult();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAddResult() async {
    final result = await Foobar.add(1, 2);

    if (!mounted) return;

    setState(() {
      _result = result.toString();
    });
  }

  Future<void> getNext() async {
    final int result = await _bridge.call("next", []);

    if (!mounted) return;

    setState(() {
      _current = result.toString();
    });
  }

  Future<void> fetch() async {
    setState(() {
      _result = "loading...";
    });

    final object = await Foobar.fetch("https://jsonplaceholder.typicode.com/todos/1");

    if (!mounted) return;

    setState(() {
      _result = object.status.toString() + "\n\n" + object.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Result: $_result\n'),
              Text('Current: $_current\n'),
              MaterialButton(
                onPressed: this.getNext,
                child: Text('Next')
              ),
              MaterialButton(
                onPressed: this.fetch,
                child: Text('Fetch')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
