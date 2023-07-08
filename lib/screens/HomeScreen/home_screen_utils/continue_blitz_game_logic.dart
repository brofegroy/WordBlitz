import 'package:flutter/material.dart';
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
    Map<String, dynamic> gameData = result;
    print("gamedata at home utils is $gameData");
    if (identical(gameData["screen"] , AnalysisScreen)){return null;}
    else {print("gameData[screen] is ${gameData["screen"]}");return gameData;}
  }



}