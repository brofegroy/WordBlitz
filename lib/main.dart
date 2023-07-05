import 'package:flutter/material.dart';

//import dependencies
import 'package:wordblitz/tools/global.dart';
//
//import screens
import 'screens/HomeScreen/home_screen.dart';
//

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Load all static async values from assets to memory here
    Global.init();
    //
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
