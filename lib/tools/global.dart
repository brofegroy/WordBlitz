import 'package:wordblitz/tools/config.dart';

import 'dict_and_dice.dart';

class Global{
  static bool get isDictDiceLoading => (Dice.isDiceLoading || Dict.isDictLoading);

  static void init() async{
    Future.wait([
      Dict.load(),
      Dice.load(),
      Config.load(),
    ]);
  }
}