import 'package:flutter/material.dart';

//import tools
import 'package:wordblitz/tools/config.dart';
import 'package:wordblitz/tools/staticNavigationData.dart';

//import external features
import '../../../wordblitz/BlitzScreen/blitz_screen.dart';
import '../../../Puzzle/PuzzleScreen/puzzle_screen.dart';
//

class HomeScreenNavigator{

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
  
  static Future<void> navigateToPuzzle(BuildContext context) async{
    /*var result = */await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context)=> PuzzleScreen(
            )
        )
    );
  }

}