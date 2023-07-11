
import 'package:flutter/cupertino.dart';

import 'package:wordblitz/tools/config.dart';

class SettingsScreenController{
  BuildContext context;
  ValueNotifier<String?> dropdown1ValueListenable = ValueNotifier<String?>("item1");
  ValueNotifier<double> blitzDurationListenable = ValueNotifier<double>(Config.blitzDuration);

  SettingsScreenController({required this.context}){
    print("settings screen controller initialised");
  }

  Future<bool> handleOnWillPop() async{
    print("handling on will pop from settings controller");
    return true;
  }

  void handleBlitzDurationSliderChanged(double value){
    blitzDurationListenable.value = value.roundToDouble();
  }
  void handleBlitzDurationSliderChangedEnd(double value){
    blitzDurationListenable.value = value.roundToDouble();
    Config.changeBlitzDuration(value.roundToDouble());
  }

  void handleDropdown1Changed(String? value){
    dropdown1ValueListenable.value = value;
  }


}
