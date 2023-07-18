import 'package:wordblitz/tools/config.dart';

import 'dict_and_dice.dart';

class InitialiseAtMain{
  static void init() async{
    await Config.load();
    Future.wait([
      Dict.load(),
      Dice.load(),
    ]);
  }
}