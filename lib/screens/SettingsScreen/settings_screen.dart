import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/SettingsScreen/settings_screen_controller.dart';
//

class SettingsScreen extends StatelessWidget{
  const SettingsScreen({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext context){
    final controller = SettingsScreenController();
    return const Scaffold(
      body: Text("this settings screen is built"),
    );
  }
}