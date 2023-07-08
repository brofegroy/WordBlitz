import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/tools/staticNavigationData.dart';
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';
import 'package:wordblitz/tools/config.dart';
//
class utilsContinueBlitzGameLogic{

  static Future<void> navigateToWordBlitz(
      BuildContext context,
      {Map<String, dynamic>? previousBlitzData}) async{
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context)=> BlitzScreen(
              initialGameTime: previousBlitzData?["time"]??Config.blitzDuration,
              initialWordList: previousBlitzData?["list"]/*??null*/,
              initialGridLayout: previousBlitzData?["gridLayout"]/*??null*/,
            )
        ));
    staticNavData.data = result;
  }



}