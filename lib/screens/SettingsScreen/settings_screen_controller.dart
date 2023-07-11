
import 'package:flutter/cupertino.dart';

import 'package:wordblitz/tools/config.dart';

class SettingsScreenController{
  BuildContext context;

  ValueNotifier<double> blitzDurationNotifier = ValueNotifier<double>(Config.blitzDuration);
  ValueNotifier<bool> isNightModeNotifier = ValueNotifier<bool>(false);

  ValueNotifier<String?> dropdown1ValueNotifier = ValueNotifier<String?>("item1");
  ValueNotifier<bool> switchTestBoolNotifier = ValueNotifier<bool>(false);

  SettingsScreenController({required this.context}){
    print("settings screen controller initialised");
  }

  Future<bool> handleOnWillPop() async{
    print("handling on will pop from settings controller");
    return true;
  }

  void handleBlitzDurationSliderChanged(double value){
    blitzDurationNotifier.value = value.roundToDouble();
  }
  void handleBlitzDurationSliderChangedEnd(double value){
    blitzDurationNotifier.value = value.roundToDouble();
    Config.changeBlitzDuration(value.roundToDouble());
  }

  void handleNightModeChanged(bool value){
    isNightModeNotifier.value = value;
    Config.changeIsNightMode(value);
  }



  void handleDropdown1Changed(String? value){
    dropdown1ValueNotifier.value = value;
  }

  void handleTestSwitchChanged(bool value){
    switchTestBoolNotifier.value = value;
  }

}
