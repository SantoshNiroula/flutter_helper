import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World! ${getName()}'),
        ),
      ),
    );
  }

  String getName() {
    return switch (appFlavor) { 'dev' => 'DEV', 'qa' => 'QA', _ => 'PROD' };
  }
}
