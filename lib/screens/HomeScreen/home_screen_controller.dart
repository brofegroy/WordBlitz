import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';
import 'home_screen_utils/continue_blitz_game_logic.dart';
//
class HomeScreenController{
  final BuildContext context;
  bool isBlitzContinueEnabled = false;
  ValueNotifier<Map<String, dynamic>?> continueBlitzScreenDataNotifier = ValueNotifier<Map<String, dynamic>?>(null);
  HomeScreenController({required this.context}){}

  void handlePlayWordBlitz({bool isContinuing=false}) async{
    Map<String, dynamic>? previousBlitzData = (isContinuing)?continueBlitzScreenDataNotifier.value:null;
    continueBlitzScreenDataNotifier.value = null;
    var incomingGameData = await utilsContinueBlitzGameLogic.navigateToWordBlitz(context, previousBlitzData: previousBlitzData);
    print("incomingGameData is $incomingGameData");
    continueBlitzScreenDataNotifier.value = incomingGameData;
    isBlitzContinueEnabled = continueBlitzScreenDataNotifier.value != null;
  }


}