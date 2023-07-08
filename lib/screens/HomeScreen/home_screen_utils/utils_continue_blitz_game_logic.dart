import 'package:flutter/material.dart';

import 'package:wordblitz/tools/staticNavigationData.dart';
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen.dart';
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';

class utilsContinueBlitzGameLogic{

  static Future<Map<String, dynamic>?> navigateToWordBlitz(
      BuildContext context,
      {Map<String, dynamic>? previousBlitzData}) async{
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context)=> BlitzScreen(
              initialGameTime: previousBlitzData?["time"]??20,
              initialWordList: previousBlitzData?["list"]/*??null*/,
              initialGridLayout: previousBlitzData?["gridLayout"]/*??null*/,
            )
        ));
    if (result is! Map<String, dynamic>){return null;}
    staticNavData.data = result;
    if (identical(staticNavData.data["screen"] , AnalysisScreen)){return null;}
    else {print("gameData[screen] is ${staticNavData.data["screen"]}");return staticNavData.data ;}
  }



}