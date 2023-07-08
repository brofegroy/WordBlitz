import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';
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
    print("incomingGameData is ${staticNavData.data}");
    continueBlitzScreenDataNotifier.value = await staticNavData.data;
    isBlitzContinueEnabled = (continueBlitzScreenDataNotifier.value != null)?(identical(continueBlitzScreenDataNotifier.value?["screen"], BlitzScreen)):false;
  }


}