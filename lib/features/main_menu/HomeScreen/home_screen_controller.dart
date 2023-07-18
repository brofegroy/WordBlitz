import 'package:flutter/material.dart';

// import tools
import 'package:wordblitz/tools/global.dart';
import 'package:wordblitz/tools/staticNavigationData.dart';

// import from other features
import '../../wordblitz/BlitzScreen/blitz_screen.dart';

// import within screen
import 'home_screen_utils/home_screen_navigator.dart';
//

class HomeScreenController{
  final BuildContext context;
  ValueNotifier<bool> isBlitzContinueEnabled = ValueNotifier<bool>(false);
  ValueNotifier<Map<String, dynamic>?> continueBlitzScreenDataNotifier = ValueNotifier<Map<String, dynamic>?>(null);
  ValueNotifier<bool> isPuzzleEnabledNotifier = ValueNotifier<bool>(false);
  HomeScreenController({required this.context}) {
    isPuzzleEnabledCompleter();
  }

  void isPuzzleEnabledCompleter() async{
    if(Global.isPuzzleLoaded.isCompleted) {
      isPuzzleEnabledNotifier.value = await Global.isPuzzleLoaded.future;
    } else{
      Global.isPuzzleLoaded.future.then((value) => isPuzzleEnabledNotifier.value = value);
    }
  }

  void handlePlayWordBlitz({bool isContinuing=false}) async{
    Map<String, dynamic>? previousBlitzData = (isContinuing)?continueBlitzScreenDataNotifier.value:null;
    continueBlitzScreenDataNotifier.value = null;
    /*var dummyVar = */await HomeScreenNavigator.navigateToWordBlitz(context, previousBlitzData: previousBlitzData);
    continueBlitzScreenDataNotifier.value = staticNavData.data;
/*    print("received data is from awaiting in home is ${staticNavData.data}");
    print( "the current notifier value is ${continueBlitzScreenDataNotifier.value}");
    print("bool value is ${(identical(continueBlitzScreenDataNotifier.value?["screen"], BlitzScreen))}");*/
    staticNavData.data = null;
    isBlitzContinueEnabled.value = (continueBlitzScreenDataNotifier.value != null)?(identical(continueBlitzScreenDataNotifier.value?["screen"], BlitzScreen)):false;
/*    print("is controller enabled value ${isBlitzContinueEnabled.value}");*/
  }

  void handlePlayPuzzle() async{
    print("play puzzle");
    /*var dummyVar = */await HomeScreenNavigator.navigateToPuzzle(context);
  }
}