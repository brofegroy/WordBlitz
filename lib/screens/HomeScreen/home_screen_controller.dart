import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';
import 'package:wordblitz/tools/Database/database_helper.dart';
import 'package:wordblitz/tools/Database/game_stats_model.dart';
import 'package:wordblitz/tools/staticNavigationData.dart';
import 'home_screen_utils/utils_continue_blitz_game_logic.dart';
//
class HomeScreenController{
  final BuildContext context;
  bool isBlitzContinueEnabled = false;
  ValueNotifier<Map<String, dynamic>?> continueBlitzScreenDataNotifier = ValueNotifier<Map<String, dynamic>?>(null);
  HomeScreenController({required this.context}){}

  void handlePlayWordBlitz({bool isContinuing=false}) async{
    Map<String, dynamic>? previousBlitzData = (isContinuing)?continueBlitzScreenDataNotifier.value:null;
    continueBlitzScreenDataNotifier.value = null;
    var dummyVar = await utilsContinueBlitzGameLogic.navigateToWordBlitz(context, previousBlitzData: previousBlitzData);
    continueBlitzScreenDataNotifier.value = staticNavData.data;
    print("receved data is from awaiting in home is ${staticNavData.data}");
    staticNavData.data = null;
    isBlitzContinueEnabled = (continueBlitzScreenDataNotifier.value != null)?(identical(continueBlitzScreenDataNotifier.value?["screen"], BlitzScreen)):false;

  }

  void handlePlayPuzzle() async{
/*    await DatabaseHelper.instance.create(GameStats(
        word: "second",
        isWordCorrect: false,
        correctGuesses: 4,
        misses: 1,
        wrongGuesses: 7,
        total: 12,
    ));*/
    List<GameStats> result = await DatabaseHelper.instance.readAllGameStats();
    print(result[0].toJson());
    print(result[1].toJson());
  }
}